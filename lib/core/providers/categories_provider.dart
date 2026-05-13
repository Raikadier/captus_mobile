import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/category.dart';
import 'auth_provider.dart';

class CategoriesService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<CategoryModel>> fetchAll(String userId) async {
    final response = await _client
        .from('categories')
        .select()
        .eq('user_id', userId)
        .order('name', ascending: true);

    return (response as List)
        .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<CategoryModel> create(String name, String userId) async {
    final response = await _client
        .from('categories')
        .insert({
          'name': name,
          'user_id': userId,
        })
        .select()
        .single();

    return CategoryModel.fromJson(response as Map<String, dynamic>);
  }

  Future<CategoryModel> updateCategory(int id, String name) async {
    final response = await _client
        .from('categories')
        .update({'name': name})
        .eq('id', id)
        .select()
        .single();

    return CategoryModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _client
        .from('categories')
        .delete()
        .eq('id', id);
  }

  Future<CategoryModel?> getGeneralCategory(String userId) async {
    final response = await _client
        .from('categories')
        .select()
        .eq('user_id', userId)
        .ilike('name', 'General')
        .maybeSingle();

    if (response == null) return null;
    return CategoryModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> createGeneralCategory(String userId) async {
    final existing = await getGeneralCategory(userId);
    if (existing == null) {
      await _client
          .from('categories')
          .insert({
            'name': 'General',
            'user_id': userId,
          });
    }
  }
}

final categoriesServiceProvider = Provider<CategoriesService>(
  (ref) => CategoriesService(),
);

class CategoriesNotifier extends AsyncNotifier<List<CategoryModel>> {
  @override
  Future<List<CategoryModel>> build() {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return Future.value([]);
    }
    return ref.read(categoriesServiceProvider).fetchAll(user.id);
  }

  Future<void> refreshCategories() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(categoriesServiceProvider).fetchAll(user.id),
    );
  }

  Future<void> create(String name) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      final newCategory = await ref.read(categoriesServiceProvider).create(name, user.id);
      state = state.whenData((categories) => [...categories, newCategory]..sort((a, b) => a.name.compareTo(b.name)));
    } catch (_) {
      await refreshCategories();
      rethrow;
    }
  }

  Future<void> updateCategory(int id, String name) async {
    try {
      final updated = await ref.read(categoriesServiceProvider).updateCategory(id, name);
      state = state.whenData(
        (categories) => categories.map((c) => c.id == id ? updated : c).toList()..sort((a, b) => a.name.compareTo(b.name)),
      );
    } catch (_) {
      await refreshCategories();
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    state = state.whenData(
      (categories) => categories.where((c) => c.id != id).toList(),
    );
    try {
      await ref.read(categoriesServiceProvider).delete(id);
    } catch (_) {
      await refreshCategories();
      rethrow;
    }
  }
}

final categoriesNotifierProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<CategoryModel>>(
  CategoriesNotifier.new,
);

final generalCategoryProvider = Provider<CategoryModel?>((ref) {
  final categoriesAsync = ref.watch(categoriesNotifierProvider);
  return categoriesAsync.whenOrNull(
    data: (categories) {
      try {
        return categories.firstWhere((c) => c.isGeneral);
      } catch (_) {
        return null;
      }
    },
  );
});
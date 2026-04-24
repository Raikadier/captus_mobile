import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../models/category.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  List<Map<String, dynamic>> _categories = [];
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _userId = user.id;
      final categories = LocalStorageService.getCategoriesByUserId(user.id);
      setState(() {
        _categories = categories;
      });
    }
  }

  Future<void> _showCategoryDialog({Map<String, dynamic>? category}) async {
    final isEditing = category != null;
    final controller = TextEditingController(text: category?['name'] ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          isEditing ? 'Editar Categoría' : 'Nueva Categoría',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nombre de la categoría',
            filled: true,
            fillColor: AppColors.surface2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty || _userId == null) return;

              if (isEditing) {
                final updatedCategory = {
                  ...category!,
                  'name': name,
                };
                await LocalStorageService.updateCategory(
                    category['id'], updatedCategory);
              } else {
                final newCategory = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'name': name,
                  'user_id': _userId!,
                  'created_at': DateTime.now().toIso8601String(),
                };
                await LocalStorageService.addCategory(newCategory);
              }

              if (mounted) {
                Navigator.pop(context);
                _loadCategories();
              }
            },
            child: Text(isEditing ? 'Guardar' : 'Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(Map<String, dynamic> category) async {
    if (category['name'] == 'General') return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Eliminar Categoría',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text(
            '¿Estás seguro de eliminar "${category['name']}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await LocalStorageService.deleteCategory(category['id']);
      _loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Categorías'),
        elevation: 0,
      ),
      body: _categories.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.category_outlined,
                      size: 64, color: AppColors.textDisabled),
                  const SizedBox(height: 16),
                  Text(
                    'No hay categorías',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega una nueva categoría para organizar tus tareas',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final category = _categories[i];
                final isGeneral = category['name'] == 'General';
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isGeneral
                            ? AppColors.primary.withAlpha(38)
                            : AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isGeneral
                            ? Icons.category_rounded
                            : Icons.label_outline_rounded,
                        color: isGeneral
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      category['name'] ?? '',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: isGeneral
                        ? Text('Categoría por defecto',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.textDisabled))
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isGeneral)
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: AppColors.textSecondary,
                            onPressed: () =>
                                _showCategoryDialog(category: category),
                          ),
                        if (!isGeneral)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: AppColors.error,
                            onPressed: () => _deleteCategory(category),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

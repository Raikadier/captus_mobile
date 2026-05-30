import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/categories_provider.dart';
import '../../../models/category.dart';
import '../../../shared/widgets/captus_fab.dart';

class CategoriesManagementScreen extends ConsumerWidget {
  const CategoriesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    return Scaffold(
      restorationId: 'categories_management_screen',
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Categorías'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver',
          onPressed: () => context.pop(),
        ),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.s4),
              Text('Error: $error', style: tt.bodyMedium),
              const SizedBox(height: AppSpacing.s4),
              ElevatedButton(
                onPressed: () => ref
                    .read(categoriesNotifierProvider.notifier)
                    .refreshCategories(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (categories) => categories.isEmpty
            ? _EmptyState(onAdd: () => _showCreateDialog(context, ref))
            : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.s4),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _CategoryTile(
                    category: category,
                    onEdit: category.isGeneral
                        ? null
                        : () =>
                            _showEditDialog(context, ref, category),
                    onDelete: category.isGeneral
                        ? null
                        : () => _showDeleteDialog(
                            context, ref, category),
                  );
                },
              ),
      ),
      floatingActionButton: CaptusFab(
        onPressed: () => _showCreateDialog(context, ref),
        icon: Icons.add_rounded,
        tooltip: 'Nueva categoría',
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva categoría'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
              hintText: 'Nombre de la categoría'),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);
              await ref
                  .read(categoriesNotifierProvider.notifier)
                  .create(name);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, CategoryModel category) {
    final controller =
        TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar categoría'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
              hintText: 'Nombre de la categoría'),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);
              await ref
                  .read(categoriesNotifierProvider.notifier)
                  .updateCategory(category.id, name);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text(
            '¿Estás seguro de que quieres eliminar "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(categoriesNotifierProvider.notifier)
                  .deleteCategory(category.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.category_outlined,
              size: 64, color: AppColors.textDisabled),
          const SizedBox(height: AppSpacing.s4),
          Text('No hay categorías',
              style: tt.headlineMedium!
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.s2),
          Text('Crea tu primera categoría',
              style: tt.bodyMedium!
                  .copyWith(color: AppColors.textDisabled)),
          const SizedBox(height: AppSpacing.s6),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Crear categoría'),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CategoryTile({
    required this.category,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r5),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4, vertical: AppSpacing.s2),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: category.isGeneral
                ? AppColors.primaryLight
                : AppColors.surface2,
            borderRadius: BorderRadius.circular(AppRadius.r4),
          ),
          child: Icon(
            category.isGeneral
                ? Icons.folder_rounded
                : Icons.label_outline_rounded,
            color: category.isGeneral
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
        title: Text(category.name,
            style: tt.headlineSmall),
        subtitle: category.isGeneral
            ? Text('Categoría predeterminada',
                style: tt.bodySmall!
                    .copyWith(color: AppColors.textSecondary))
            : null,
        trailing: category.isGeneral
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Editar',
                    onPressed: onEdit,
                    color: AppColors.textSecondary,
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.delete_outline, size: 20),
                    tooltip: 'Eliminar',
                    onPressed: onDelete,
                    color: AppColors.error,
                  ),
                ],
              ),
      ),
    );
  }
}

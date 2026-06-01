import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_errors.dart';
import '../services/admin_service.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class AdminGradingScalesScreen extends StatefulWidget {
  const AdminGradingScalesScreen({super.key});

  @override
  State<AdminGradingScalesScreen> createState() =>
      _AdminGradingScalesScreenState();
}

class _AdminGradingScalesScreenState extends State<AdminGradingScalesScreen> {
  List<dynamic> _scales = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final scales = await AdminService.instance.getGradingScales();
      if (mounted) setState(() { _scales = scales; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // ── Create / Edit dialog ────────────────────────────────────────────────

  Future<void> _showFormDialog({Map<String, dynamic>? existing}) async {
    final nameCtrl = TextEditingController(
        text: existing != null ? existing['name'] as String? ?? '' : '');
    final minCtrl = TextEditingController(
        text: existing != null
            ? (existing['min_score'] ?? 0).toString()
            : '0');
    final maxCtrl = TextEditingController(
        text: existing != null
            ? (existing['max_score'] ?? 5).toString()
            : '5');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r8)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.s6, right: AppSpacing.s6, top: AppSpacing.s6,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existing == null ? 'Nueva escala' : 'Editar escala',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.s5),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre (ej. Escala 0–5)'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: AppSpacing.s3),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: minCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Nota mínima'),
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? 'Número inválido' : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: TextFormField(
                    controller: maxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Nota máxima'),
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? 'Número inválido' : null,
                  ),
                ),
              ]),
              const SizedBox(height: AppSpacing.s6),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(ctx, true);
                    }
                  },
                  child: Text(existing == null ? 'Crear' : 'Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    final payload = {
      'name': nameCtrl.text.trim(),
      'min_score': double.parse(minCtrl.text),
      'max_score': double.parse(maxCtrl.text),
    };

    try {
      if (existing == null) {
        await AdminService.instance.createGradingScale(payload);
      } else {
        await AdminService.instance
            .updateGradingScale(existing['id'] as String, payload);
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e, fallback: 'No se pudo guardar la escala. Intenta de nuevo.')), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // ── Set default ─────────────────────────────────────────────────────────

  Future<void> _setDefault(String id) async {
    try {
      await AdminService.instance.setDefaultGradingScale(id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e, fallback: 'No se pudo actualizar la escala predeterminada. Intenta de nuevo.')), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  Future<void> _delete(Map<String, dynamic> scale) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar escala'),
        content:
            Text('¿Eliminar "${scale['name']}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AdminService.instance.deleteGradingScale(scale['id'] as String);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e, fallback: 'No se pudo eliminar la escala. Intenta de nuevo.')), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      restorationId: 'admin_grading_scales_screen',
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Escalas de calificación',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva escala'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: AppSpacing.s3),
                      ElevatedButton(
                          onPressed: _load, child: const Text('Reintentar')),
                    ],
                  ),
                )
              : _scales.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.grading_outlined,
                              size: 64, color: AppColors.textSecondary),
                          const SizedBox(height: AppSpacing.s4),
                          Text('Sin escalas de calificación',
                              style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: AppSpacing.s2),
                          Text('Crea tu primera escala con el botón +',
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: _scales.length,
                        itemBuilder: (_, i) {
                          final scale =
                              _scales[i] as Map<String, dynamic>;
                          final isDefault =
                              scale['is_default'] as bool? ?? false;
                          final min = scale['min_score'];
                          final max = scale['max_score'];

                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.s3),
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.r5),
                              side: isDefault
                                  ? BorderSide(
                                      color: AppColors.primary, width: 1.5)
                                  : BorderSide.none,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.s4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(AppAlpha.a08),
                                      borderRadius: BorderRadius.circular(AppRadius.r4),
                                    ),
                                    child: Icon(Icons.grading_outlined,
                                        color: AppColors.primary),
                                  ),
                                  const SizedBox(width: AppSpacing.s3),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Text(
                                            scale['name'] as String? ?? '',
                                            style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppColors.textPrimary),
                                          ),
                                          if (isDefault) ...[
                                            const SizedBox(width: AppSpacing.s2),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withAlpha(AppAlpha.a08),
                                                borderRadius:
                                                    BorderRadius.circular(AppRadius.r8),
                                              ),
                                              child: Text('predeterminada',
                                                  style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.primary)),
                                            ),
                                          ],
                                        ]),
                                        const SizedBox(height: AppSpacing.s1),
                                        Text(
                                          'Rango: $min – $max',
                                          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert,
                                        color: AppColors.textSecondary),
                                    onSelected: (action) {
                                      if (action == 'edit') {
                                        _showFormDialog(existing: scale);
                                      } else if (action == 'default') {
                                        _setDefault(scale['id'] as String);
                                      } else if (action == 'delete') {
                                        _delete(scale);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                          value: 'edit',
                                          child: ListTile(
                                              leading: Icon(Icons.edit_outlined),
                                              title: Text('Editar'),
                                              contentPadding: EdgeInsets.zero)),
                                      if (!isDefault)
                                        const PopupMenuItem(
                                            value: 'default',
                                            child: ListTile(
                                                leading: Icon(
                                                    Icons.star_outline_rounded),
                                                title:
                                                    Text('Marcar predeterminada'),
                                                contentPadding:
                                                    EdgeInsets.zero)),
                                      if (!isDefault)
                                        PopupMenuItem(
                                            value: 'delete',
                                            child: ListTile(
                                                leading: const Icon(
                                                    Icons.delete_outline,
                                                    color: AppColors.error),
                                                title: Text('Eliminar',
                                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.error)),
                                                contentPadding:
                                                    EdgeInsets.zero)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

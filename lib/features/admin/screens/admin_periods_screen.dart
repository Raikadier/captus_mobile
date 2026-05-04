import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../services/admin_service.dart';

class AdminPeriodsScreen extends StatefulWidget {
  const AdminPeriodsScreen({super.key});

  @override
  State<AdminPeriodsScreen> createState() => _AdminPeriodsScreenState();
}

class _AdminPeriodsScreenState extends State<AdminPeriodsScreen> {
  List<dynamic> _periods = [];
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
      final periods = await AdminService.instance.getPeriods();
      if (mounted) setState(() { _periods = periods; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // ── Create / Edit dialog ────────────────────────────────────────────────

  Future<void> _showFormDialog({Map<String, dynamic>? existing}) async {
    final nameCtrl = TextEditingController(
        text: existing != null ? existing['name'] as String? ?? '' : '');
    DateTime? startDate = existing != null && existing['start_date'] != null
        ? DateTime.tryParse(existing['start_date'] as String)
        : null;
    DateTime? endDate = existing != null && existing['end_date'] != null
        ? DateTime.tryParse(existing['end_date'] as String)
        : null;

    final formKey = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing == null ? 'Nuevo período' : 'Editar período',
                  style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nombre (ej. 2026-I)'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                // Start date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(
                    startDate != null
                        ? 'Inicio: ${startDate!.toLocal().toString().split(' ')[0]}'
                        : 'Fecha de inicio (opcional)',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (d != null) setModalState(() => startDate = d);
                  },
                ),
                // End date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(
                    endDate != null
                        ? 'Fin: ${endDate!.toLocal().toString().split(' ')[0]}'
                        : 'Fecha de fin (opcional)',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (d != null) setModalState(() => endDate = d);
                  },
                ),
                const SizedBox(height: 16),
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
      ),
    );

    if (confirmed != true || !mounted) return;

    final payload = <String, dynamic>{
      'name': nameCtrl.text.trim(),
      if (startDate != null)
        'start_date': startDate!.toIso8601String().split('T')[0],
      if (endDate != null)
        'end_date': endDate!.toIso8601String().split('T')[0],
    };

    try {
      if (existing == null) {
        await AdminService.instance.createPeriod(payload);
      } else {
        await AdminService.instance
            .updatePeriod(existing['id'] as String, payload);
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── Set active ───────────────────────────────────────────────────────────

  Future<void> _setActive(String id) async {
    try {
      await AdminService.instance.setActivePeriod(id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  Future<void> _delete(Map<String, dynamic> period) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar período'),
        content: Text(
            '¿Eliminar "${period['name']}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AdminService.instance.deletePeriod(period['id'] as String);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Períodos académicos',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo período'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _load, child: const Text('Reintentar')),
                    ],
                  ),
                )
              : _periods.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.date_range_outlined,
                              size: 64, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          Text('Sin períodos académicos',
                              style: GoogleFonts.inter(
                                  color: AppColors.textSecondary, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Crea tu primer período con el botón +',
                              style: GoogleFonts.inter(
                                  color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: _periods.length,
                        itemBuilder: (_, i) {
                          final period = _periods[i] as Map<String, dynamic>;
                          final isActive =
                              period['is_active'] as bool? ?? false;
                          final startDate = period['start_date'] as String?;
                          final endDate = period['end_date'] as String?;

                          String dateRange = '';
                          if (startDate != null && endDate != null) {
                            dateRange = '$startDate → $endDate';
                          } else if (startDate != null) {
                            dateRange = 'Desde $startDate';
                          } else if (endDate != null) {
                            dateRange = 'Hasta $endDate';
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isActive
                                  ? BorderSide(
                                      color: Colors.green, width: 1.5)
                                  : BorderSide.none,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.green.withAlpha(25)
                                          : AppColors.primary.withAlpha(20),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.date_range_outlined,
                                        color: isActive
                                            ? Colors.green
                                            : AppColors.primary),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Text(
                                            period['name'] as String? ?? '',
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                                color: AppColors.textPrimary),
                                          ),
                                          if (isActive) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.green
                                                    .withAlpha(25),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text('activo',
                                                  style: GoogleFonts.inter(
                                                      fontSize: 11,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                          ],
                                        ]),
                                        if (dateRange.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            dateRange,
                                            style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert,
                                        color: AppColors.textSecondary),
                                    onSelected: (action) {
                                      if (action == 'edit') {
                                        _showFormDialog(existing: period);
                                      } else if (action == 'activate') {
                                        _setActive(period['id'] as String);
                                      } else if (action == 'delete') {
                                        _delete(period);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                          value: 'edit',
                                          child: ListTile(
                                              leading: Icon(Icons.edit_outlined),
                                              title: Text('Editar'),
                                              contentPadding: EdgeInsets.zero)),
                                      if (!isActive)
                                        const PopupMenuItem(
                                            value: 'activate',
                                            child: ListTile(
                                                leading: Icon(
                                                    Icons.check_circle_outline,
                                                    color: Colors.green),
                                                title: Text('Marcar activo',
                                                    style: TextStyle(
                                                        color: Colors.green)),
                                                contentPadding:
                                                    EdgeInsets.zero)),
                                      const PopupMenuItem(
                                          value: 'delete',
                                          child: ListTile(
                                              leading: Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red),
                                              title: Text('Eliminar',
                                                  style: TextStyle(
                                                      color: Colors.red)),
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

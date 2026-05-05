import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/assignments_provider.dart';
import '../../../core/providers/courses_provider.dart';
import '../../../models/assignment.dart';

class TeacherAssignmentCreateScreen extends ConsumerStatefulWidget {
  const TeacherAssignmentCreateScreen({super.key});

  @override
  ConsumerState<TeacherAssignmentCreateScreen> createState() =>
      _TeacherAssignmentCreateScreenState();
}

class _TeacherAssignmentCreateScreenState
    extends ConsumerState<TeacherAssignmentCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _description = '';
  String? _selectedCourseId;
  DateTime? _startDate;
  DateTime? _dueDate;
  double _maxGrade = 5.0;
  bool _isGroupAssignment = false;

  bool _isLoading = false;

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_dueDate ?? DateTime.now().add(const Duration(days: 7)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un curso')),
      );
      return;
    }
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una fecha límite')),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no autenticado');

      final newAssignment = AssignmentModel(
        id: '', // Se generará
        courseId: _selectedCourseId!,
        teacherId: user.id,
        title: _title,
        description: _description,
        startDate: _startDate,
        dueDate: _dueDate!,
        createdAt: DateTime.now(),
        type: 'Tarea', // Fijo por ahora, se podría agregar selector
        maxGrade: _maxGrade,
        requiresFile: true,
        isGroupAssignment: _isGroupAssignment,
      );

      final notifier = ref.read(teacherAssignmentsProvider.notifier);
      final created = await notifier.createAssignment(newAssignment);

      if (created != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarea creada exitosamente')),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear tarea: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Nueva Asignación',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (courses) {
          // ── Empty state: no courses available ──────────────────────────────
          if (courses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inbox_outlined,
                        size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes cursos disponibles',
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Debes tener al menos un curso asignado para crear tareas.',
                      style:
                          GoogleFonts.inter(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Título de la Tarea'),
                  TextFormField(
                    decoration: _inputDecoration('Ej: Taller de Algoritmos'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Requerido' : null,
                    onSaved: (val) => _title = val ?? '',
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Descripción'),
                  TextFormField(
                    maxLines: 4,
                    decoration: _inputDecoration(
                        'Instrucciones para los estudiantes...'),
                    onSaved: (val) => _description = val ?? '',
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Curso'),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Selecciona un curso'),
                    value: _selectedCourseId,
                    items: courses.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      );
                    }).toList(),
                    validator: (val) =>
                        val == null ? 'Selecciona un curso' : null,
                    onChanged: (val) => setState(() => _selectedCourseId = val),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Fecha Inicio (Opcional)'),
                            InkWell(
                              onTap: () => _pickDate(context, true),
                              child: InputDecorator(
                                decoration: _inputDecoration(''),
                                child: Text(
                                  _startDate != null
                                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                      : 'Seleccionar',
                                  style: GoogleFonts.inter(
                                    color: _startDate != null
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Fecha Límite'),
                            InkWell(
                              onTap: () => _pickDate(context, false),
                              child: InputDecorator(
                                decoration: _inputDecoration(''),
                                child: Text(
                                  _dueDate != null
                                      ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                      : 'Seleccionar',
                                  style: GoogleFonts.inter(
                                    color: _dueDate != null
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Nota Máxima'),
                  TextFormField(
                    initialValue: '5.0',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration('Ej: 5.0 o 100'),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Requerido';
                      if (double.tryParse(val) == null)
                        return 'Debe ser un número';
                      return null;
                    },
                    onSaved: (val) =>
                        _maxGrade = double.tryParse(val ?? '5.0') ?? 5.0,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Tipo de Asignación'),
                  DropdownButtonFormField<bool>(
                    decoration: _inputDecoration('Destinatarios'),
                    value: _isGroupAssignment,
                    items: const [
                      DropdownMenuItem(
                          value: false, child: Text('Para todo el curso')),
                      DropdownMenuItem(
                          value: true, child: Text('Para grupos (automático)')),
                    ],
                    onChanged: (val) => setState(() => _isGroupAssignment = val!),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading || _selectedCourseId == null
                              ? null
                              : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Crear Asignación',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}

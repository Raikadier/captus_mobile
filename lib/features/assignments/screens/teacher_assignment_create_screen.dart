import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/assignments_provider.dart';
import '../../../core/providers/courses_provider.dart';
import '../../../core/providers/course_groups_provider.dart';
import '../../../core/utils/app_errors.dart';
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
  int? _selectedGroupId;
  String? _selectedStudentId;
  DateTime? _startDate;
  DateTime? _dueDate;
  double _maxGrade = 5.0;
  bool _isGroupAssignment = false;

  Uint8List? _attachedFileBytes;
  String? _attachedFileName;

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

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      withData: true,
      type: FileType.any,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _attachedFileBytes = result.files.single.bytes;
        _attachedFileName = result.files.single.name;
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

      final repo = ref.read(assignmentsRepositoryProvider);
      
      String? fileUrl;
      if (_attachedFileBytes != null && _attachedFileName != null) {
        fileUrl = await repo.uploadFile(_attachedFileBytes!, _attachedFileName!);
      }

      final newAssignment = AssignmentModel(
        id: '', 
        courseId: _selectedCourseId!,
        teacherId: user.id,
        title: _title,
        description: _description,
        startDate: _startDate,
        dueDate: _dueDate!,
        createdAt: DateTime.now(),
        type: 'Tarea',
        maxGrade: _maxGrade,
        requiresFile: true,
        isGroupAssignment: _isGroupAssignment || _selectedGroupId != null,
        fileUrl: fileUrl,
      );

      final notifier = ref.read(teacherAssignmentsProvider.notifier);
      final created = await notifier.createAssignment(newAssignment);

      if (created != null) {
        // If it's for a specific group or student, we might need to handle extra logic here
        // or the repository handles it if we pass targets.
        // For now, following the user's instructions.
        
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
          SnackBar(content: Text(friendlyError(e, fallback: 'No se pudo crear la tarea. Intenta de nuevo.'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    
    // Fetch groups and students if a course is selected
    final courseIdInt = int.tryParse(_selectedCourseId ?? '');
    final groupsAsync = courseIdInt != null 
        ? ref.watch(courseGroupsProvider(courseIdInt)) 
        : const AsyncValue.data(<CourseGroup>[]);
        
    final studentsAsync = courseIdInt != null 
        ? ref.watch(courseStudentsProvider(courseIdInt)) 
        : const AsyncValue.data(<EnrolledStudent>[]);

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
        error: (err, _) => Center(child: Text(friendlyError(err, fallback: 'No se pudieron cargar los cursos. Intenta de nuevo.'))),
        data: (courses) {
          if (courses.isEmpty) {
            return _buildEmptyCoursesState();
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
                    onChanged: (val) {
                      setState(() {
                        _selectedCourseId = val;
                        _selectedGroupId = null;
                        _selectedStudentId = null;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  if (_selectedCourseId != null) ...[
                    _buildSectionTitle('Asignar a (Opcional)'),
                    Row(
                      children: [
                        Expanded(
                          child: groupsAsync.when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, __) => const Text('Error grupos'),
                            data: (groups) => DropdownButtonFormField<int>(
                              decoration: _inputDecoration('Grupo'),
                              value: _selectedGroupId,
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Todo el curso')),
                                ...groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))),
                              ],
                              onChanged: (val) => setState(() {
                                _selectedGroupId = val;
                                if (val != null) _selectedStudentId = null;
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: studentsAsync.when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, __) => const Text('Error estudiantes'),
                            data: (students) => DropdownButtonFormField<String>(
                              decoration: _inputDecoration('Estudiante'),
                              value: _selectedStudentId,
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Todos')),
                                ...students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                              ],
                              onChanged: (val) => setState(() {
                                _selectedStudentId = val;
                                if (val != null) _selectedGroupId = null;
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Fecha Inicio'),
                            InkWell(
                              onTap: () => _pickDate(context, true),
                              child: InputDecorator(
                                decoration: _inputDecoration(''),
                                child: Text(
                                  _startDate != null
                                      ? DateFormat('dd/MM/yyyy').format(_startDate!)
                                      : 'Hoy',
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
                                      ? DateFormat('dd/MM/yyyy').format(_dueDate!)
                                      : 'Seleccionar',
                                  style: TextStyle(
                                    color: _dueDate != null
                                        ? AppColors.textPrimary
                                        : AppColors.error,
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
                  
                  _buildSectionTitle('Adjuntar Archivo (PDF, Word, etc.)'),
                  InkWell(
                    onTap: _pickFile,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _attachedFileName != null ? AppColors.primary : AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _attachedFileName != null ? Icons.file_present_rounded : Icons.attach_file_rounded,
                            color: _attachedFileName != null ? AppColors.primary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _attachedFileName ?? 'Ningún archivo seleccionado',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: _attachedFileName != null ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_attachedFileName != null)
                            IconButton(
                              onPressed: () => setState(() {
                                _attachedFileBytes = null;
                                _attachedFileName = null;
                              }),
                              icon: const Icon(Icons.close_rounded, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  _buildSectionTitle('Nota Máxima'),
                  TextFormField(
                    initialValue: '5.0',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration('Ej: 5.0 o 100'),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Requerido';
                      if (double.tryParse(val) == null) return 'Debe ser un número';
                      return null;
                    },
                    onSaved: (val) => _maxGrade = double.tryParse(val ?? '5.0') ?? 5.0,
                  ),
                  
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading || _selectedCourseId == null ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Crear Asignación',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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

  Widget _buildEmptyCoursesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No tienes cursos disponibles',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Debes tener al menos un curso asignado para crear tareas.',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorStyle: GoogleFonts.inter(fontSize: 11),
    );
  }
}

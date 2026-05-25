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


  Uint8List? _attachedFileBytes;
  String? _attachedFileName;

  bool _isLoading = false;
  String _assignTo = 'course'; // 'course', 'group', 'student'

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
    debugPrint('CREATE_ASSIGNMENT_BUTTON_PRESSED');
    debugPrint('selectedCourseId: $_selectedCourseId');
    debugPrint('selectedGroupId: $_selectedGroupId');
    debugPrint('selectedStudentId: $_selectedStudentId');
    
    final isValid = _formKey.currentState!.validate();
    debugPrint('FORM_VALID: $isValid');

    _formKey.currentState!.save();

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa los campos del formulario')),
      );
      return;
    }
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un curso')),
      );
      return;
    }
    if (_title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un título')),
      );
      return;
    }
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha límite')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no autenticado');

      final repo = ref.read(assignmentsRepositoryProvider);
      
      String? fileUrl;
      if (_attachedFileBytes != null && _attachedFileName != null) {
        fileUrl = await repo.uploadFile(_attachedFileBytes!, _attachedFileName!);
      }

      // El assignment_type debe representar el tipo académico, no el destinatario.
      // Por defecto usar 'tarea'.
      const String assignmentType = 'tarea';
      final int? courseGroupId = _selectedGroupId;

      debugPrint('assignmentType: $assignmentType');
      debugPrint('courseGroupId: $courseGroupId');

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
        isGroupAssignment: courseGroupId != null,
        fileUrl: fileUrl,
        courseGroupId: courseGroupId,
        assignmentType: assignmentType,
        priority: 'medio',
      );

      final notifier = ref.read(teacherAssignmentsProvider.notifier);
      final created = await notifier.createAssignment(newAssignment);

      if (created != null) {
        // Si es para grupo o estudiante, crear el registro en submissions si corresponde
        if (_selectedGroupId != null) {
          await repo.assignToGroup(created.id, _selectedGroupId!.toString());
        } else if (_selectedStudentId != null) {
          await repo.assignToStudent(created.id, _selectedStudentId!);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Asignación creada correctamente')),
          );
          context.go('/teacher/assignments');
        }
      } else {
         // El notifier ya captura el error y lo pone en el state, 
         // pero aquí lanzamos una excepción si created es null para entrar al catch
         throw Exception('Error al crear asignación');
      }
    } catch (e) {
      debugPrint('Error completo en _submit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
        error: (err, _) => Center(child: Text('Error: $err')),
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
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                    iconEnabledColor: Colors.black,
                    value: _selectedCourseId,
                    items: courses.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.name, style: const TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                    selectedItemBuilder: (context) {
                      return courses.map((c) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            c.name,
                            style: const TextStyle(color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList();
                    },
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
                    _buildSectionTitle('Asignar a'),
                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration('Destinatario'),
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black, fontSize: 13),
                      iconEnabledColor: Colors.black,
                      value: _assignTo,
                      items: const [
                        DropdownMenuItem(value: 'course', child: Text('Todo el curso', style: TextStyle(color: Colors.black))),
                        DropdownMenuItem(value: 'group', child: Text('Un grupo específico', style: TextStyle(color: Colors.black))),
                        DropdownMenuItem(value: 'student', child: Text('Un estudiante específico', style: TextStyle(color: Colors.black))),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _assignTo = val!;
                          _selectedGroupId = null;
                          _selectedStudentId = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    if (_assignTo == 'group')
                      groupsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('Error al cargar grupos'),
                        data: (groups) => DropdownButtonFormField<int>(
                          decoration: _inputDecoration('Selecciona el grupo'),
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.black, fontSize: 13),
                          iconEnabledColor: Colors.black,
                          value: _selectedGroupId,
                          items: groups.map((g) => DropdownMenuItem<int>(
                            value: g.id, 
                            child: Text(g.name, style: const TextStyle(color: Colors.black))
                          )).toList(),
                          validator: (val) => _assignTo == 'group' && val == null ? 'Selecciona un grupo' : null,
                          onChanged: (val) => setState(() => _selectedGroupId = val),
                        ),
                      ),

                    if (_assignTo == 'student')
                      studentsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('Error al cargar estudiantes'),
                        data: (students) => DropdownButtonFormField<String>(
                          decoration: _inputDecoration('Selecciona el estudiante'),
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.black, fontSize: 13),
                          iconEnabledColor: Colors.black,
                          value: _selectedStudentId,
                          items: students.map((s) => DropdownMenuItem<String>(
                            value: s.id, 
                            child: Text(s.name, style: const TextStyle(color: Colors.black))
                          )).toList(),
                          validator: (val) => _assignTo == 'student' && val == null ? 'Selecciona un estudiante' : null,
                          onChanged: (val) => setState(() => _selectedStudentId = val),
                        ),
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
                      onPressed: _isLoading ? null : _submit,
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

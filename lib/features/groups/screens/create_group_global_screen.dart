import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/courses_provider.dart';
import '../../../core/providers/course_groups_provider.dart';

class CreateGroupGlobalScreen extends ConsumerStatefulWidget {
  const CreateGroupGlobalScreen({super.key});

  @override
  ConsumerState<CreateGroupGlobalScreen> createState() => _CreateGroupGlobalScreenState();
}

class _CreateGroupGlobalScreenState extends ConsumerState<CreateGroupGlobalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  String? _selectedCourseId;
  final Set<String> _selectedStudentIds = <String>{};
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    debugPrint('CREATE_GROUP_BUTTON_PRESSED');
    final isValid = _formKey.currentState!.validate();
    debugPrint('CREATE_GROUP_FORM_VALID: $isValid');
    
    if (!isValid || _saving) return;
    
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un curso')),
      );
      return;
    }

    final courseIdInt = int.parse(_selectedCourseId!);
    final payload = {
      'courseId': courseIdInt,
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'memberIds': _selectedStudentIds.toList(),
    };
    debugPrint('CREATE_GROUP_PAYLOAD: $payload');
    debugPrint('SELECTED_COURSE_ID: $_selectedCourseId');
    debugPrint('SELECTED_STUDENTS: ${_selectedStudentIds.toList()}');

    setState(() => _saving = true);
    try {
      await ref.read(courseGroupsNotifierProvider.notifier).createGroup(
        courseId: courseIdInt,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        memberIds: _selectedStudentIds.toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grupo creado correctamente')),
      );
      context.go('/groups');
    } catch (e) {
      debugPrint('Error al crear grupo: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo crear el grupo: ${e.toString()}', style: GoogleFonts.inter()),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Crear Nuevo Grupo',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error al cargar cursos', style: TextStyle(color: Colors.white))),
        data: (courses) {
          if (courses.isEmpty) {
            return const Center(child: Text('No tienes cursos disponibles', style: TextStyle(color: Colors.white)));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Curso Requerido', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Selecciona un curso'),
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                    iconEnabledColor: Colors.black,
                    value: _selectedCourseId,
                    items: courses.map((c) => DropdownMenuItem<String>(
                      value: c.id,
                      child: Text(
                        c.name, 
                        style: const TextStyle(color: Colors.black),
                      ),
                    )).toList(),
                    selectedItemBuilder: (context) {
                      return courses.map((c) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          c.name,
                          style: const TextStyle(color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )).toList();
                    },
                    validator: (val) => val == null ? 'Requerido' : null,
                    onChanged: (val) {
                      debugPrint('SELECTED_COURSE_ID_CHANGED: $val');
                      setState(() {
                        _selectedCourseId = val;
                        _selectedStudentIds.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('Nombre del Grupo', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _inputDecoration('Ej. Equipo Alpha'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 20),
                  Text('Descripción (Opcional)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    maxLines: 3,
                    decoration: _inputDecoration('Describe el propósito del grupo...'),
                  ),
                  const SizedBox(height: 20),
                  Text('Estudiantes (Opcional)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  if (_selectedCourseId == null)
                    Text('Selecciona un curso primero para ver estudiantes', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary))
                  else
                    ref.watch(courseStudentsProvider(int.parse(_selectedCourseId!))).when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
                      data: (students) {
                        if (students.isEmpty) {
                          return Text('Sin estudiantes matriculados en este curso', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary));
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final s = students[index];
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(s.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                              subtitle: Text(s.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                              value: _selectedStudentIds.contains(s.id),
                              activeColor: AppColors.primary,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) _selectedStudentIds.add(s.id);
                                  else _selectedStudentIds.remove(s.id);
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _createGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _saving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Crear Grupo', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

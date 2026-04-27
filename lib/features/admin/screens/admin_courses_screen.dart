import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../services/admin_service.dart';

class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});

  @override
  State<AdminCoursesScreen> createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  List<dynamic> _courses = [];
  List<dynamic> _teachers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        AdminService.instance.getCourses(),
        AdminService.instance.getMembers(role: 'teacher'),
      ]);
      if (mounted) {
        setState(() {
          _courses  = results[0];
          _teachers = results[1];
          _loading  = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showCreateDialog() async {
    String name = '';
    String desc = '';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nuevo curso',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nombre del curso',
                hintText: 'Ej: Matemáticas 10°',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => name = v,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => desc = v,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () async {
                  if (name.isEmpty) return;
                  Navigator.pop(ctx);
                  try {
                    final data = await AdminService.instance
                        .createCourse({'name': name, 'description': desc});
                    if (mounted) {
                      setState(() => _courses.insert(0, data));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Curso creado')));
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: Text('Crear',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAssignTeacher(Map<String, dynamic> course) async {
    String? teacherId;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Asignar docente',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(course['name'] ?? '',
                style: GoogleFonts.inter(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: teacherId,
                decoration: const InputDecoration(
                  labelText: 'Docente',
                  border: OutlineInputBorder(),
                ),
                items: _teachers.map<DropdownMenuItem<String>>((t) {
                  final tMap = t as Map<String, dynamic>;
                  return DropdownMenuItem(
                    value: tMap['id'].toString(),
                    child: Text(tMap['name'] ?? tMap['email'] ?? ''),
                  );
                }).toList(),
                onChanged: (v) => setModal(() => teacherId = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: teacherId == null ? null : () async {
                    Navigator.pop(ctx);
                    try {
                      await AdminService.instance
                          .assignTeacher(course['id'].toString(), teacherId!);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Docente asignado')));
                        _load();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  child: Text('Confirmar',
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Cursos',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : _courses.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.book_outlined, size: 48, color: AppColors.textDisabled),
                  const SizedBox(height: 12),
                  Text('No hay cursos',
                    style: GoogleFonts.inter(color: AppColors.textSecondary)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _courses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final c = _courses[i] as Map<String, dynamic>;
                  final hasTeacher = c['teacher_id'] != null;
                  final enrollments = c['enrollments_count'] ?? 0;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(c['name'] ?? '',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                )),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('$enrollments alumnos',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasTeacher
                            ? 'Docente: ${c['teacher_name'] ?? 'Asignado'}'
                            : 'Sin docente asignado',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: hasTeacher
                              ? AppColors.textSecondary
                              : AppColors.warning,
                            fontStyle: hasTeacher ? FontStyle.normal : FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showAssignTeacher(c),
                                icon: const Icon(Icons.person_add_rounded, size: 16),
                                label: Text('Docente',
                                  style: GoogleFonts.inter(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

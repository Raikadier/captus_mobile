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
  List<dynamic> _courses  = [];
  List<dynamic> _teachers = [];
  List<dynamic> _periods  = [];
  List<dynamic> _scales   = [];
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
        AdminService.instance.getPeriods(),
        AdminService.instance.getGradingScales(),
      ]);
      if (mounted) {
        setState(() {
          _courses  = results[0];
          _teachers = results[1];
          _periods  = results[2];
          _scales   = results[3];
          _loading  = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Create / Edit course ────────────────────────────────────────────────

  Future<void> _showCourseForm({Map<String, dynamic>? existing}) async {
    final nameCtrl = TextEditingController(
        text: existing != null ? existing['name'] as String? ?? '' : '');
    final descCtrl = TextEditingController(
        text: existing != null ? existing['description'] as String? ?? '' : '');
    String? teacherId  = existing?['teacher_id'] as String?;
    String? periodId   = existing?['period']?['id'] as String?;
    String? scaleId    = existing?['grading_scale_id'] as String?;
    final formKey = GlobalKey<FormState>();
    final isEdit = existing != null;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEdit ? 'Editar curso' : 'Nuevo curso',
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Nombre del curso',
                        hintText: 'Ej: Matemáticas 10°',
                        border: OutlineInputBorder()),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        border: OutlineInputBorder()),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  if (_teachers.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: teacherId,
                      decoration: const InputDecoration(
                          labelText: 'Docente (opcional)',
                          border: OutlineInputBorder()),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('Sin asignar')),
                        ..._teachers.map((t) {
                          final m = t as Map<String, dynamic>;
                          return DropdownMenuItem(
                              value: m['id'] as String,
                              child: Text(m['name'] as String? ?? m['email'] as String? ?? ''));
                        }),
                      ],
                      onChanged: (v) => setModal(() => teacherId = v),
                    ),
                  const SizedBox(height: 12),
                  if (_periods.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: periodId,
                      decoration: const InputDecoration(
                          labelText: 'Período académico (opcional)',
                          border: OutlineInputBorder()),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('Sin período')),
                        ..._periods.map((p) {
                          final m = p as Map<String, dynamic>;
                          return DropdownMenuItem(
                              value: m['id'] as String,
                              child: Text(m['name'] as String? ?? ''));
                        }),
                      ],
                      onChanged: (v) => setModal(() => periodId = v),
                    ),
                  const SizedBox(height: 12),
                  if (_scales.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: scaleId,
                      decoration: const InputDecoration(
                          labelText: 'Escala de calificación (opcional)',
                          border: OutlineInputBorder()),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('Sin escala')),
                        ..._scales.map((s) {
                          final m = s as Map<String, dynamic>;
                          return DropdownMenuItem(
                              value: m['id'] as String,
                              child: Text(m['name'] as String? ?? ''));
                        }),
                      ],
                      onChanged: (v) => setModal(() => scaleId = v),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(ctx, true);
                        }
                      },
                      child: Text(isEdit ? 'Guardar cambios' : 'Crear curso'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    final payload = {
      'name': nameCtrl.text.trim(),
      'description': descCtrl.text.trim(),
      if (teacherId != null) 'teacher_id': teacherId,
      'period_id': periodId,
      'grading_scale_id': scaleId,
    };

    try {
      if (isEdit) {
        await AdminService.instance.updateCourse(existing['id'].toString(), payload);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Curso actualizado')));
      } else {
        await AdminService.instance.createCourse(payload);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Curso creado')));
      }
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // ── Students bottom sheet ────────────────────────────────────────────────

  Future<void> _showStudents(Map<String, dynamic> course) async {
    final courseId = course['id'].toString();
    List<dynamic> students = [];
    bool loading = true;
    String? err;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          if (loading && students.isEmpty && err == null) {
            AdminService.instance.getCourseStudents(courseId).then((data) {
              setModal(() { students = data; loading = false; });
            }).catchError((e) {
              setModal(() { err = e.toString(); loading = false; });
            });
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.65,
            maxChildSize: 0.92,
            minChildSize: 0.4,
            expand: false,
            builder: (_, scrollCtrl) => Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estudiantes inscritos',
                            style: GoogleFonts.inter(
                                fontSize: 18, fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        Text(course['name'] as String? ?? '',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add_rounded,
                        color: AppColors.primary),
                    tooltip: 'Inscribir estudiantes',
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showBulkEnroll(course);
                    },
                  ),
                ]),
              ),
              const Divider(height: 20),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : err != null
                        ? Center(child: Text(err!))
                        : students.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.school_outlined,
                                        size: 48, color: AppColors.textSecondary),
                                    const SizedBox(height: 12),
                                    Text('Sin estudiantes inscritos',
                                        style: GoogleFonts.inter(
                                            color: AppColors.textSecondary)),
                                    const SizedBox(height: 12),
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _showBulkEnroll(course);
                                      },
                                      icon: const Icon(Icons.person_add_outlined),
                                      label: const Text('Inscribir estudiantes'),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                controller: scrollCtrl,
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                itemCount: students.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (_, i) {
                                  final s = students[i] as Map<String, dynamic>;
                                  final name = s['name'] as String? ??
                                      s['email'] as String? ?? 'Sin nombre';
                                  final email = s['email'] as String? ?? '';
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 4),
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.primary.withAlpha(25),
                                      child: Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    title: Text(name,
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14)),
                                    subtitle: email.isNotEmpty
                                        ? Text(email,
                                            style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: AppColors.textSecondary))
                                        : null,
                                    trailing: IconButton(
                                      icon: const Icon(Icons.person_remove_outlined,
                                          color: Colors.red, size: 20),
                                      tooltip: 'Desinscribir',
                                      onPressed: () async {
                                        final ok = await showDialog<bool>(
                                          context: ctx,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Desinscribir'),
                                            content: Text('¿Quitar a $name de este curso?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('Cancelar')),
                                              TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  style: TextButton.styleFrom(
                                                      foregroundColor: Colors.red),
                                                  child: const Text('Quitar')),
                                            ],
                                          ),
                                        );
                                        if (ok != true) return;
                                        try {
                                          await AdminService.instance
                                              .unenrollStudent(courseId, s['id'] as String);
                                          setModal(() => students.removeAt(i));
                                          if (mounted) _load();
                                        } catch (e) {
                                          if (mounted) ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text('Error: $e'),
                                                  backgroundColor: Colors.red));
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
              ),
            ]),
          );
        },
      ),
    );
  }

  // ── Bulk enroll ──────────────────────────────────────────────────────────

  Future<void> _showBulkEnroll(Map<String, dynamic> course) async {
    final ctrl = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inscribir estudiantes',
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text(course['name'] as String? ?? '',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              maxLines: 5,
              decoration: const InputDecoration(
                  labelText: 'Emails de estudiantes',
                  hintText: 'uno@ejemplo.com\ndos@ejemplo.com',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true),
            ),
            const SizedBox(height: 8),
            Text('Un email por línea. Solo estudiantes ya registrados en Captus.',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Inscribir'),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    final emails = ctrl.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (emails.isEmpty) return;

    try {
      final result = await AdminService.instance
          .bulkEnroll(course['id'].toString(), emails);
      final enrolled = (result['enrolled'] as List?)?.length ?? 0;
      final skipped  = (result['skipped']  as List?)?.length ?? 0;
      final notFound = (result['notFound'] as List?)?.length ?? 0;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Inscritos: $enrolled · Omitidos: $skipped · No encontrados: $notFound'),
          duration: const Duration(seconds: 4),
        ));
        _load();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // ── Broadcast notification ───────────────────────────────────────────────

  Future<void> _showBroadcast() async {
    final titleCtrl = TextEditingController();
    final bodyCtrl  = TextEditingController();
    String? selectedRole;
    final formKey = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notificación institucional',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('Envía un mensaje a los miembros de la institución',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 18),
                DropdownButtonFormField<String?>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                      labelText: 'Destinatarios',
                      border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Todos los miembros')),
                    DropdownMenuItem(value: 'student', child: Text('Solo estudiantes')),
                    DropdownMenuItem(value: 'teacher', child: Text('Solo docentes')),
                  ],
                  onChanged: (v) => setModal(() => selectedRole = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Título', border: OutlineInputBorder()),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: bodyCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Mensaje (opcional)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Enviar notificación'),
                    onPressed: () {
                      if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final res = await AdminService.instance.broadcastNotification(
        title: titleCtrl.text.trim(),
        body: bodyCtrl.text.trim(),
        role: selectedRole,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] as String? ?? 'Enviado')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Cursos',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign_outlined, color: AppColors.primary),
            tooltip: 'Notificación institucional',
            onPressed: _showBroadcast,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
            tooltip: 'Nuevo curso',
            onPressed: () => _showCourseForm(),
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
                      const Icon(Icons.book_outlined,
                          size: 56, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text('No hay cursos',
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Crea el primero con el botón +',
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary, fontSize: 13)),
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
                      final periodName = c['period']?['name'] as String?;

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
                            Row(children: [
                              Expanded(
                                child: Text(c['name'] as String? ?? '',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: AppColors.textPrimary)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('$enrollments alumnos',
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 4),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert,
                                    color: AppColors.textSecondary, size: 20),
                                onSelected: (action) {
                                  if (action == 'edit') _showCourseForm(existing: c);
                                  if (action == 'students') _showStudents(c);
                                  if (action == 'enroll') _showBulkEnroll(c);
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                          leading: Icon(Icons.edit_outlined),
                                          title: Text('Editar curso'),
                                          contentPadding: EdgeInsets.zero)),
                                  PopupMenuItem(
                                      value: 'students',
                                      child: ListTile(
                                          leading: Icon(Icons.people_outlined),
                                          title: Text('Ver estudiantes'),
                                          contentPadding: EdgeInsets.zero)),
                                  PopupMenuItem(
                                      value: 'enroll',
                                      child: ListTile(
                                          leading: Icon(Icons.person_add_outlined),
                                          title: Text('Inscribir estudiantes'),
                                          contentPadding: EdgeInsets.zero)),
                                ],
                              ),
                            ]),
                            const SizedBox(height: 6),
                            Row(children: [
                              Icon(
                                hasTeacher
                                    ? Icons.person_rounded
                                    : Icons.person_off_outlined,
                                size: 14,
                                color: hasTeacher
                                    ? AppColors.textSecondary
                                    : AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hasTeacher
                                    ? c['teacher_name'] as String? ?? 'Docente asignado'
                                    : 'Sin docente asignado',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: hasTeacher
                                        ? AppColors.textSecondary
                                        : AppColors.warning),
                              ),
                            ]),
                            if (periodName != null) ...[
                              const SizedBox(height: 4),
                              Row(children: [
                                const Icon(Icons.date_range_outlined,
                                    size: 13, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(periodName,
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                              ]),
                            ],
                            const SizedBox(height: 10),
                            Row(children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showStudents(c),
                                  icon: const Icon(Icons.people_outlined, size: 15),
                                  label: Text('Estudiantes ($enrollments)',
                                      style: GoogleFonts.inter(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary),
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showCourseForm(existing: c),
                                  icon: const Icon(Icons.edit_outlined, size: 15),
                                  label: Text('Editar',
                                      style: GoogleFonts.inter(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textSecondary,
                                    side: const BorderSide(color: AppColors.border),
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

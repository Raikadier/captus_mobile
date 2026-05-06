import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/course_groups_provider.dart';

class CourseGroupsTab extends ConsumerWidget {
  final int courseId;
  final String courseTitle;

  const CourseGroupsTab({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(courseGroupsProvider(courseId));
    final unassignedAsync =
        ref.watch(unassignedCourseStudentsProvider(courseId));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () =>
                context.push('/teacher/courses/$courseId/groups/new'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.add),
            label: Text(
              'Crear Nuevo Grupo',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 16),
        groupsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _ErrorBox(
            message: 'No se pudieron cargar los grupos',
            onRetry: () => ref.invalidate(courseGroupsProvider(courseId)),
          ),
          data: (groups) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GRUPOS DEL CURSO (${groups.length})',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              if (groups.isEmpty)
                _EmptyInfo(text: 'Aún no hay grupos creados')
              else
                ...groups.map(
                  (group) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _GroupTile(
                      group: group,
                      onTap: () => context.push(
                        '/teacher/courses/$courseId/groups/${group.id}',
                        extra: {'courseTitle': courseTitle},
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'SIN GRUPO ASIGNADO',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        unassignedAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) =>
              const _EmptyInfo(text: 'No se pudo cargar la lista'),
          data: (students) {
            if (students.isEmpty) {
              return const _EmptyInfo(
                  text: 'Todos los estudiantes tienen grupo');
            }
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border.withOpacity(0.6)),
              ),
              child: Column(
                children: students
                    .map(
                      (student) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.courseColor(
                            student.id.hashCode.abs() % 10,
                          ),
                          child: Text(
                            student.name.isNotEmpty
                                ? student.name[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(
                          student.name,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          student.email.isEmpty ? 'Sin correo' : student.email,
                          style:
                              GoogleFonts.inter(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class CreateCourseGroupScreen extends ConsumerStatefulWidget {
  final int courseId;

  const CreateCourseGroupScreen({super.key, required this.courseId});

  @override
  ConsumerState<CreateCourseGroupScreen> createState() =>
      _CreateCourseGroupScreenState();
}

class _CreateCourseGroupScreenState
    extends ConsumerState<CreateCourseGroupScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final Set<String> _selectedStudentIds = <String>{};
  int _step = 0;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (_nameCtrl.text.trim().isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final groupId =
          await ref.read(courseGroupsNotifierProvider.notifier).createGroup(
                courseId: widget.courseId,
                name: _nameCtrl.text,
                description: _descCtrl.text,
                memberIds: _selectedStudentIds.toList(),
              );

      if (!mounted) return;
      context.go('/teacher/courses/${widget.courseId}/groups/$groupId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('No se pudo crear el grupo: $e', style: GoogleFonts.inter()),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(courseStudentsProvider(widget.courseId));
    final canContinue = _nameCtrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        title: Text(
          'Crear Nuevo Grupo',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(26),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _step == 0 ? Colors.white : Colors.white70,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _step == 1 ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _step == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nombre del Grupo',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Ej: Equipo Alpha, Los Programadores...',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Text('Descripción (opcional)',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Notas del grupo...',
                      ),
                    ),
                    const SizedBox(height: 18),
                    _GroupPreviewCard(name: _nameCtrl.text.trim()),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: canContinue
                            ? () => setState(() => _step = 1)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                        ),
                        child: Text(
                          'Continuar',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selecciona miembros',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: studentsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const _EmptyInfo(
                            text: 'No se pudieron cargar estudiantes'),
                        data: (students) {
                          if (students.isEmpty) {
                            return const _EmptyInfo(
                              text:
                                  'No hay estudiantes inscritos en este curso',
                            );
                          }
                          return ListView.separated(
                            itemCount: students.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final s = students[index];
                              final selected =
                                  _selectedStudentIds.contains(s.id);
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.border.withOpacity(0.6),
                                  ),
                                ),
                                child: CheckboxListTile(
                                  value: selected,
                                  activeColor: AppColors.primary,
                                  onChanged: (_) {
                                    setState(() {
                                      if (selected) {
                                        _selectedStudentIds.remove(s.id);
                                      } else {
                                        _selectedStudentIds.add(s.id);
                                      }
                                    });
                                  },
                                  title: Text(
                                    s.name,
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    s.email.isEmpty ? 'Sin correo' : s.email,
                                    style: GoogleFonts.inter(
                                        color: AppColors.textSecondary),
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _step = 0),
                            child: Text('Atrás', style: GoogleFonts.inter()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saving ? null : _createGroup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.black,
                            ),
                            child: Text(
                              _saving ? 'Creando...' : 'Crear grupo',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class GroupDetailTeacherScreen extends ConsumerWidget {
  final int courseId;
  final int groupId;

  const GroupDetailTeacherScreen({
    super.key,
    required this.courseId,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersProvider(groupId));
    final assignmentsAsync = ref.watch(groupAssignmentsProvider(groupId));
    final groupsAsync = ref.watch(courseGroupsProvider(courseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        title: groupsAsync.when(
          loading: () => const Text('Grupo'),
          error: (_, __) => const Text('Grupo'),
          data: (groups) {
            CourseGroup? group;
            for (final item in groups) {
              if (item.id == groupId) {
                group = item;
                break;
              }
            }
            return Text(
              group?.name ?? 'Grupo',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(
              '/teacher/courses/$courseId/groups/$groupId/admin',
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          membersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                const _EmptyInfo(text: 'No se pudieron cargar miembros'),
            data: (members) => Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border.withOpacity(0.6)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Text(
                          'Miembros',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${members.length}',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  if (members.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: _EmptyInfo(text: 'Sin miembros todavía'),
                    )
                  else
                    ...members.map(
                      (m) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.courseColor(
                            m.studentId.hashCode.abs() % 10,
                          ),
                          child: Text(
                            m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(
                          m.name,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          m.email.isEmpty ? 'Sin correo' : m.email,
                          style:
                              GoogleFonts.inter(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          assignmentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                const _EmptyInfo(text: 'No se pudieron cargar tareas'),
            data: (assignments) => _GroupAssignmentsCard(
              assignments: assignments,
              onAssign: () => _showAssignTaskSheet(
                context: context,
                ref: ref,
                courseId: courseId,
                groupId: groupId,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GroupAdminTeacherScreen extends ConsumerWidget {
  final int courseId;
  final int groupId;

  const GroupAdminTeacherScreen({
    super.key,
    required this.courseId,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersProvider(groupId));
    final enrolledAsync = ref.watch(courseStudentsProvider(courseId));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.orange.shade700,
          foregroundColor: Colors.white,
          title: Text(
            'Administrar Grupo',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.82),
            labelStyle:
                GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle:
                GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [
              Tab(text: 'General'),
              Tab(text: 'Miembros'),
              Tab(text: 'Tareas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _GeneralAdminTab(
              courseId: courseId,
              groupId: groupId,
            ),
            membersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const _EmptyInfo(text: 'No se pudo cargar miembros'),
              data: (members) => enrolledAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const _EmptyInfo(text: 'No se pudo cargar estudiantes'),
                data: (enrolled) => _MembersAdminTab(
                  courseId: courseId,
                  groupId: groupId,
                  currentMembers: members,
                  enrolledStudents: enrolled,
                ),
              ),
            ),
            _TasksAdminTab(courseId: courseId, groupId: groupId),
          ],
        ),
      ),
    );
  }
}

class _GeneralAdminTab extends ConsumerWidget {
  final int courseId;
  final int groupId;
  const _GeneralAdminTab({required this.courseId, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersProvider(groupId));
    final assignmentsAsync = ref.watch(groupAssignmentsProvider(groupId));

    return assignmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const _EmptyInfo(text: 'No se pudo cargar información'),
      data: (assignments) => membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const _EmptyInfo(text: 'No se pudo cargar informacion'),
        data: (members) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                  child: _InfoCounter(
                      title: 'Miembros', value: '${members.length}')),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoCounter(
                  title: 'Tareas',
                  value: '${assignments.length}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoCounter(
                  title: 'Pendiente',
                  value:
                      '${assignments.where((task) => !task.graded).length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Acciones Rápidas',
            style: GoogleFonts.inter(
                fontSize: 24 * 0.75, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.65,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _AdminActionCard(
                icon: Icons.post_add_outlined,
                label: 'Asignar Tarea',
                color: AppColors.primary,
                onTap: () => _showAssignTaskSheet(
                  context: context,
                  ref: ref,
                  courseId: courseId,
                  groupId: groupId,
                ),
              ),
              _AdminActionCard(
                icon: Icons.person_add_alt_1_outlined,
                label: 'Agregar Miembro',
                color: Colors.orange,
                onTap: () => DefaultTabController.of(context).animateTo(1),
              ),
              _AdminActionCard(
                icon: Icons.calendar_month_outlined,
                label: 'Programar',
                color: Colors.deepPurple,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Próximamente')),
                ),
              ),
              _AdminActionCard(
                icon: Icons.delete_outline,
                label: 'Eliminar',
                color: Colors.red,
                onTap: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Eliminar grupo'),
                      content: const Text(
                        'Esta acción quitará el grupo y sus miembros. ¿Continuar?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                  if (shouldDelete != true) return;
                  await ref
                      .read(courseGroupsNotifierProvider.notifier)
                      .deleteGroup(
                        courseId: courseId,
                        groupId: groupId,
                      );
                  if (!context.mounted) return;
                  context.go('/teacher/courses/$courseId');
                },
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class _MembersAdminTab extends ConsumerWidget {
  final int courseId;
  final int groupId;
  final List<GroupMember> currentMembers;
  final List<EnrolledStudent> enrolledStudents;

  const _MembersAdminTab({
    required this.courseId,
    required this.groupId,
    required this.currentMembers,
    required this.enrolledStudents,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberIds = currentMembers.map((e) => e.studentId).toSet();
    final addable =
        enrolledStudents.where((s) => !memberIds.contains(s.id)).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Miembros Actuales',
          style: GoogleFonts.inter(
              fontSize: 28 * 0.75, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withOpacity(0.6)),
          ),
          child: currentMembers.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: _EmptyInfo(text: 'Sin miembros en el grupo'),
                )
              : Column(
                  children: currentMembers
                      .map(
                        (member) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.courseColor(
                              member.studentId.hashCode.abs() % 10,
                            ),
                            child: Text(
                              member.name.isNotEmpty
                                  ? member.name[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          title: Text(
                            member.name,
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            member.email.isEmpty ? 'Sin correo' : member.email,
                            style: GoogleFonts.inter(
                                color: AppColors.textSecondary),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () async {
                              await ref
                                  .read(courseGroupsNotifierProvider.notifier)
                                  .removeMember(
                                    courseId: courseId,
                                    groupId: groupId,
                                    studentId: member.studentId,
                                  );
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        Text(
          'Agregar Miembros',
          style: GoogleFonts.inter(
              fontSize: 28 * 0.75, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withOpacity(0.6)),
          ),
          child: addable.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: _EmptyInfo(text: 'No hay estudiantes disponibles'),
                )
              : Column(
                  children: addable
                      .map(
                        (student) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.courseColor(
                              student.id.hashCode.abs() % 10,
                            ),
                            child: Text(
                              student.name.isNotEmpty
                                  ? student.name[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          title: Text(
                            student.name,
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            student.email.isEmpty
                                ? 'Sin correo'
                                : student.email,
                            style: GoogleFonts.inter(
                                color: AppColors.textSecondary),
                          ),
                          trailing: OutlinedButton.icon(
                            onPressed: () async {
                              await ref
                                  .read(courseGroupsNotifierProvider.notifier)
                                  .addMember(
                                    courseId: courseId,
                                    groupId: groupId,
                                    studentId: student.id,
                                  );
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Agregar'),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class _TasksAdminTab extends ConsumerWidget {
  final int courseId;
  final int groupId;

  const _TasksAdminTab({required this.courseId, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(groupAssignmentsProvider(groupId));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 46,
          child: ElevatedButton.icon(
            onPressed: () => _showAssignTaskSheet(
              context: context,
              ref: ref,
              courseId: courseId,
              groupId: groupId,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.add),
            label: Text(
              'Asignar Nueva Tarea',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 14),
        assignmentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              const _EmptyInfo(text: 'No se pudieron cargar tareas'),
          data: (assignments) => _GroupAssignmentsList(assignments: assignments),
        ),
      ],
    );
  }
}

Future<void> _showAssignTaskSheet({
  required BuildContext context,
  required WidgetRef ref,
  required int courseId,
  required int groupId,
}) async {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  DateTime? dueDate;
  bool saving = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        final canSubmit =
            titleCtrl.text.trim().isNotEmpty && dueDate != null && !saving;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(sheetContext).viewInsets.bottom + 18,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Asignar Nueva Tarea',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: saving
                          ? null
                          : () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Text(
                  'Se asignara a todos los miembros del grupo.',
                  style: GoogleFonts.inter(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Titulo de la tarea',
                    hintText: 'Ej: Ejercicios del capitulo 5',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'El titulo es requerido'
                      : null,
                  onChanged: (_) => setSheetState(() {}),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripcion',
                    hintText: 'Instrucciones detalladas para el grupo...',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Fecha limite',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: saving
                      ? null
                      : () async {
                          final picked = await showDatePicker(
                            context: sheetContext,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 3),
                            ),
                            initialDate: dueDate ?? DateTime.now(),
                          );
                          if (picked == null) return;
                          setSheetState(() => dueDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                23,
                                59,
                              ));
                        },
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(
                    dueDate == null
                        ? 'Seleccionar fecha'
                        : DateFormat('dd/MM/yyyy').format(dueDate!),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: saving
                            ? null
                            : () => Navigator.pop(sheetContext),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: canSubmit
                            ? () async {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }
                                setSheetState(() => saving = true);
                                try {
                                  await ref
                                      .read(courseGroupsNotifierProvider
                                          .notifier)
                                      .assignTaskToGroup(
                                        courseId: courseId,
                                        groupId: groupId,
                                        title: titleCtrl.text,
                                        description: descCtrl.text,
                                        dueDate: dueDate!,
                                      );
                                  if (!sheetContext.mounted) return;
                                  FocusScope.of(sheetContext).unfocus();
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (!sheetContext.mounted) return;
                                    Navigator.pop(sheetContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Tarea asignada al grupo',
                                          style: GoogleFonts.inter(),
                                        ),
                                      ),
                                    );
                                  });
                                } catch (e) {
                                  setSheetState(() => saving = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('No se pudo asignar: $e'),
                                      backgroundColor: Colors.red.shade700,
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                        ),
                        child: Text(saving ? 'Asignando...' : 'Asignar Tarea'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  titleCtrl.dispose();
  descCtrl.dispose();
}

class _GroupAssignmentsCard extends StatelessWidget {
  final List<GroupAssignment> assignments;
  final VoidCallback onAssign;

  const _GroupAssignmentsCard({
    required this.assignments,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Tareas del grupo',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onAssign,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _GroupAssignmentsList(assignments: assignments),
        ],
      ),
    );
  }
}

class _GroupAssignmentsList extends StatelessWidget {
  final List<GroupAssignment> assignments;

  const _GroupAssignmentsList({required this.assignments});

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return const _EmptyInfo(text: 'Aun no hay tareas asignadas al grupo');
    }

    return Column(
      children: assignments
          .map(
            (assignment) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withOpacity(0.6)),
              ),
              child: Row(
                children: [
                  Icon(
                    assignment.graded
                        ? Icons.check_circle_outline
                        : Icons.pending_actions_outlined,
                    color: assignment.graded
                        ? AppColors.success
                        : Colors.orange.shade700,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Entrega: ${DateFormat('dd/MM/yyyy').format(assignment.dueDate)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final CourseGroup group;
  final VoidCallback onTap;

  const _GroupTile({
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.courseColor(group.id % 10);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withOpacity(0.6)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color,
                child: const Icon(Icons.groups_2_outlined, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: GoogleFonts.inter(
                        fontSize: 23 * 0.75,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${group.memberCount} miembros',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupPreviewCard extends StatelessWidget {
  final String name;
  const _GroupPreviewCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.info,
            child: const Icon(Icons.groups_2_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Nombre del grupo' : name,
                  style: GoogleFonts.inter(
                    fontSize: 20 * 0.75,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Vista previa',
                  style: GoogleFonts.inter(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCounter extends StatelessWidget {
  final String value;
  final String title;

  const _InfoCounter({required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.7)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 30 * 0.75,
              fontWeight: FontWeight.w800,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14 * 0.75,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withOpacity(0.65)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color:
                      label == 'Eliminar' ? Colors.red : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyInfo extends StatelessWidget {
  final String text;
  const _EmptyInfo({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(color: AppColors.textSecondary),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(color: AppColors.textPrimary),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

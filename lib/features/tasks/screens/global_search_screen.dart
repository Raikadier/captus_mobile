import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/task.dart';
import '../../../models/course.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  List<TaskModel> get _taskResults => _query.isEmpty
      ? []
      : TaskModel.mockList
          .where((t) => t.title.toLowerCase().contains(_query.toLowerCase()))
          .toList();

  List<CourseModel> get _courseResults => _query.isEmpty
      ? []
      : CourseModel.mockList
          .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasResults = _taskResults.isNotEmpty || _courseResults.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          style: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Buscar tareas, materias, grupos...',
            hintStyle:
                GoogleFonts.inter(fontSize: 16, color: AppColors.textDisabled),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                _searchCtrl.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? _RecentSearches()
          : hasResults
              ? _SearchResults(
                  tasks: _taskResults,
                  courses: _courseResults,
                )
              : _NoResults(query: _query),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recents = ['Cálculo II', 'Estructuras de Datos', 'Parcial'];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'BÚSQUEDAS RECIENTES',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        ...recents.map((r) => ListTile(
              leading: const Icon(Icons.history_rounded,
                  color: AppColors.textSecondary),
              title: Text(r, style: GoogleFonts.inter(fontSize: 14)),
              dense: true,
              contentPadding: EdgeInsets.zero,
            )),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<TaskModel> tasks;
  final List<CourseModel> courses;

  const _SearchResults({required this.tasks, required this.courses});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (tasks.isNotEmpty) ...[
          Text(
            'TAREAS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          ...tasks.map((t) => ListTile(
                leading: const Icon(Icons.check_box_outline_blank_rounded,
                    color: AppColors.primary),
                title: Text(t.title, style: GoogleFonts.inter(fontSize: 14)),
                subtitle: Text(t.courseName ?? '',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary)),
                dense: true,
                onTap: () => context.push('/tasks/${t.id}'),
              )),
        ],
        if (courses.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'MATERIAS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          ...courses.map((c) => ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.courseColor(c.colorIndex).withAlpha(38),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      c.name[0],
                      style: TextStyle(
                        color: AppColors.courseColor(c.colorIndex),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(c.name, style: GoogleFonts.inter(fontSize: 14)),
                subtitle: Text(c.code,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary)),
                dense: true,
                onTap: () => context.push('/courses/${c.id}'),
              )),
        ],
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Sin resultados para "$query"',
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '¿Quieres preguntarle a Captus IA?',
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.push('/ai'),
              icon: const Text('🤖', style: TextStyle(fontSize: 16)),
              label: const Text('Preguntar al asistente'),
            ),
          ],
        ),
      ),
    );
  }
}

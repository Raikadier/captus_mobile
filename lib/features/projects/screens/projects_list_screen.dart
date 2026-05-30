import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/services/api_client.dart';
import '../../../shared/widgets/captus_fab.dart';
import '../../../shared/widgets/captus_pressable.dart';
import '../../../shared/widgets/cactus_refresh.dart';

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  List<dynamic> _projects = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.get('/projects');
      final data = res.data;
      if (mounted) {
        setState(() {
          if (data is List) {
            _projects = data;
          } else if (data is Map && data['data'] is List) {
            _projects = data['data'] as List;
          } else {
            _projects = [];
          }
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Proyectos',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: const [SizedBox(width: AppSpacing.s2)],
      ),
      floatingActionButton: CaptusFab(
        onPressed: () async {
          await context.push('/projects/create');
          _load();
        },
        icon: Icons.add_rounded,
        tooltip: 'Nuevo proyecto',
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
              ? _buildError()
              : _projects.isEmpty
                  ? _buildEmpty()
                  : CactusRefresh(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.s4, AppSpacing.s2, AppSpacing.s4, 100),
                        itemCount: _projects.length,
                        itemBuilder: (_, i) {
                          final p = _projects[i] as Map<String, dynamic>;
                          return _ProjectCard(
                            project: p,
                            onTap: () => context.push('/projects/${p['id']}'),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56, color: AppColors.error),
          const SizedBox(height: AppSpacing.s3),
          Text(
            'Error al cargar proyectos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s4),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: _load,
            child: Text(
              'Reintentar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textOnPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.folder_open_rounded,
            size: 56,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            'Sin proyectos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            'Crea tu primer proyecto colaborativo',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s6),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () async {
              await context.push('/projects/create');
              _load();
            },
            icon: const Icon(Icons.add_rounded, color: AppColors.textOnPrimary),
            label: Text(
              'Crear proyecto',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textOnPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;
  final VoidCallback onTap;

  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final role = project['userRole'] as String? ??
        project['role'] as String? ??
        'member';
    final memberCount = project['memberCount'] as int? ??
        (project['members'] as List?)?.length ??
        0;
    final isOwner = role == 'owner' || role == 'admin';

    return CaptusPressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s3),
        padding: const EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r6),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(AppAlpha.a10),
                borderRadius: BorderRadius.circular(AppRadius.r5),
              ),
              child: const Icon(
                Icons.folder_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project['title'] as String? ?? 'Sin título',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isOwner
                              ? AppColors.primary.withAlpha(AppAlpha.a10)
                              : AppColors.surface2,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOwner ? 'Propietario' : 'Miembro',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: isOwner
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (project['description'] != null &&
                      (project['description'] as String).isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      project['description'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s1),
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.s1),
                      Text(
                        '$memberCount ${memberCount == 1 ? 'miembro' : 'miembros'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s2),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

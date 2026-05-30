import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../models/group.dart';
import '../../../shared/widgets/captus_fab.dart';
import '../../../shared/widgets/captus_pressable.dart';
import '../../../shared/widgets/empty_state.dart';

class GroupsListScreen extends ConsumerStatefulWidget {
  const GroupsListScreen({super.key});

  @override
  ConsumerState<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends ConsumerState<GroupsListScreen> {
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeFocuses = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _codeFocuses) {
      f.dispose();
    }
    super.dispose();
  }

  void _showJoinDialog() {
    for (final c in _codeControllers) {
      c.clear();
    }
    showDialog(
      context: context,
      builder: (context) {
            return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Unirse con código',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ingresa el código de 6 caracteres',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.s5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 40,
                    child: TextField(
                      controller: _codeControllers[i],
                      focusNode: _codeFocuses[i],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: Theme.of(context).textTheme.headlineMedium,
                      decoration: const InputDecoration(
                        counterText: '',
                      ),
                      onChanged: (v) {
                        if (v.isNotEmpty && i < 5) {
                          _codeFocuses[i + 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final code = _codeControllers.map((c) => c.text).join();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Buscando grupo: $code',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    backgroundColor: AppColors.surface2,
                  ),
                );
              },
              child: Text(
                'Unirse',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFabMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
            return Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.s4, AppSpacing.s4, AppSpacing.s4, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.s5),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(AppAlpha.a10),
                    borderRadius: BorderRadius.circular(AppRadius.r5),
                  ),
                  child:
                      const Icon(Icons.group_add, color: AppColors.primary, size: 22),
                ),
                title: Text(
                  'Crear grupo',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Nuevo grupo de trabajo',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/groups/create');
                },
              ),
              const SizedBox(height: AppSpacing.s2),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha(AppAlpha.a10),
                    borderRadius: BorderRadius.circular(AppRadius.r5),
                  ),
                  child:
                      const Icon(Icons.qr_code, color: AppColors.info, size: 22),
                ),
                title: Text(
                  'Unirse con código',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Ingresar código de invitación',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showJoinDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatLastActivity(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    return 'Hace ${diff.inDays} días';
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(myGroupsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mis Grupos',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_outlined,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: AppSpacing.s3),
              Text(
                'No se pudo cargar los grupos',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s4),
              OutlinedButton(
                onPressed: () => ref.invalidate(myGroupsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (groups) => groups.isEmpty
            ? EmptyState(
                icon: Icons.group_outlined,
                title: 'Sin grupos',
                subtitle: 'Crea un grupo o únete con un código.',
                actionLabel: 'Comenzar',
                onAction: _showFabMenu,
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => ref.invalidate(myGroupsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.s4),
                  itemCount: groups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s3),
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return _GroupCard(
                      group: group,
                      lastActivityText: _formatLastActivity(group.lastActivity),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: CaptusFab(
        onPressed: _showFabMenu,
        icon: Icons.add,
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupModel group;
  final String lastActivityText;

  const _GroupCard({
    required this.group,
    required this.lastActivityText,
  });

  @override
  Widget build(BuildContext context) {
    return CaptusPressable(
      onTap: () => context.push('/groups/${group.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r7),
          border: Border.all(color: AppColors.border.withAlpha(AppAlpha.a40)),
        ),
        child: Row(
          children: [
            _MemberAvatars(
              members: group.members,
              count: group.effectiveMemberCount,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  if (group.courseName != null)
                    Text(
                      group.courseName!,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: AppSpacing.s1),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 12, color: AppColors.textDisabled),
                      const SizedBox(width: AppSpacing.s1),
                      Text(
                        lastActivityText,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textDisabled),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s2),
            if (group.pendingTasks > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2, vertical: AppSpacing.s1),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(AppAlpha.a15),
                  borderRadius: BorderRadius.circular(AppRadius.r3),
                ),
                child: Text(
                  '${group.pendingTasks}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shows stacked member avatars when [members] are available,
/// or a simple member count badge when only a count is known.
class _MemberAvatars extends StatelessWidget {
  final List<GroupMember> members;
  final int count;

  const _MemberAvatars({required this.members, required this.count});

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      // Compact count badge when we only have a number
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(AppAlpha.a10),
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$count',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(
              count == 1 ? 'miembro' : 'mbrs',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 8),
            ),
          ],
        ),
      );
    }

    final visible = members.take(3).toList();
    const avatarSize = 34.0;
    const overlap = 10.0;
    final totalWidth =
        avatarSize + (visible.length - 1).clamp(0, 2) * (avatarSize - overlap);

    return SizedBox(
      width: totalWidth,
      height: avatarSize,
      child: Stack(
        children: List.generate(visible.length, (i) {
          final member = visible[i];
          return Positioned(
            left: i * (avatarSize - overlap),
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
                color: AppColors.courseColor(i),
              ),
              child: Center(
                child: Text(
                  member.name.isNotEmpty ? member.name[0] : '?',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

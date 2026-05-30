import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/utils/app_errors.dart';
import '../services/admin_service.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../shared/widgets/captus_pressable.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<dynamic> _members = [];
  bool _loading = true;
  String _roleTab = 'all';

  static const _roleLabels = {
    'all': 'Todos',
    'student': 'Estudiantes',
    'teacher': 'Docentes',
    'admin': 'Admins',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await AdminService.instance.getMembers(
        role: _roleTab == 'all' ? null : _roleTab,
      );
      if (mounted) setState(() { _members = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showInviteDialog() async {
    String email = '';
    String role = 'student';

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
            left: AppSpacing.s5, right: AppSpacing.s5, top: AppSpacing.s5,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invitar usuario',
                style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.s4),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email del usuario',
                  hintText: 'correo@ejemplo.com',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => email = v,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.s3),
              DropdownButtonFormField<String>(
                value: role,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Estudiante')),
                  DropdownMenuItem(value: 'teacher', child: Text('Docente')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setModal(() => role = v ?? role),
              ),
              const SizedBox(height: AppSpacing.s4),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    if (email.isEmpty) return;
                    Navigator.pop(ctx);
                    try {
                      await AdminService.instance.inviteUser(email, role);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Usuario invitado correctamente')));
                        _load();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(friendlyError(e, fallback: 'No se pudo invitar al usuario. Intenta de nuevo.'))));
                      }
                    }
                  },
                  child: Text('Invitar',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppColors.textOnPrimary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRemove(String userId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover usuario'),
        content: Text('¿Remover a $name de la institución?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Remover', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await AdminService.instance.removeUser(userId);
        if (mounted) {
          setState(() => _members.removeWhere((u) => u['id'] == userId));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario removido')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e, fallback: 'No se pudo remover al usuario. Intenta de nuevo.'))));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Usuarios',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: AppColors.primary),
            onPressed: _showInviteDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Role tabs
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s1),
              children: _roleLabels.entries.map((e) {
                final selected = _roleTab == e.key;
                return CaptusPressable(
                  onTap: () {
                    setState(() => _roleTab = e.key);
                    _load();
                  },
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    margin: const EdgeInsets.only(right: AppSpacing.s2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      e.value,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: selected ? AppColors.textOnPrimary : AppColors.textSecondary),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _members.isEmpty
                ? Center(
                    child: Text('Sin resultados',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary)))
                : RefreshIndicator(
                    onRefresh: _load,
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.s4),
                      itemCount: _members.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s2),
                      itemBuilder: (_, i) {
                        final u = _members[i] as Map<String, dynamic>;
                        final name = u['name'] ?? u['email'] ?? 'Sin nombre';
                        final role = u['role'] ?? 'student';
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.r5),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primary.withAlpha(AppAlpha.a15),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name,
                                      style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppColors.textPrimary)),
                                    Text(u['email'] ?? '',
                                      style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              _RoleBadge(role: role),
                              const SizedBox(width: AppSpacing.s2),
                              CaptusPressable(
                                onTap: () => _confirmRemove(u['id'].toString(), name),
                                child: const Icon(Icons.remove_circle_outline,
                                  color: AppColors.error, size: 20),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (role) {
      'teacher' => ('Docente',    AppColors.infoLight,    AppColors.info),
      'admin'   => ('Admin',      AppColors.errorLight,   AppColors.error),
      _         => ('Estudiante', AppColors.successLight, AppColors.success),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
        style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

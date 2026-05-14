import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_animations.dart';
import '../../core/providers/auth_provider.dart';
import '../../shared/widgets/offline_banner.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _getSelectedIndex(BuildContext context, String role) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/tasks') ||
        location.startsWith('/teacher/assignments') ||
        location.startsWith('/student/assignments')) return 1;
    if (location.startsWith('/ai')) return 2;
    if (location.startsWith('/courses') || location.startsWith('/teacher/courses')) return 3;
    if (location.startsWith('/calendar') || location.startsWith('/notes')) return 4;
    return 0;
  }

  void _onTabTap(BuildContext context, int index, String role) {
    switch (index) {
      case 0:
        if (role == 'teacher') {
          context.go('/home/teacher');
        } else {
          context.go('/home');
        }
        break;
      case 1:
        if (role == 'teacher') {
          context.go('/teacher/assignments');
        } else {
          context.go('/tasks');
        }
        break;
      case 2:
        context.go('/ai');
        break;
      case 3:
        if (role == 'teacher') {
          context.go('/teacher/courses');
        } else {
          context.go('/courses');
        }
        break;
      case 4:
        break;
    }
  }

void _showMoreMenu(BuildContext context, String role) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => _MoreMenuSheet(
        role: role,
        onNavigate: (route) {
          Navigator.pop(context);
          context.go(route);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    final selectedIndex = _getSelectedIndex(context, role);

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: _CaptusBottomNav(
        selectedIndex: selectedIndex,
        role: role,
        onTap: (i) {
          if (i == 4) {
            _showMoreMenu(context, role);
          } else {
            _onTabTap(context, i, role);
          }
        },
      ),
    );
  }
}

class _CaptusBottomNav extends StatelessWidget {
  final int selectedIndex;
  final String role;
  final ValueChanged<int> onTap;

  const _CaptusBottomNav({
    required this.selectedIndex,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(25),
        border: Border(
          top: BorderSide(color: AppColors.primary.withAlpha(50), width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                isSelected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment_rounded,
                isSelected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              _CenterNavItem(
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome_rounded,
                isSelected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.school_outlined,
                activeIcon: Icons.school_rounded,
                isSelected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.add_circle_outline_rounded,
                activeIcon: Icons.add_circle_rounded,
                isSelected: selectedIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.exit,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          size: 26,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _CenterNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterNavItem({
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.exit,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [AppColors.primary, AppColors.primaryDark]
                : [AppColors.surface2, AppColors.surface2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(100),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          size: 28,
          color: isSelected ? Colors.white : AppColors.textSecondary, // white OK: over gradient green bg
        ),
      ),
    );
  }
}

class _MoreMenuSheet extends StatelessWidget {
  final String role;
  final ValueChanged<String> onNavigate;

  const _MoreMenuSheet({
    required this.role,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), // AppColors.modalBg — available after Phase 1 merge
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Más opciones',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _MenuOption(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.primary,
                title: 'Calendario',
                subtitle: 'Ver eventos yrecordatorios',
                onTap: () => onNavigate('/calendar'),
              ),
              const SizedBox(height: 12),
              _MenuOption(
                icon: Icons.note_alt_rounded,
                iconColor: AppColors.streak,
                title: 'Notas',
                subtitle: 'Tus notas personales',
                onTap: () => onNavigate('/notes'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}


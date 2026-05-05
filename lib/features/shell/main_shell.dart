import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _selectedIndex(BuildContext context, String role) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/tasks') ||
        location.startsWith('/teacher/assignments') ||
        location.startsWith('/student/assignments')) return 1;
    if (location.startsWith('/calendar')) return 2;
    if (role == 'teacher') {
      if (location.startsWith('/teacher/statistics')) return 3;
    } else {
      if (location.startsWith('/ai')) return 3;
    }
    if (location.startsWith('/groups')) return 4;
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
          // El estudiante navega a su nuevo módulo de asignaciones
          context.go('/student/assignments');
        }
        break;
      case 2:
        context.go('/calendar');
        break;
      case 3:
        if (role == 'teacher') {
          context.go('/teacher/statistics');
        } else {
          context.go('/ai');
        }
        break;
      case 4:
        context.go('/groups');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    final selectedIndex = _selectedIndex(context, role);

    return Scaffold(
      body: child,
      bottomNavigationBar: _CaptusBottomNav(
        selectedIndex: selectedIndex,
        role: role,
        onTap: (i) => _onTabTap(context, i, role),
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
    final isTeacher = role == 'teacher';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Inicio',
                isSelected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.check_box_outline_blank_rounded,
                activeIcon: Icons.check_box_rounded,
                label: 'Tareas',
                isSelected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today_rounded,
                label: 'Calendario',
                isSelected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
              if (isTeacher)
                _NavItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart_rounded,
                  label: 'Estadísticas',
                  isSelected: selectedIndex == 3,
                  onTap: () => onTap(3),
                )
              else
                _NavItem(
                  icon: Icons.auto_awesome_outlined,
                  activeIcon: Icons.auto_awesome_rounded,
                  label: 'IA',
                  isSelected: selectedIndex == 3,
                  onTap: () => onTap(3),
                ),
              _NavItem(
                icon: Icons.group_outlined,
                activeIcon: Icons.group_rounded,
                label: 'Grupos',
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
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72, // Slightly wider to accommodate "Estadísticas"
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withAlpha(25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    size: 24,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


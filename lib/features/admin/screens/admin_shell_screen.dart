import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_spacing.dart';

/// Top-level shell for admin users.
/// Bottom nav: Panel · Usuarios · Cursos · Escalas · Períodos · Cuenta
class AdminShellScreen extends StatelessWidget {
  final Widget child;
  const AdminShellScreen({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/admin/users'))          return 1;
    if (location.startsWith('/admin/courses'))        return 2;
    if (location.startsWith('/admin/grading-scales')) return 3;
    if (location.startsWith('/admin/periods'))        return 4;
    // index 5 = Cuenta → profile is pushed outside shell, so never matched here
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/admin/dashboard');
      case 1: context.go('/admin/users');
      case 2: context.go('/admin/courses');
      case 3: context.go('/admin/grading-scales');
      case 4: context.go('/admin/periods');
      // Push (not go) so the shell stays in the back-stack and the
      // back button on ProfileScreen returns here.
      case 5: context.push('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final idx = _selectedIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              // No fixed item widths — Expanded distributes evenly for any
              // number of tabs without overflowing on narrow screens.
              children: [
                Expanded(
                  child: _AdminNavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    label: 'Panel',
                    isSelected: idx == 0,
                    onTap: () => _onTap(context, 0),
                  ),
                ),
                Expanded(
                  child: _AdminNavItem(
                    icon: Icons.people_outline_rounded,
                    activeIcon: Icons.people_rounded,
                    label: 'Usuarios',
                    isSelected: idx == 1,
                    onTap: () => _onTap(context, 1),
                  ),
                ),
                Expanded(
                  child: _AdminNavItem(
                    icon: Icons.book_outlined,
                    activeIcon: Icons.book_rounded,
                    label: 'Cursos',
                    isSelected: idx == 2,
                    onTap: () => _onTap(context, 2),
                  ),
                ),
                Expanded(
                  child: _AdminNavItem(
                    icon: Icons.grading_outlined,
                    activeIcon: Icons.grading_rounded,
                    label: 'Escalas',
                    isSelected: idx == 3,
                    onTap: () => _onTap(context, 3),
                  ),
                ),
                Expanded(
                  child: _AdminNavItem(
                    icon: Icons.date_range_outlined,
                    activeIcon: Icons.date_range_rounded,
                    label: 'Períodos',
                    isSelected: idx == 4,
                    onTap: () => _onTap(context, 4),
                  ),
                ),
                Expanded(
                  child: _AdminNavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Cuenta',
                    // Profile is pushed outside the shell, so never "selected"
                    // as a shell tab — but the icon still clearly indicates where
                    // the user will land.
                    isSelected: false,
                    onTap: () => _onTap(context, 5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AdminNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            size: 20,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: tt.labelSmall!.copyWith(color: isSelected ? AppColors.primary : AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s1),
          AnimatedContainer(
            duration: AppDurations.fast,
            width: isSelected ? 4 : 0,
            height: isSelected ? 4 : 0,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

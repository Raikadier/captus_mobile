import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_animations.dart';
import '../../core/constants/app_gradients.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_radius.dart';
import '../../core/providers/auth_provider.dart';
import '../../shared/widgets/captus_pressable.dart';
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
    if (location.startsWith('/courses') ||
        location.startsWith('/teacher/courses')) return 3;
    if (location.startsWith('/calendar') || location.startsWith('/notes')) return 4;
    return 0;
  }

  void _onTabTap(BuildContext context, int index, String role) {
    switch (index) {
      case 0:
        context.go(role == 'teacher' ? '/home/teacher' : '/home');
      case 1:
        context.go(role == 'teacher' ? '/teacher/assignments' : '/tasks');
      case 2:
        context.go('/ai');
      case 3:
        context.go(role == 'teacher' ? '/teacher/courses' : '/courses');
      case 4:
        break;
    }
  }

  void _showMoreMenu(BuildContext context, String role) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.textPrimary.withAlpha(AppAlpha.a40),
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

// ── Premium bottom navigation bar ─────────────────────────────────────────────
//
// v2: Dark shell (slate-900) background — premium, Spotify-inspired.
// Hairline slate-800 top border. Selected = brand green. Unselected = slate-400.
//
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
      decoration: const BoxDecoration(
        color: AppColors.shellBg,  // slate-900 — dark shell
        border: Border(
          top: BorderSide(
            color: AppColors.shellSurface, // slate-800 hairline
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: AppSpacing.bottomNavHeight,
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
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment_rounded,
                label: 'Tareas',
                isSelected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              _CenterNavItem(
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome_rounded,
                label: 'Captus AI',
                isSelected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.school_outlined,
                activeIcon: Icons.school_rounded,
                label: 'Cursos',
                isSelected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                label: 'Más',
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
    return Semantics(
      button: true,
      label: label,
      selected: isSelected,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: AppDurations.fast,
                curve: AppCurves.standard,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3 + 2, vertical: AppSpacing.s1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withAlpha(AppAlpha.a20)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill), // pill indicator
                ),
                child: AnimatedSwitcher(
                  duration: AppDurations.quick,
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey(isSelected),
                    size: 24,
                    color: isSelected
                        ? AppColors.primary    // brand green on dark
                        : AppColors.slate400,  // muted gray
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s1),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.slate500,
                  letterSpacing: isSelected ? 0.1 : 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Center "AI" button — premium gradient pill with brand shadow
class _CenterNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      selected: isSelected,
      excludeSemantics: true,
      child: CaptusPressable(
        onTap: onTap,
        pressScale: 0.92,
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: AppDurations.standard,
                curve: AppCurves.springShort,
                width: 44,
                height: 32,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppGradients.brand : null,
                  color: isSelected ? null : AppColors.shellSurface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: isSelected ? AppShadows.brandSm : null,
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: AppDurations.quick,
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      key: ValueKey(isSelected),
                      size: 22,
                      color: isSelected
                          ? AppColors.textOnPrimary
                          : AppColors.slate400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s1),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.slate500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── More-options bottom sheet ──────────────────────────────────────────────────

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
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r10)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Más opciones',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              _MenuOption(
                icon: Icons.calendar_month_rounded,
                iconColor: AppColors.primary,
                title: 'Calendario',
                subtitle: 'Ver eventos y recordatorios',
                onTap: () => onNavigate('/calendar'),
              ),
              const SizedBox(height: AppSpacing.cardGap),
              _MenuOption(
                icon: Icons.note_alt_rounded,
                iconColor: AppColors.streak,
                title: 'Notas',
                subtitle: 'Tus notas personales',
                onTap: () => onNavigate('/notes'),
              ),
              const SizedBox(height: AppSpacing.s4),
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
    return CaptusPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPaddingStd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r7),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: AppShadows.xs,
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              padding: const EdgeInsets.all(AppSpacing.s3),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(AppAlpha.a10),
                borderRadius: BorderRadius.circular(AppRadius.r5),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: AppSpacing.s4),
            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell screen for the superadmin section — provides bottom navigation
/// between platform dashboard, institutions list, and global users.
class SuperAdminShellScreen extends StatelessWidget {
  final Widget child;
  const SuperAdminShellScreen({super.key, required this.child});

  static const _tabs = [
    _Tab(label: 'Plataforma', icon: Icons.dashboard_outlined,    route: '/superadmin/dashboard'),
    _Tab(label: 'Instituciones', icon: Icons.business_outlined,  route: '/superadmin/institutions'),
    _Tab(label: 'Usuarios',   icon: Icons.people_outline,        route: '/superadmin/users'),
    _Tab(label: 'Auditoría',  icon: Icons.history_outlined,      route: '/superadmin/audit'),
  ];

  int _selectedIndex(BuildContext ctx) {
    final loc = GoRouterState.of(ctx).uri.toString();
    for (var i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _selectedIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_tabs[i].route),
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

class _Tab {
  final String label;
  final IconData icon;
  final String route;
  const _Tab({required this.label, required this.icon, required this.route});
}

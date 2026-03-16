import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';

class AppShellScaffold extends ConsumerWidget {
  const AppShellScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<_ShellTab> _tabs = [
    _ShellTab(
      label: 'Dashboard',
      title: 'Dashboard',
      icon: Icons.space_dashboard_rounded,
    ),
    _ShellTab(
      label: 'Projects',
      title: 'Projects',
      icon: Icons.apartment_rounded,
    ),
    _ShellTab(label: 'Tasks', title: 'Tasks', icon: Icons.task_alt_rounded),
    _ShellTab(label: 'Map', title: 'Map', icon: Icons.map_rounded),
    _ShellTab(label: 'Profile', title: 'Profile', icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final activeTab = _tabs[navigationShell.currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(activeTab.title),
        actions: [
          IconButton(
            onPressed: authState.isSubmitting
                ? null
                : () {
                    ref.read(authControllerProvider.notifier).logout();
                  },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: _tabs
            .map(
              (tab) =>
                  NavigationDestination(icon: Icon(tab.icon), label: tab.label),
            )
            .toList(),
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab({
    required this.label,
    required this.title,
    required this.icon,
  });

  final String label;
  final String title;
  final IconData icon;
}

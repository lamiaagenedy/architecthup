import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/presentation/widgets/common/corporate_app_bar.dart';

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<_ShellTab> _tabs = [
    _ShellTab(
      label: AppStrings.tabDashboard,
      title: AppStrings.tabDashboard,
      icon: Icons.space_dashboard_rounded,
    ),
    _ShellTab(
      label: AppStrings.tabProjects,
      title: AppStrings.tabProjects,
      icon: Icons.apartment_rounded,
    ),
    _ShellTab(
      label: AppStrings.tabTasks,
      title: AppStrings.tabTasks,
      icon: Icons.task_alt_rounded,
    ),
    _ShellTab(
      label: AppStrings.tabMap,
      title: AppStrings.tabMap,
      icon: Icons.map_rounded,
    ),
    _ShellTab(
      label: AppStrings.tabProfile,
      title: AppStrings.tabProfile,
      icon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeTab = _tabs[navigationShell.currentIndex];

    return Scaffold(
      appBar: CorporateAppBar(title: activeTab.title, isRoot: true),
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

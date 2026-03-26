import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import 'app_bottom_navigation.dart';
import 'authenticated_shell_header.dart';

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<_ShellTab> _tabs = [
    _ShellTab(
      label: AppStrings.tabDashboard,
      title: AppStrings.tabDashboard,
      subtitle: AppStrings.shellHeaderDashboardSubtitle,
      icon: Icons.space_dashboard_rounded,
    ),
    _ShellTab(
      label: AppStrings.tabProjects,
      title: AppStrings.tabProjects,
      subtitle: AppStrings.shellHeaderProjectsSubtitle,
      icon: Icons.apartment_rounded,
    ),
    _ShellTab(
      label: AppStrings.tabTasks,
      title: AppStrings.tabTasks,
      subtitle: AppStrings.shellHeaderTasksSubtitle,
      icon: Icons.task_alt_rounded,
    ),
    _ShellTab(
      label: AppStrings.tabMap,
      title: AppStrings.tabMap,
      subtitle: AppStrings.shellHeaderMapSubtitle,
      icon: Icons.map_rounded,
    ),
    _ShellTab(
      label: AppStrings.tabProfile,
      title: AppStrings.tabProfile,
      subtitle: AppStrings.shellHeaderProfileSubtitle,
      icon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeTab = _tabs[navigationShell.currentIndex];

    return Scaffold(
      appBar: AuthenticatedShellHeader(
        eyebrow: AppStrings.shellHeaderEyebrow,
        title: activeTab.title,
        subtitle: activeTab.subtitle,
      ),
      body: navigationShell,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: navigationShell.currentIndex,
        items: _tabs
            .map(
              (tab) =>
                  AppBottomNavigationItem(icon: tab.icon, label: tab.label),
            )
            .toList(),
        onTap: (index) {
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
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
}

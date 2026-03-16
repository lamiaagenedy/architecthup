import 'package:flutter/material.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.projectSummary,
    required this.activeProjects,
    required this.statusIndicators,
    required this.upcomingItems,
    required this.recentUpdates,
    required this.quickActions,
  });

  final DashboardProjectSummary projectSummary;
  final List<DashboardProjectItem> activeProjects;
  final List<DashboardStatusIndicator> statusIndicators;
  final List<DashboardWorkItem> upcomingItems;
  final List<DashboardUpdateItem> recentUpdates;
  final List<DashboardQuickAction> quickActions;
}

class DashboardProjectSummary {
  const DashboardProjectSummary({
    required this.totalProjects,
    required this.onTrackProjects,
    required this.atRiskProjects,
    required this.needsAttentionProjects,
    required this.tasksDueToday,
    required this.openMaintenanceItems,
  });

  final int totalProjects;
  final int onTrackProjects;
  final int atRiskProjects;
  final int needsAttentionProjects;
  final int tasksDueToday;
  final int openMaintenanceItems;
}

class DashboardProjectItem {
  const DashboardProjectItem({
    required this.name,
    required this.location,
    required this.stage,
    required this.progress,
    required this.statusLabel,
    required this.statusTone,
    required this.nextMilestone,
  });

  final String name;
  final String location;
  final String stage;
  final double progress;
  final String statusLabel;
  final DashboardTone statusTone;
  final String nextMilestone;
}

class DashboardStatusIndicator {
  const DashboardStatusIndicator({
    required this.label,
    required this.value,
    required this.caption,
    required this.tone,
  });

  final String label;
  final String value;
  final String caption;
  final DashboardTone tone;
}

class DashboardWorkItem {
  const DashboardWorkItem({
    required this.title,
    required this.projectName,
    required this.categoryLabel,
    required this.scheduleLabel,
    required this.priorityLabel,
    required this.tone,
  });

  final String title;
  final String projectName;
  final String categoryLabel;
  final String scheduleLabel;
  final String priorityLabel;
  final DashboardTone tone;
}

class DashboardUpdateItem {
  const DashboardUpdateItem({
    required this.title,
    required this.description,
    required this.timeLabel,
  });

  final String title;
  final String description;
  final String timeLabel;
}

class DashboardQuickAction {
  const DashboardQuickAction({
    required this.label,
    required this.description,
    required this.icon,
  });

  final String label;
  final String description;
  final IconData icon;
}

enum DashboardTone { positive, caution, critical, neutral }

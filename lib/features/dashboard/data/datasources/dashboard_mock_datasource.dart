import 'package:flutter/material.dart';

import '../../domain/entities/dashboard_snapshot.dart';

class DashboardMockDatasource {
  Future<DashboardSnapshot> loadDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    return DashboardSnapshot(
      projectSummary: const DashboardProjectSummary(
        totalProjects: 5,
        onTrackProjects: 3,
        atRiskProjects: 1,
        needsAttentionProjects: 1,
        tasksDueToday: 4,
        openMaintenanceItems: 2,
      ),
      activeProjects: const [
        DashboardProjectItem(
          name: 'North Gate Residences',
          location: 'Riyadh, Site A',
          stage: 'Structure & facade',
          progress: 0.72,
          statusLabel: 'On track',
          statusTone: DashboardTone.positive,
          nextMilestone: 'Facade inspection on Thursday',
        ),
        DashboardProjectItem(
          name: 'Palm Business Center',
          location: 'Jeddah, Block C',
          stage: 'MEP coordination',
          progress: 0.58,
          statusLabel: 'At risk',
          statusTone: DashboardTone.caution,
          nextMilestone: 'Resolve electrical clash review',
        ),
        DashboardProjectItem(
          name: 'Al Waha Villas',
          location: 'Dammam, Cluster 2',
          stage: 'Interior finishing',
          progress: 0.86,
          statusLabel: 'Needs attention',
          statusTone: DashboardTone.critical,
          nextMilestone: 'Material approval overdue',
        ),
      ],
      statusIndicators: const [
        DashboardStatusIndicator(
          label: 'Site readiness',
          value: '82%',
          caption: 'Crews cleared for today',
          tone: DashboardTone.positive,
        ),
        DashboardStatusIndicator(
          label: 'Inspections pending',
          value: '3',
          caption: 'Two close-out, one safety',
          tone: DashboardTone.caution,
        ),
        DashboardStatusIndicator(
          label: 'Blocked items',
          value: '2',
          caption: 'Awaiting client sign-off',
          tone: DashboardTone.critical,
        ),
      ],
      upcomingItems: const [
        DashboardWorkItem(
          title: 'Concrete pour checklist',
          projectName: 'North Gate Residences',
          categoryLabel: 'Task',
          scheduleLabel: 'Today, 09:30',
          priorityLabel: 'High priority',
          tone: DashboardTone.critical,
        ),
        DashboardWorkItem(
          title: 'Generator preventive service',
          projectName: 'Palm Business Center',
          categoryLabel: 'Maintenance',
          scheduleLabel: 'Today, 14:00',
          priorityLabel: 'Scheduled',
          tone: DashboardTone.caution,
        ),
        DashboardWorkItem(
          title: 'Finish snag review',
          projectName: 'Al Waha Villas',
          categoryLabel: 'Task',
          scheduleLabel: 'Tomorrow, 08:00',
          priorityLabel: 'Medium priority',
          tone: DashboardTone.neutral,
        ),
      ],
      recentUpdates: const [
        DashboardUpdateItem(
          title: 'Facade package approved',
          description: 'North Gate Residences advanced to the next handoff.',
          timeLabel: '25 min ago',
        ),
        DashboardUpdateItem(
          title: 'Safety note logged',
          description:
              'A ladder access issue was raised for Palm Business Center.',
          timeLabel: '1 hr ago',
        ),
        DashboardUpdateItem(
          title: 'Material delivery delayed',
          description: 'Joinery shipment for Al Waha Villas moved to tomorrow.',
          timeLabel: '2 hr ago',
        ),
      ],
      quickActions: const [
        DashboardQuickAction(
          label: 'Projects',
          description: 'Review site progress',
          icon: Icons.apartment_rounded,
        ),
        DashboardQuickAction(
          label: 'Tasks',
          description: 'Check due work items',
          icon: Icons.task_alt_rounded,
        ),
        DashboardQuickAction(
          label: 'Maintenance',
          description: 'Track scheduled servicing',
          icon: Icons.build_circle_rounded,
        ),
      ],
    );
  }
}

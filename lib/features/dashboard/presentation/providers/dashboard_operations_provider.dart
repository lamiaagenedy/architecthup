import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/dashboard_strings.dart';
import '../../../projects/domain/entities/project_list_item.dart';
import '../../../projects/presentation/providers/projects_provider.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import 'dashboard_provider.dart';

enum DashboardCategoryType { housekeeping, maintenance, security, landscape }

extension DashboardCategoryTypeX on DashboardCategoryType {
  String get label {
    return switch (this) {
      DashboardCategoryType.housekeeping =>
        DashboardStrings.categoryHousekeeping,
      DashboardCategoryType.maintenance => DashboardStrings.categoryMaintenance,
      DashboardCategoryType.security => DashboardStrings.categorySecurity,
      DashboardCategoryType.landscape => DashboardStrings.categoryLandscape,
    };
  }

  IconData get icon {
    return switch (this) {
      DashboardCategoryType.housekeeping => Icons.home_work_rounded,
      DashboardCategoryType.maintenance => Icons.build_circle_rounded,
      DashboardCategoryType.security => Icons.shield_rounded,
      DashboardCategoryType.landscape => Icons.park_rounded,
    };
  }
}

class DashboardCategoryScore {
  const DashboardCategoryScore({required this.category, required this.score});

  final DashboardCategoryType category;
  final int score;
}

class DashboardInspectionProject {
  const DashboardInspectionProject({
    required this.project,
    required this.overallScore,
    required this.categoryScores,
  });

  final ProjectListItem project;
  final int? overallScore;
  final List<DashboardCategoryScore> categoryScores;
}

class DashboardTaskSnapshotItem {
  const DashboardTaskSnapshotItem({
    required this.title,
    required this.projectName,
  });

  final String title;
  final String projectName;
}

class DashboardOperationsViewModel {
  const DashboardOperationsViewModel({
    required this.headerDateLabel,
    required this.activeProjectCount,
    required this.pendingTaskCount,
    required this.inspectionProjects,
    required this.highestRatedProject,
    required this.lowestRatedProject,
    required this.overallAverageScore,
    required this.inspectedToday,
    required this.totalProjects,
    required this.progressProjects,
    required this.categoryAverages,
    required this.attentionItems,
    required this.pendingTasks,
  });

  final String headerDateLabel;
  final int activeProjectCount;
  final int pendingTaskCount;
  final List<DashboardInspectionProject> inspectionProjects;
  final DashboardInspectionProject? highestRatedProject;
  final DashboardInspectionProject? lowestRatedProject;
  final int? overallAverageScore;
  final int inspectedToday;
  final int totalProjects;
  final List<ProjectListItem> progressProjects;
  final List<DashboardCategoryScore> categoryAverages;
  final List<DashboardInspectionProject> attentionItems;
  final List<DashboardTaskSnapshotItem> pendingTasks;
}

final dashboardOperationsViewModelProvider =
    Provider<AsyncValue<DashboardOperationsViewModel>>((ref) {
      final projectsAsync = ref.watch(projectsListProvider);
      final dashboardAsync = ref.watch(dashboardSnapshotProvider);

      return projectsAsync.when(
        data: (projects) {
          return dashboardAsync.when(
            data: (dashboardSnapshot) => AsyncValue.data(
              _buildDashboardOperationsViewModel(projects, dashboardSnapshot),
            ),
            loading: () => const AsyncValue.loading(),
            error: AsyncValue.error,
          );
        },
        loading: () => const AsyncValue.loading(),
        error: AsyncValue.error,
      );
    });

DashboardOperationsViewModel _buildDashboardOperationsViewModel(
  List<ProjectListItem> projects,
  DashboardSnapshot snapshot,
) {
  final sortedProjects = [...projects]
    ..sort((first, second) {
      return _projectStatusRank(
        first.status,
      ).compareTo(_projectStatusRank(second.status));
    });

  final inspectionProjects = sortedProjects
      .map((project) => _buildInspectionProject(project))
      .toList();
  final highestRatedProject = _findHighestRatedProject(inspectionProjects);
  final lowestRatedProject = _findLowestRatedProject(inspectionProjects);
  final overallAverageScore = _calculateOverallAverageScore(inspectionProjects);

  final inspectedToday = projects
      .where(
        (project) =>
            project.updatedLabel.contains('min') ||
            project.updatedLabel.contains('hr') ||
            project.updatedLabel.contains('Today'),
      )
      .length;

  final categoryAverages = DashboardCategoryType.values.map((category) {
    final scores = inspectionProjects
        .map(
          (project) => project.categoryScores
              .firstWhere((item) => item.category == category)
              .score,
        )
        .toList();

    if (scores.isEmpty) {
      return DashboardCategoryScore(category: category, score: 0);
    }

    final average = scores.reduce((sum, value) => sum + value) / scores.length;
    return DashboardCategoryScore(category: category, score: average.round());
  }).toList();

  final attentionItems = inspectionProjects.where((project) {
    return project.categoryScores.any(
      (categoryScore) => categoryScore.score < 75,
    );
  }).toList();

  final pendingTasks = snapshot.upcomingItems
      .where((item) => item.categoryLabel.toLowerCase() == 'task')
      .take(3)
      .map(
        (item) => DashboardTaskSnapshotItem(
          title: item.title,
          projectName: item.projectName,
        ),
      )
      .toList();

  final activeProjectCount = projects
      .where((project) => project.status == ProjectStatus.inProgress)
      .length;

  final pendingTaskCount = snapshot.upcomingItems
      .where((item) => item.categoryLabel.toLowerCase() == 'task')
      .length;

  return DashboardOperationsViewModel(
    headerDateLabel: _formatHeaderDate(DateTime.now()),
    activeProjectCount: activeProjectCount,
    pendingTaskCount: pendingTaskCount,
    inspectionProjects: inspectionProjects,
    highestRatedProject: highestRatedProject,
    lowestRatedProject: lowestRatedProject,
    overallAverageScore: overallAverageScore,
    inspectedToday: inspectedToday,
    totalProjects: projects.length,
    progressProjects: sortedProjects.take(5).toList(),
    categoryAverages: categoryAverages,
    attentionItems: attentionItems,
    pendingTasks: pendingTasks,
  );
}

DashboardInspectionProject _buildInspectionProject(ProjectListItem project) {
  final baseScore = (project.progress * 100).round();
  final categoryScores = DashboardCategoryType.values
      .map(
        (category) =>
            DashboardCategoryScore(category: category, score: baseScore),
      )
      .toList();

  return DashboardInspectionProject(
    project: project,
    overallScore: baseScore,
    categoryScores: categoryScores,
  );
}

String _formatHeaderDate(DateTime date) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final weekday = weekdays[date.weekday - 1];
  final month = months[date.month - 1];
  return '$weekday, $month ${date.day}';
}

int _projectStatusRank(ProjectStatus status) {
  return switch (status) {
    ProjectStatus.inProgress => 0,
    ProjectStatus.pending => 1,
    ProjectStatus.completed => 2,
  };
}

DashboardInspectionProject? _findHighestRatedProject(
  List<DashboardInspectionProject> inspectionProjects,
) {
  final ratedProjects = inspectionProjects
      .where((project) => project.overallScore != null)
      .toList();
  if (ratedProjects.isEmpty) {
    return null;
  }

  ratedProjects.sort((a, b) => b.overallScore!.compareTo(a.overallScore!));
  return ratedProjects.first;
}

DashboardInspectionProject? _findLowestRatedProject(
  List<DashboardInspectionProject> inspectionProjects,
) {
  final ratedProjects = inspectionProjects
      .where((project) => project.overallScore != null)
      .toList();
  if (ratedProjects.isEmpty) {
    return null;
  }

  ratedProjects.sort((a, b) => a.overallScore!.compareTo(b.overallScore!));
  return ratedProjects.first;
}

int? _calculateOverallAverageScore(
  List<DashboardInspectionProject> inspectionProjects,
) {
  final scores = inspectionProjects
      .map((project) => project.overallScore)
      .whereType<int>()
      .toList();
  if (scores.isEmpty) {
    return null;
  }

  final average = scores.reduce((sum, value) => sum + value) / scores.length;
  return average.round();
}

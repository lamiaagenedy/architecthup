import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/dashboard_strings.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../projects/domain/entities/project_list_item.dart';
import '../../../projects/presentation/providers/projects_provider.dart';
import '../providers/dashboard_operations_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_attention_section.dart';
import '../widgets/dashboard_category_summary_section.dart';
import '../widgets/dashboard_hero_section.dart';
import '../widgets/dashboard_metric_card.dart';
import '../widgets/dashboard_my_tasks_section.dart';
import '../widgets/dashboard_section_header.dart';
import '../widgets/dashboard_state_views.dart';
import '../widgets/score_circle.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardOperationsViewModelProvider);
    final currentUser = ref.watch(currentUserProvider);

    return dashboardAsync.when(
      data: (viewModel) {
        if (viewModel.progressProjects.isEmpty) {
          return const DashboardEmptyView();
        }

        return _DashboardOperationsContent(
          viewModel: viewModel,
          userName: currentUser?.name ?? DashboardStrings.defaultUserName,
          onRefresh: () async {
            ref.invalidate(projectsListProvider);
            ref.invalidate(dashboardSnapshotProvider);
            await ref.read(projectsListProvider.future);
          },
          onOpenProjects: () {
            context.go(RouteNames.projects);
          },
          onOpenTasks: () {
            context.go(RouteNames.tasks);
          },
          onOpenMap: () {
            context.go(RouteNames.map);
          },
          onOpenProfile: () {
            context.go(RouteNames.profile);
          },
          onOpenProjectChecklist: (project) {
            context.go(RouteNames.projectDetails(project.id), extra: project);
          },
          onOpenCategoryProjects: () {
            ref.read(projectsQueryProvider.notifier).state = '';
            ref.read(projectsStatusFilterProvider.notifier).state = null;
            context.go(RouteNames.projects);
          },
        );
      },
      loading: DashboardLoadingView.new,
      error: (error, stackTrace) => DashboardErrorView(
        onRetry: () => ref.refresh(dashboardSnapshotProvider),
      ),
    );
  }
}

class _DashboardOperationsContent extends StatelessWidget {
  const _DashboardOperationsContent({
    required this.viewModel,
    required this.userName,
    required this.onRefresh,
    required this.onOpenProjects,
    required this.onOpenTasks,
    required this.onOpenMap,
    required this.onOpenProfile,
    required this.onOpenProjectChecklist,
    required this.onOpenCategoryProjects,
  });

  final DashboardOperationsViewModel viewModel;
  final String userName;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenProjects;
  final VoidCallback onOpenTasks;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenProfile;
  final ValueChanged<ProjectListItem> onOpenProjectChecklist;
  final VoidCallback onOpenCategoryProjects;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: DesignTokens.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardHeaderSection(
                  userName: userName,
                  dateLabel: viewModel.headerDateLabel,
                ),
                const SizedBox(height: AppDimensions.xl),
                _InspectionPerformanceSection(
                  viewModel: viewModel,
                  onOpenProjects: onOpenProjects,
                  onOpenProjectChecklist: onOpenProjectChecklist,
                ),
                const SizedBox(height: AppDimensions.xl),
                DashboardCategorySummarySection(
                  categoryAverages: viewModel.categoryAverages,
                  onOpenCategoryProjects: onOpenCategoryProjects,
                ),
                const SizedBox(height: AppDimensions.xl),
                DashboardAttentionSection(
                  attentionItems: viewModel.attentionItems,
                  onOpenProjectChecklist: onOpenProjectChecklist,
                ),
                const SizedBox(height: AppDimensions.xl),
                _QuickActionsSection(
                  onOpenProjects: onOpenProjects,
                  onOpenTasks: onOpenTasks,
                  onOpenMap: onOpenMap,
                  onOpenProfile: onOpenProfile,
                ),
                const SizedBox(height: AppDimensions.xl),
                _PersonalTasksSnapshotSection(
                  tasks: viewModel.pendingTasks,
                  onOpenTasks: onOpenTasks,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardHeaderSection extends StatelessWidget {
  const _DashboardHeaderSection({
    required this.userName,
    required this.dateLabel,
  });

  final String userName;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return DashboardHeroSection(userName: userName, dateLabel: dateLabel);
  }
}

class _InspectionPerformanceSection extends StatelessWidget {
  const _InspectionPerformanceSection({
    required this.viewModel,
    required this.onOpenProjects,
    required this.onOpenProjectChecklist,
  });

  final DashboardOperationsViewModel viewModel;
  final VoidCallback onOpenProjects;
  final ValueChanged<ProjectListItem> onOpenProjectChecklist;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardSectionHeader(
          eyebrow: DashboardStrings.sectionInspectionEyebrow,
          title: DashboardStrings.sectionInspectionTitle,
          subtitle: DashboardStrings.sectionInspectionSubtitle,
        ),
        const SizedBox(height: AppDimensions.lg),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _HighestRatedProjectCard(
                  project: viewModel.highestRatedProject,
                  onOpenProjects: onOpenProjects,
                  onOpenProjectChecklist: onOpenProjectChecklist,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _LowestRatedProjectCard(
                  project: viewModel.lowestRatedProject,
                  onOpenProjects: onOpenProjects,
                  onOpenProjectChecklist: onOpenProjectChecklist,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _InspectionsTodayCard(
                  inspectedToday: viewModel.inspectedToday,
                  totalProjects: viewModel.totalProjects,
                  onTap: onOpenProjects,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _OverallAverageScoreCard(
                  score: viewModel.overallAverageScore,
                  onTap: onOpenProjects,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HighestRatedProjectCard extends StatelessWidget {
  const _HighestRatedProjectCard({
    required this.project,
    required this.onOpenProjects,
    required this.onOpenProjectChecklist,
  });

  final DashboardInspectionProject? project;
  final VoidCallback onOpenProjects;
  final ValueChanged<ProjectListItem> onOpenProjectChecklist;

  @override
  Widget build(BuildContext context) {
    final tintColor = Theme.of(context).colorScheme.secondary;

    return _InspectionMetricCard(
      tintColor: tintColor,
      label: DashboardStrings.highestRatedLabel,
      title: project?.project.name ?? DashboardStrings.noInspectionsYet,
      subtitle: DashboardStrings.dashboardMetricBestHelper,
      icon: Icons.emoji_events_rounded,
      onTap: project == null
          ? onOpenProjects
          : () => onOpenProjectChecklist(project!.project),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScoreCircle(
                score: project?.overallScore,
                foregroundColor: tintColor,
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Text(
                  project?.overallScore == null
                      ? DashboardStrings.noInspectionsYet
                      : '${project!.overallScore}% quality score',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LowestRatedProjectCard extends StatelessWidget {
  const _LowestRatedProjectCard({
    required this.project,
    required this.onOpenProjects,
    required this.onOpenProjectChecklist,
  });

  final DashboardInspectionProject? project;
  final VoidCallback onOpenProjects;
  final ValueChanged<ProjectListItem> onOpenProjectChecklist;

  @override
  Widget build(BuildContext context) {
    final tintColor = Theme.of(context).colorScheme.error;

    return _InspectionMetricCard(
      tintColor: tintColor,
      label: DashboardStrings.lowestRatedLabel,
      title: project?.project.name ?? DashboardStrings.noInspectionsYet,
      subtitle: DashboardStrings.dashboardMetricLowestHelper,
      icon: Icons.warning_amber_rounded,
      onTap: project == null
          ? onOpenProjects
          : () => onOpenProjectChecklist(project!.project),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScoreCircle(
                score: project?.overallScore,
                foregroundColor: tintColor,
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Text(
                  project?.overallScore == null
                      ? DashboardStrings.noInspectionsYet
                      : '${project!.overallScore}% quality score',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InspectionsTodayCard extends StatelessWidget {
  const _InspectionsTodayCard({
    required this.inspectedToday,
    required this.totalProjects,
    required this.onTap,
  });

  final int inspectedToday;
  final int totalProjects;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _InspectionMetricCard(
      tintColor: Theme.of(context).colorScheme.primary,
      label: DashboardStrings.inspectionsToday,
      title: '$inspectedToday ${DashboardStrings.inspectedSuffix}',
      subtitle: DashboardStrings.dashboardMetricTodayHelper,
      icon: Icons.checklist_rounded,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$inspectedToday',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            '$inspectedToday of $totalProjects ${DashboardStrings.projectsLabel}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverallAverageScoreCard extends StatelessWidget {
  const _OverallAverageScoreCard({required this.score, required this.onTap});

  final int? score;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final toneColor = _scoreToneColor(context, score ?? 0);

    return _InspectionMetricCard(
      tintColor: toneColor,
      label: DashboardStrings.overallScoreLabel,
      title: DashboardStrings.overallScoreLabel,
      subtitle: DashboardStrings.dashboardMetricOverallHelper,
      icon: Icons.analytics_rounded,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            score == null ? '-' : '$score',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: score == null
                  ? Theme.of(context).colorScheme.onSurface
                  : toneColor,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            score == null
                ? DashboardStrings.noInspectionsYet
                : 'Across all sites',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InspectionMetricCard extends StatelessWidget {
  const _InspectionMetricCard({
    required this.child,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.label,
    required this.icon,
    required this.tintColor,
  });

  final Widget child;
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final String label;
  final IconData icon;
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    return DashboardMetricCard(
      title: title,
      subtitle: subtitle,
      label: label,
      icon: icon,
      tintColor: tintColor,
      onTap: onTap,
      child: child,
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({
    required this.onOpenProjects,
    required this.onOpenTasks,
    required this.onOpenMap,
    required this.onOpenProfile,
  });

  final VoidCallback onOpenProjects;
  final VoidCallback onOpenTasks;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardSectionHeader(
          eyebrow: DashboardStrings.sectionQuickActionsEyebrow,
          title: DashboardStrings.sectionQuickActionsTitle,
          subtitle: DashboardStrings.sectionQuickActionsSubtitle,
        ),
        const SizedBox(height: AppDimensions.lg),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _QuickActionPill(
                icon: Icons.apartment_rounded,
                label: DashboardStrings.actionProjects,
                onTap: onOpenProjects,
              ),
              const SizedBox(width: AppDimensions.sm),
              _QuickActionPill(
                icon: Icons.task_alt_rounded,
                label: DashboardStrings.actionTasks,
                onTap: onOpenTasks,
              ),
              const SizedBox(width: AppDimensions.sm),
              _QuickActionPill(
                icon: Icons.map_rounded,
                label: DashboardStrings.actionMap,
                onTap: onOpenMap,
              ),
              const SizedBox(width: AppDimensions.sm),
              _QuickActionPill(
                icon: Icons.person_rounded,
                label: DashboardStrings.actionProfile,
                onTap: onOpenProfile,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionPill extends StatelessWidget {
  const _QuickActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm,
          ),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.onPrimary, size: AppDimensions.md),
              const SizedBox(width: AppDimensions.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonalTasksSnapshotSection extends StatelessWidget {
  const _PersonalTasksSnapshotSection({
    required this.tasks,
    required this.onOpenTasks,
  });

  final List<DashboardTaskSnapshotItem> tasks;
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context) {
    return DashboardMyTasksSection(tasks: tasks, onOpenTasks: onOpenTasks);
  }
}

Color _scoreToneColor(BuildContext context, int score) {
  final colorScheme = Theme.of(context).colorScheme;

  if (score >= 90) {
    return colorScheme.secondary;
  }
  if (score >= 75) {
    return AppColors.accent;
  }

  return colorScheme.error;
}

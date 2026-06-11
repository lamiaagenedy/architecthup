import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/dashboard_strings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../projects/domain/entities/project_list_item.dart';
import '../../../projects/presentation/providers/projects_provider.dart';
import '../providers/dashboard_operations_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_attention_section.dart';
import '../widgets/dashboard_category_summary_section.dart';
import '../widgets/dashboard_hero_section.dart';
import '../widgets/dashboard_metric_card.dart';
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
        onRetry: () {
          ref.invalidate(projectsListProvider);
          ref.invalidate(dashboardSnapshotProvider);
        },
        message: _resolveErrorMessage(error),
      ),
    );
  }
}

String _resolveErrorMessage(Object error) {
  final message = error.toString().trim();
  if (message.isEmpty) {
    return 'Something went wrong while loading your dashboard.';
  }
  return message;
}

class _DashboardOperationsContent extends StatelessWidget {
  const _DashboardOperationsContent({
    required this.viewModel,
    required this.userName,
    required this.onRefresh,
    required this.onOpenProjects,
    required this.onOpenProfile,
    required this.onOpenProjectChecklist,
    required this.onOpenCategoryProjects,
  });

  final DashboardOperationsViewModel viewModel;
  final String userName;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenProjects;
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
            padding: AppDimensions.screenPadding,
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
        _ResponsiveMetricRow(
          leading: _HighestRatedProjectCard(
            project: viewModel.highestRatedProject,
            onOpenProjects: onOpenProjects,
            onOpenProjectChecklist: onOpenProjectChecklist,
          ),
          trailing: _LowestRatedProjectCard(
            project: viewModel.lowestRatedProject,
            onOpenProjects: onOpenProjects,
            onOpenProjectChecklist: onOpenProjectChecklist,
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        _ResponsiveMetricRow(
          leading: _InspectionsTodayCard(
            inspectedToday: viewModel.inspectedToday,
            totalProjects: viewModel.totalProjects,
            onTap: onOpenProjects,
          ),
          trailing: _OverallAverageScoreCard(
            score: viewModel.overallAverageScore,
            onTap: onOpenProjects,
          ),
        ),
      ],
    );
  }
}

class _ResponsiveMetricRow extends StatelessWidget {
  const _ResponsiveMetricRow({required this.leading, required this.trailing});

  final Widget leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 620;
        if (isNarrow) {
          return Column(
            children: [
              leading,
              const SizedBox(height: AppDimensions.md),
              trailing,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: leading),
            const SizedBox(width: AppDimensions.md),
            Expanded(child: trailing),
          ],
        );
      },
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

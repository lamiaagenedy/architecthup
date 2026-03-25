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
import '../../../projects/presentation/widgets/project_status_badge.dart';
import '../providers/dashboard_operations_provider.dart';
import '../providers/dashboard_provider.dart';
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
            ref.read(projectsQueryProvider.notifier).state = project.name;
            ref.read(projectsStatusFilterProvider.notifier).state = null;
            context.go(RouteNames.projects);
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
                  activeProjectCount: viewModel.activeProjectCount,
                  pendingTaskCount: viewModel.pendingTaskCount,
                  onOpenProjects: onOpenProjects,
                  onOpenTasks: onOpenTasks,
                ),
                const SizedBox(height: AppDimensions.xl),
                _InspectionPerformanceSection(
                  viewModel: viewModel,
                  onOpenProjects: onOpenProjects,
                  onOpenProjectChecklist: onOpenProjectChecklist,
                ),
                const SizedBox(height: AppDimensions.xl),
                _ProjectsProgressSection(
                  projects: viewModel.progressProjects,
                  inspectionProjects: viewModel.inspectionProjects,
                  onOpenProjects: onOpenProjects,
                  onOpenProjectChecklist: onOpenProjectChecklist,
                ),
                const SizedBox(height: AppDimensions.xl),
                _CategoryPerformanceSection(
                  categoryAverages: viewModel.categoryAverages,
                  onOpenCategoryProjects: onOpenCategoryProjects,
                ),
                const SizedBox(height: AppDimensions.xl),
                _ProjectsNeedingAttentionSection(
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
    required this.activeProjectCount,
    required this.pendingTaskCount,
    required this.onOpenProjects,
    required this.onOpenTasks,
  });

  final String userName;
  final String dateLabel;
  final int activeProjectCount;
  final int pendingTaskCount;
  final VoidCallback onOpenProjects;
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: AppDimensions.xs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: AppDimensions.sm,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: AppDimensions.xs),
                    Text(
                      DashboardStrings.statusLive,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            '${DashboardStrings.greetingPrefix}, $userName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.94),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            DashboardStrings.greetingHeadline,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            DashboardStrings.greetingSubhead,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: _HeaderSummaryChip(
                  label: DashboardStrings.summaryActiveProjects,
                  value: '$activeProjectCount',
                  onTap: onOpenProjects,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: _HeaderSummaryChip(
                  label: DashboardStrings.summaryPendingTasks,
                  value: '$pendingTaskCount',
                  onTap: onOpenTasks,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderSummaryChip extends StatelessWidget {
  const _HeaderSummaryChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.onPrimary.withValues(alpha: 0.13),
      borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm,
          ),
          child: Row(
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppDimensions.xs),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          title: DashboardStrings.sectionInspectionTitle,
          subtitle: DashboardStrings.sectionInspectionSubtitle,
        ),
        const SizedBox(height: AppDimensions.md),
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
    return _InspectionMetricCard(
      onTap: project == null
          ? onOpenProjects
          : () => onOpenProjectChecklist(project!.project),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Icon(Icons.emoji_events_rounded),
          ),
          const SizedBox(height: AppDimensions.sm),
          ScoreCircle(score: project?.overallScore),
          const SizedBox(height: AppDimensions.sm),
          Text(
            project?.project.name ?? DashboardStrings.noInspectionsYet,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            DashboardStrings.highestRatedLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
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
    return _InspectionMetricCard(
      onTap: project == null
          ? onOpenProjects
          : () => onOpenProjectChecklist(project!.project),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          ScoreCircle(
            score: project?.overallScore,
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            project?.project.name ?? DashboardStrings.noInspectionsYet,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            DashboardStrings.lowestRatedLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
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
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.checklist_rounded),
          const SizedBox(height: AppDimensions.sm),
          Text(
            '$inspectedToday',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            DashboardStrings.inspectedToday,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            '$inspectedToday of $totalProjects ${DashboardStrings.projectsLabel}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    return _InspectionMetricCard(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            color: _scoreToneColor(context, score ?? 0),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            score == null ? '-' : '$score',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: score == null
                  ? Theme.of(context).colorScheme.onSurface
                  : _scoreToneColor(context, score!),
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            DashboardStrings.overallScoreLabel,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _InspectionMetricCard extends StatelessWidget {
  const _InspectionMetricCard({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ProjectsProgressSection extends StatelessWidget {
  const _ProjectsProgressSection({
    required this.projects,
    required this.inspectionProjects,
    required this.onOpenProjects,
    required this.onOpenProjectChecklist,
  });

  final List<ProjectListItem> projects;
  final List<DashboardInspectionProject> inspectionProjects;
  final VoidCallback onOpenProjects;
  final ValueChanged<ProjectListItem> onOpenProjectChecklist;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: DashboardStrings.sectionProgressTitle,
          subtitle: DashboardStrings.sectionProgressSubtitle,
          trailing: TextButton(
            onPressed: onOpenProjects,
            child: const Text(DashboardStrings.viewAll),
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              children: projects
                  .map(
                    (project) => Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.md),
                      child: _ProjectProgressRow(
                        project: project,
                        inspectionProject: inspectionProjects.firstWhere(
                          (item) => item.project.id == project.id,
                        ),
                        onTap: () => onOpenProjectChecklist(project),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectProgressRow extends StatelessWidget {
  const _ProjectProgressRow({
    required this.project,
    required this.inspectionProject,
    required this.onTap,
  });

  final ProjectListItem project;
  final DashboardInspectionProject inspectionProject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  if (inspectionProject.overallScore != null)
                    Text(
                      '${inspectionProject.overallScore}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else
                    Text(
                      '-',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(width: AppDimensions.sm),
                  ProjectStatusBadge(status: project.status),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: project.progress,
                  minHeight: AppDimensions.sm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPerformanceSection extends StatelessWidget {
  const _CategoryPerformanceSection({
    required this.categoryAverages,
    required this.onOpenCategoryProjects,
  });

  final List<DashboardCategoryScore> categoryAverages;
  final VoidCallback onOpenCategoryProjects;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardSectionHeader(
          title: DashboardStrings.sectionCategoryTitle,
          subtitle: DashboardStrings.sectionCategorySubtitle,
        ),
        const SizedBox(height: AppDimensions.md),
        GridView.builder(
          itemCount: categoryAverages.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppDimensions.md,
            crossAxisSpacing: AppDimensions.md,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, index) {
            final item = categoryAverages[index];

            return _CategoryPerformanceCard(
              item: item,
              onTap: onOpenCategoryProjects,
            );
          },
        ),
      ],
    );
  }
}

class _CategoryPerformanceCard extends StatelessWidget {
  const _CategoryPerformanceCard({required this.item, required this.onTap});

  final DashboardCategoryScore item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final toneColor = _scoreToneColor(context, item.score);

    return Material(
      color: toneColor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
            border: Border.all(color: toneColor.withValues(alpha: 0.45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.category.icon, color: toneColor),
              const SizedBox(height: AppDimensions.sm),
              Text(
                item.category.label,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${item.score}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: toneColor,
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

class _ProjectsNeedingAttentionSection extends StatelessWidget {
  const _ProjectsNeedingAttentionSection({
    required this.attentionItems,
    required this.onOpenProjectChecklist,
  });

  final List<DashboardInspectionProject> attentionItems;
  final ValueChanged<ProjectListItem> onOpenProjectChecklist;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardSectionHeader(
          title: DashboardStrings.sectionAttentionTitle,
          subtitle: DashboardStrings.sectionAttentionSubtitle,
        ),
        const SizedBox(height: AppDimensions.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: attentionItems.isEmpty
                ? Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: Text(
                          DashboardStrings.allProjectsPerformingWell,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: attentionItems
                        .map(
                          (item) => _AttentionProjectRow(
                            item: item,
                            onTap: () => onOpenProjectChecklist(item.project),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }
}

class _AttentionProjectRow extends StatelessWidget {
  const _AttentionProjectRow({required this.item, required this.onTap});

  final DashboardInspectionProject item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final underperforming = item.categoryScores.firstWhere(
      (score) => score.score < 75,
      orElse: () => item.categoryScores.first,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.project.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${underperforming.category.label}: ${underperforming.score}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
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
          title: DashboardStrings.sectionQuickActionsTitle,
          subtitle: DashboardStrings.sectionQuickActionsSubtitle,
        ),
        const SizedBox(height: AppDimensions.md),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: DashboardStrings.sectionMyTasksTitle,
          subtitle: DashboardStrings.sectionMyTasksSubtitle,
          trailing: TextButton(
            onPressed: onOpenTasks,
            child: const Text(DashboardStrings.viewAllTasks),
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: tasks.isEmpty
                ? Text(
                    DashboardStrings.noPendingTasksToday,
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                : Column(
                    children: tasks
                        .map(
                          (task) =>
                              _TaskSnapshotRow(task: task, onTap: onOpenTasks),
                        )
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }
}

class _TaskSnapshotRow extends StatelessWidget {
  const _TaskSnapshotRow({required this.task, required this.onTap});

  final DashboardTaskSnapshotItem task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
          child: Row(
            children: [
              Checkbox(value: false, onChanged: (_) => onTap()),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      task.projectName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

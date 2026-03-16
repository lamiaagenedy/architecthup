import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_list_tile_card.dart';
import '../widgets/dashboard_project_card.dart';
import '../widgets/dashboard_section_header.dart';
import '../widgets/dashboard_state_views.dart';
import '../widgets/dashboard_summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardSnapshotProvider);
    final currentUser = ref.watch(currentUserProvider);

    return dashboardAsync.when(
      data: (snapshot) {
        if (snapshot.activeProjects.isEmpty) {
          return const DashboardEmptyView();
        }

        return _DashboardContent(
          snapshot: snapshot,
          userName: currentUser?.name ?? 'Team lead',
          onRefresh: () => ref.refresh(dashboardSnapshotProvider.future),
        );
      },
      loading: DashboardLoadingView.new,
      error: (error, stackTrace) => DashboardErrorView(
        onRetry: () => ref.refresh(dashboardSnapshotProvider),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.snapshot,
    required this.userName,
    required this.onRefresh,
  });

  final DashboardSnapshot snapshot;
  final String userName;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final summary = snapshot.projectSummary;

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: DesignTokens.pagePadding,
          children: [
            _DashboardWelcomeCard(userName: userName, summary: summary),
            const SizedBox(height: AppDimensions.xl),
            const DashboardSectionHeader(
              title: 'Project summary',
              subtitle:
                  'Quick visibility into site health and today’s workload.',
            ),
            const SizedBox(height: AppDimensions.md),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.md,
              mainAxisSpacing: AppDimensions.md,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.16,
              children: [
                DashboardSummaryCard(
                  label: 'Total projects',
                  value: '${summary.totalProjects}',
                  caption: '${summary.onTrackProjects} currently on track',
                  tone: DashboardTone.neutral,
                ),
                DashboardSummaryCard(
                  label: 'At risk',
                  value: '${summary.atRiskProjects}',
                  caption: 'Needs coordination this week',
                  tone: DashboardTone.caution,
                ),
                DashboardSummaryCard(
                  label: 'Due today',
                  value: '${summary.tasksDueToday}',
                  caption: 'Task commitments needing follow-up',
                  tone: DashboardTone.critical,
                ),
                DashboardSummaryCard(
                  label: 'Maintenance open',
                  value: '${summary.openMaintenanceItems}',
                  caption: 'Scheduled servicing still pending',
                  tone: DashboardTone.positive,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            const DashboardSectionHeader(
              title: 'Active projects',
              subtitle:
                  'Most important project signals for the current workday.',
            ),
            const SizedBox(height: AppDimensions.md),
            ...snapshot.activeProjects.map(
              (project) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.md),
                child: DashboardProjectCard(project: project),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            const DashboardSectionHeader(
              title: 'Quick status',
              subtitle:
                  'Operational indicators that help teams scan today’s risks.',
            ),
            const SizedBox(height: AppDimensions.md),
            ...snapshot.statusIndicators.map(
              (indicator) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.md),
                child: DashboardSummaryCard(
                  label: indicator.label,
                  value: indicator.value,
                  caption: indicator.caption,
                  tone: indicator.tone,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            const DashboardSectionHeader(
              title: 'Upcoming work',
              subtitle:
                  'A compact preview of tasks and maintenance requiring attention.',
            ),
            const SizedBox(height: AppDimensions.md),
            ...snapshot.upcomingItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.md),
                child: DashboardListTileCard.workItem(item: item),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            const DashboardSectionHeader(
              title: 'Recent updates',
              subtitle:
                  'Latest field and coordination changes across active work.',
            ),
            const SizedBox(height: AppDimensions.md),
            ...snapshot.recentUpdates.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.md),
                child: DashboardListTileCard.update(item: item),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            const DashboardSectionHeader(
              title: 'Quick actions',
              subtitle:
                  'Entry points for the next workflows that will be wired later.',
            ),
            const SizedBox(height: AppDimensions.md),
            SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.quickActions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppDimensions.md),
                itemBuilder: (context, index) {
                  final action = snapshot.quickActions[index];

                  return _QuickActionCard(action: action);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardWelcomeCard extends StatelessWidget {
  const _DashboardWelcomeCard({required this.userName, required this.summary});

  final String userName;
  final DashboardProjectSummary summary;

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
          Text(
            'Good morning, $userName',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'You have ${summary.tasksDueToday} due items and ${summary.atRiskProjects} project needing closer attention today.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          Row(
            children: [
              Expanded(
                child: _WelcomeMetric(
                  label: 'On track',
                  value: '${summary.onTrackProjects}',
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _WelcomeMetric(
                  label: 'Attention',
                  value:
                      '${summary.atRiskProjects + summary.needsAttentionProjects}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WelcomeMetric extends StatelessWidget {
  const _WelcomeMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final DashboardQuickAction action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(action.icon),
          const SizedBox(height: AppDimensions.md),
          Text(
            action.label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            action.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

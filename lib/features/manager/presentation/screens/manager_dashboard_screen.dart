import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/route_names.dart';
import '../../../../app/di/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_grade_badge.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../providers/manager_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../quality/presentation/widgets/stats_card_widget.dart';

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(managerDashboardProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentUser?.name ?? 'Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () => context.go(RouteNames.managerUsers),
          ),
          IconButton(
            icon: const Icon(Icons.apartment_outlined),
            onPressed: () => context.go(RouteNames.managerProjects),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              await ref.read(authControllerProvider.notifier).logout();
              await ref.read(authLocalDatasourceProvider).clearSession();
              context.go(RouteNames.login);
            },
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (data) {
          final topProjects = (data['top_projects'] as List? ?? [])
              .cast<Map<String, dynamic>>();
          final bottomProjects = (data['bottom_projects'] as List? ?? [])
              .cast<Map<String, dynamic>>();
          final incomplete = (data['incomplete_projects'] as List? ?? [])
              .cast<Map<String, dynamic>>();
          final serviceAvgs = (data['per_service_average'] as List? ?? [])
              .cast<Map<String, dynamic>>();
          final totalProjects = (data['total_projects'] as num?) ?? 0;
          final totalSupervisors = (data['total_supervisors'] as num?) ?? 0;
          final averageScore = ((data['average_score'] as num?) ?? 0) * 100;
          final completionRate = totalProjects == 0
              ? 0
              : ((totalProjects - incomplete.length) / totalProjects) * 100;
          final gradeLabel = _gradeLabel(averageScore);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(managerDashboardProvider);
              await ref.read(managerDashboardProvider.future);
            },
            child: ListView(
              padding: AppDimensions.screenPadding,
              children: [
                Text(
                  'Welcome back, ${currentUser?.name ?? 'Manager'}',
                  style: AppTextStyles.pageTitle,
                ),
                const SizedBox(height: AppDimensions.spacingSection),
                Row(
                  children: [
                    Expanded(
                      child: StatsCardWidget(
                        title: 'Total Projects',
                        value: '$totalProjects',
                        subtitle: 'Tracked this cycle',
                        icon: Icons.apartment_outlined,
                        iconColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: StatsCardWidget(
                        title: 'Supervisors',
                        value: '$totalSupervisors',
                        subtitle: 'Active supervisors',
                        icon: Icons.people_outline,
                        iconColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingCard),
                Row(
                  children: [
                    Expanded(
                      child: StatsCardWidget(
                        title: 'Average Score',
                        value: '${averageScore.toStringAsFixed(1)}%',
                        subtitle: 'Across all projects',
                        icon: Icons.assessment_outlined,
                        iconColor: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: StatsCardWidget(
                        title: 'Completion Rate',
                        value: '${completionRate.toStringAsFixed(0)}%',
                        subtitle: 'Projects closed',
                        icon: Icons.check_circle_outline,
                        iconColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingSection),
                _PerformanceCard(gradeLabel: gradeLabel, score: averageScore),
                const SizedBox(height: AppDimensions.spacingSection),
                Text('Top 5 Projects', style: AppTextStyles.sectionTitle),
                const SizedBox(height: AppDimensions.sm),
                ...topProjects.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.md,
                        vertical: AppDimensions.sm,
                      ),
                      child: Text(
                        p['name'] as String? ?? '',
                        style: AppTextStyles.body,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSection),
                Text('Bottom 5 Projects', style: AppTextStyles.sectionTitle),
                const SizedBox(height: AppDimensions.sm),
                ...bottomProjects.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.md,
                        vertical: AppDimensions.sm,
                      ),
                      child: Text(
                        p['name'] as String? ?? '',
                        style: AppTextStyles.body,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSection),
                Text('Service Performance', style: AppTextStyles.sectionTitle),
                const SizedBox(height: AppDimensions.sm),
                ...serviceAvgs.map(
                  (service) => Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.md,
                        vertical: AppDimensions.sm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              service['service_name'] as String? ?? 'Service',
                              style: AppTextStyles.body,
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: LinearProgressIndicator(
                              value: ((service['average_score'] as num?) ?? 0)
                                  .toDouble(),
                              minHeight: 8,
                              backgroundColor: AppColors.divider,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.gradeLabel, required this.score});

  final String gradeLabel;
  final num score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimensions.cardPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A90D9), Color(0xFF6EB5FF)],
        ),
      ),
      child: Row(
        children: [
          const AppIconContainer(
            icon: Icons.stars_outlined,
            color: Colors.white,
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Performance',
                  style: AppTextStyles.secondary.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  '${score.toStringAsFixed(1)}%',
                  style: AppTextStyles.pageTitle.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          AppGradeBadge(label: gradeLabel, score: score),
        ],
      ),
    );
  }
}

String _gradeLabel(num score) {
  if (score >= 90) return 'A';
  if (score >= 80) return 'B';
  if (score >= 70) return 'C';
  if (score >= 60) return 'D';
  return 'F';
}

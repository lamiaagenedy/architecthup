import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/route_names.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../providers/manager_provider.dart';
import '../../../quality/presentation/widgets/stats_card_widget.dart';

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(managerDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () => context.go(RouteNames.managerUsers),
          ),
          IconButton(
            icon: const Icon(Icons.apartment_outlined),
            onPressed: () => context.go(RouteNames.managerProjects),
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

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(managerDashboardProvider);
              await ref.read(managerDashboardProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.lg),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatsCardWidget(
                        title: 'Projects',
                        value: '${data['total_projects'] ?? 0}',
                        subtitle: 'Total projects',
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: StatsCardWidget(
                        title: 'Supervisors',
                        value: '${data['total_supervisors'] ?? 0}',
                        subtitle: 'Active supervisors',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),
                StatsCardWidget(
                  title: 'Average Score',
                  value:
                      '${(((data['average_score'] as num?) ?? 0) * 100).toStringAsFixed(1)}%',
                  subtitle: 'Across all projects',
                ),
                const SizedBox(height: AppDimensions.lg),
                Text('Top 5 Projects', style: Theme.of(context).textTheme.titleMedium),
                ...topProjects.map((p) => ListTile(title: Text(p['name'] as String? ?? ''))),
                const SizedBox(height: AppDimensions.md),
                Text('Bottom 5 Projects', style: Theme.of(context).textTheme.titleMedium),
                ...bottomProjects.map((p) => ListTile(title: Text(p['name'] as String? ?? ''))),
                const SizedBox(height: AppDimensions.md),
                Text('Incomplete Projects', style: Theme.of(context).textTheme.titleMedium),
                ...incomplete.map(
                  (p) => ListTile(
                    title: Text(p['name'] as String? ?? ''),
                    subtitle: Text('${p['progress'] ?? 0}% complete'),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                Text('Service Performance', style: Theme.of(context).textTheme.titleMedium),
                ...serviceAvgs.map(
                  (service) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: LinearProgressIndicator(
                      value: ((service['average_score'] as num?) ?? 0).toDouble(),
                      minHeight: 12,
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

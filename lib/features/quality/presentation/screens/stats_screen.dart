import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../providers/quality_api_provider.dart';
import '../widgets/stats_card_widget.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(projectStatsProvider(projectId));

    return statsAsync.when(
      data: (stats) => ListView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        children: [
          StatsCardWidget(
            title: 'Overall',
            value: '${stats.overallProgress}%',
            subtitle: '${stats.grade} • ${(stats.overallScore * 100).toStringAsFixed(1)}%',
          ),
          const SizedBox(height: AppDimensions.md),
          ...stats.services.map(
            (service) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.sm),
              child: StatsCardWidget(
                title: service.name,
                value: '${service.progress}%',
                subtitle:
                    '${service.grade} • ${(service.rating * 100).toStringAsFixed(1)}%',
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
    );
  }
}

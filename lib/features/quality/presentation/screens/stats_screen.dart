import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_grade_badge.dart';
import '../providers/quality_api_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(projectStatsProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppColors.primary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Statistics'),
      ),
      body: statsAsync.when(
        data: (stats) => ListView(
          padding: AppDimensions.screenPadding,
          children: [
            AppCard(
              child: Column(
                children: [
                  _ProgressCircle(score: stats.overallProgress),
                  const SizedBox(height: AppDimensions.sm),
                  AppGradeBadge(
                    label: stats.grade,
                    score: stats.overallScore * 100,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    'Overall ${(stats.overallScore * 100).toStringAsFixed(1)}%',
                    style: AppTextStyles.secondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSection),
            ...stats.services.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service.name,
                              style: AppTextStyles.cardTitle,
                            ),
                          ),
                          AppGradeBadge(
                            label: service.grade,
                            score: service.rating * 100,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      LinearProgressIndicator(
                        value: (service.progress / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: AppColors.divider,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class _ProgressCircle extends StatelessWidget {
  const _ProgressCircle({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final progress = (score / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 10,
            backgroundColor: AppColors.divider,
            color: AppColors.primary,
          ),
          Text('$score%', style: AppTextStyles.pageTitle),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_grade_badge.dart';
import '../../domain/entities/project_list_item.dart';

class ProjectListItemCard extends StatelessWidget {
  const ProjectListItemCard({
    required this.project,
    required this.onTap,
    super.key,
  });

  final ProjectListItem project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progressPercent = (project.progress * 100).round();

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 17),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  project.companyName ?? project.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.secondary,
                ),
                const SizedBox(height: AppDimensions.sm),
                _ProjectProgressBlock(
                  progress: project.progress,
                  progressPercent: progressPercent,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Column(
            children: [
              _ProgressCircle(progress: project.progress),
              const SizedBox(height: AppDimensions.sm),
              AppGradeBadge(
                label: project.grade ?? '—',
                score: progressPercent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectProgressBlock extends StatelessWidget {
  const _ProjectProgressBlock({
    required this.progress,
    required this.progressPercent,
  });

  final double progress;
  final int progressPercent;

  @override
  Widget build(BuildContext context) {
    final progressColor = _progressColor(progressPercent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$progressPercent%', style: AppTextStyles.cardTitle),
        const SizedBox(height: AppDimensions.sm),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Color _progressColor(int progressPercent) {
  if (progressPercent >= 90) {
    return AppColors.success;
  }
  if (progressPercent >= 65) {
    return AppColors.primary;
  }

  return AppColors.warning;
}

class _ProgressCircle extends StatelessWidget {
  const _ProgressCircle({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: 4,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

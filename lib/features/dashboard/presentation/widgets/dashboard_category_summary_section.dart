import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_grade_badge.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../core/constants/dashboard_strings.dart';
import '../providers/dashboard_operations_provider.dart';
import 'dashboard_section_header.dart';

class DashboardCategorySummarySection extends StatelessWidget {
  const DashboardCategorySummarySection({
    required this.categoryAverages,
    required this.onOpenCategoryProjects,
    super.key,
  });

  final List<DashboardCategoryScore> categoryAverages;
  final VoidCallback onOpenCategoryProjects;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionHeader(
            eyebrow: DashboardStrings.sectionCategoryEyebrow,
            title: DashboardStrings.sectionCategoryTitle,
            subtitle: DashboardStrings.sectionCategorySubtitle,
          ),
          const SizedBox(height: AppDimensions.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              const minCardWidth = 156.0;
              final columns = math.max(
                1,
                ((constraints.maxWidth + AppDimensions.md) /
                        (minCardWidth + AppDimensions.md))
                    .floor(),
              );
              final spacing = AppDimensions.md;
              final cardWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: categoryAverages
                    .map(
                      (item) => SizedBox(
                        width: cardWidth,
                        child: _CategoryPerformanceCard(
                          item: item,
                          onTap: onOpenCategoryProjects,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryPerformanceCard extends StatelessWidget {
  const _CategoryPerformanceCard({required this.item, required this.onTap});

  final DashboardCategoryScore item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final toneColor = _scoreToneColor(item.score);

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconContainer(icon: item.category.icon, color: toneColor),
              const Spacer(),
              AppGradeBadge(label: '${item.score}', score: item.score),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            item.category.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle,
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            DashboardStrings.categoryScoreHelper,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.secondary,
          ),
          const SizedBox(height: AppDimensions.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (item.score.clamp(0, 100)) / 100,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              color: toneColor,
            ),
          ),
        ],
      ),
    );
  }
}

Color _scoreToneColor(int score) {
  if (score >= 90) {
    return AppColors.success;
  }
  if (score >= 75) {
    return AppColors.warning;
  }

  return AppColors.danger;
}

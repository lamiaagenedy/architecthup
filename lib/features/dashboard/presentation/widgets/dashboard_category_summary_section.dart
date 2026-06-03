import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
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
    final toneColor = _scoreToneColor(context, item.score);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.surface, toneColor.withValues(alpha: 0.06)],
            ),
            border: Border.all(color: toneColor.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: toneColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item.category.icon,
                        color: toneColor,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    _ScoreBadge(score: item.score, toneColor: toneColor),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                Text(
                  item.category.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  DashboardStrings.categoryScoreHelper,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (item.score.clamp(0, 100)) / 100,
                    minHeight: 8,
                    backgroundColor: toneColor.withValues(alpha: 0.14),
                    valueColor: AlwaysStoppedAnimation<Color>(toneColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.toneColor});

  final int score;
  final Color toneColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: toneColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$score',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: toneColor,
          fontWeight: FontWeight.w800,
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
    return const Color(0xFFF59E0B);
  }

  return colorScheme.error;
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../../core/constants/dashboard_strings.dart';
import '../../../projects/domain/entities/project_list_item.dart';
import '../providers/dashboard_operations_provider.dart';
import 'dashboard_section_header.dart';

class DashboardAttentionSection extends StatelessWidget {
  const DashboardAttentionSection({
    required this.attentionItems,
    required this.onOpenProjectChecklist,
    super.key,
  });

  final List<DashboardInspectionProject> attentionItems;
  final ValueChanged<ProjectListItem> onOpenProjectChecklist;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardSectionHeader(
            eyebrow: DashboardStrings.sectionAttentionEyebrow,
            title: DashboardStrings.sectionAttentionTitle,
            subtitle: DashboardStrings.sectionAttentionSubtitle,
            trailing: _AttentionCountBadge(count: attentionItems.length),
          ),
          const SizedBox(height: AppDimensions.lg),
          if (attentionItems.isEmpty)
            const _AttentionEmptyState()
          else
            Column(
              children: attentionItems
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.md),
                      child: _AttentionProjectCard(
                        item: item,
                        onTap: () => onOpenProjectChecklist(item.project),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _AttentionCountBadge extends StatelessWidget {
  const _AttentionCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final isClear = count == 0;
    final tint = isClear ? AppColors.success : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.14)),
      ),
      child: Text(
        isClear ? DashboardStrings.attentionAllClear : '$count flagged',
        style: AppTextStyles.caption.copyWith(
          color: tint,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AttentionEmptyState extends StatelessWidget {
  const _AttentionEmptyState();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const AppIconContainer(
            icon: Icons.verified_outlined,
            color: AppColors.success,
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Text(
              DashboardStrings.allProjectsPerformingWell,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttentionProjectCard extends StatelessWidget {
  const _AttentionProjectCard({required this.item, required this.onTap});

  final DashboardInspectionProject item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final underperforming = item.categoryScores.firstWhere(
      (score) => score.score < 75,
      orElse: () => item.categoryScores.first,
    );
    final accentColor = underperforming.score < 75
        ? AppColors.danger
        : AppColors.warning;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconContainer(
                icon: Icons.priority_high_outlined,
                color: accentColor,
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.project.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      DashboardStrings.attentionProjectHelper,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _AttentionStatusBadge(accentColor: accentColor),
                  const SizedBox(height: AppDimensions.sm),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.sm,
              vertical: AppDimensions.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _AttentionMetricGroup(
                    label: underperforming.category.label,
                    value: '${underperforming.score}',
                    valueColor: accentColor,
                  ),
                ),
                Container(width: 1, height: 28, color: AppColors.divider),
                const SizedBox(width: AppDimensions.sm),
                _AttentionMetricGroup(
                  label: DashboardStrings.attentionCategoryAverageLabel,
                  value: '${item.averageScore}',
                  valueColor: accentColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttentionStatusBadge extends StatelessWidget {
  const _AttentionStatusBadge({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        DashboardStrings.attentionFlaggedLabel,
        style: AppTextStyles.caption.copyWith(
          color: accentColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AttentionMetricGroup extends StatelessWidget {
  const _AttentionMetricGroup({
    required this.label,
    required this.value,
    required this.valueColor,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final crossAxisAlignment = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

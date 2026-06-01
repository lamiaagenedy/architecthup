import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import 'dashboard_tone_styles.dart';

class DashboardListTileCard extends StatelessWidget {
  DashboardListTileCard.workItem({required DashboardWorkItem item, super.key})
    : _title = item.title,
      _subtitle = item.projectName,
      _supporting = '${item.categoryLabel} • ${item.scheduleLabel}',
      _badge = item.priorityLabel,
      _tone = item.tone;

  DashboardListTileCard.update({required DashboardUpdateItem item, super.key})
    : _title = item.title,
      _subtitle = item.description,
      _supporting = item.timeLabel,
      _badge = null,
      _tone = DashboardTone.neutral;

  final String _title;
  final String _subtitle;
  final String _supporting;
  final String? _badge;
  final DashboardTone _tone;

  @override
  Widget build(BuildContext context) {
    final colors = dashboardToneColors(context, _tone);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(_title, style: AppTextStyles.cardTitle)),
              if (_badge != null) ...[
                const SizedBox(width: AppDimensions.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sm,
                    vertical: AppDimensions.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    _badge,
                    style: AppTextStyles.caption.copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(_subtitle, style: AppTextStyles.body),
          const SizedBox(height: AppDimensions.xs),
          Text(_supporting, style: AppTextStyles.secondary),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
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

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
                  ),
                  child: Text(
                    _badge,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(_subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppDimensions.xs),
          Text(
            _supporting,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

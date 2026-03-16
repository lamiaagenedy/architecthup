import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import 'dashboard_tone_styles.dart';

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({
    required this.label,
    required this.value,
    required this.caption,
    required this.tone,
    super.key,
  });

  final String label;
  final String value;
  final String caption;
  final DashboardTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = dashboardToneColors(context, tone);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: colors.foreground),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            caption,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

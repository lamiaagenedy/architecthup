import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../constants/quality_checklist_items.dart';
import 'quality_checklist_section.dart';

class QualityHousekeepingTab extends StatelessWidget {
  const QualityHousekeepingTab({
    required this.projectId,
    required this.indoorAverage,
    required this.outdoorAverage,
    super.key,
  });

  final String projectId;
  final double indoorAverage;
  final double outdoorAverage;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        AppDimensions.md,
        AppDimensions.lg,
        AppDimensions.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategoryAverageCard(
            label: 'Housekeeping averages',
            value:
                'Indoor ${_formatAverage(indoorAverage)} • Outdoor ${_formatAverage(outdoorAverage)}',
          ),
          const SizedBox(height: AppDimensions.lg),
          QualityChecklistSection(
            projectId: projectId,
            title: 'Indoor Cleaning',
            category: InspectionCategoryKey.housekeepingIndoor,
            items: QualityChecklistItems.housekeepingIndoor,
          ),
          const SizedBox(height: AppDimensions.lg),
          QualityChecklistSection(
            projectId: projectId,
            title: 'Outdoor Cleaning',
            category: InspectionCategoryKey.housekeepingOutdoor,
            items: QualityChecklistItems.housekeepingOutdoor,
          ),
        ],
      ),
    );
  }
}

class _CategoryAverageCard extends StatelessWidget {
  const _CategoryAverageCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

String _formatAverage(double value) {
  if (value == 0) {
    return '-';
  }

  return value.toStringAsFixed(1);
}

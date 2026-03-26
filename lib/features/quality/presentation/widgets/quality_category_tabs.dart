import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../constants/quality_checklist_items.dart';
import 'quality_checklist_section.dart';

class QualityMaintenanceTab extends StatelessWidget {
  const QualityMaintenanceTab({
    required this.projectId,
    required this.average,
    super.key,
  });

  final String projectId;
  final double average;

  @override
  Widget build(BuildContext context) {
    return _QualitySingleCategoryTab(
      projectId: projectId,
      average: average,
      averageLabel: 'Maintenance average',
      sectionTitle: 'Maintenance',
      category: InspectionCategoryKey.maintenance,
      items: QualityChecklistItems.maintenance,
    );
  }
}

class QualitySecurityTab extends StatelessWidget {
  const QualitySecurityTab({
    required this.projectId,
    required this.average,
    super.key,
  });

  final String projectId;
  final double average;

  @override
  Widget build(BuildContext context) {
    return _QualitySingleCategoryTab(
      projectId: projectId,
      average: average,
      averageLabel: 'Security average',
      sectionTitle: 'Security',
      category: InspectionCategoryKey.security,
      items: QualityChecklistItems.security,
    );
  }
}

class QualityLandscapeTab extends StatelessWidget {
  const QualityLandscapeTab({
    required this.projectId,
    required this.average,
    super.key,
  });

  final String projectId;
  final double average;

  @override
  Widget build(BuildContext context) {
    return _QualitySingleCategoryTab(
      projectId: projectId,
      average: average,
      averageLabel: 'Landscape average',
      sectionTitle: 'Landscape',
      category: InspectionCategoryKey.landscape,
      items: QualityChecklistItems.landscape,
    );
  }
}

class _QualitySingleCategoryTab extends StatelessWidget {
  const _QualitySingleCategoryTab({
    required this.projectId,
    required this.average,
    required this.averageLabel,
    required this.sectionTitle,
    required this.category,
    required this.items,
  });

  final String projectId;
  final double average;
  final String averageLabel;
  final String sectionTitle;
  final InspectionCategoryKey category;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              '$averageLabel: ${_formatAverage(average)}',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          QualityChecklistSection(
            projectId: projectId,
            title: sectionTitle,
            category: category,
            items: items,
          ),
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

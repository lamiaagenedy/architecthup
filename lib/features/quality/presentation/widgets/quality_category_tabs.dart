import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../constants/quality_checklist_items.dart';
import 'quality_checklist_section.dart';

class QualityMaintenanceTab extends StatelessWidget {
  const QualityMaintenanceTab({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return _QualitySingleCategoryTab(
      projectId: projectId,
      category: InspectionCategoryKey.maintenance,
      items: QualityChecklistItems.maintenance,
    );
  }
}

class QualitySecurityTab extends StatelessWidget {
  const QualitySecurityTab({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return _QualitySingleCategoryTab(
      projectId: projectId,
      category: InspectionCategoryKey.security,
      items: QualityChecklistItems.security,
    );
  }
}

class QualityLandscapeTab extends StatelessWidget {
  const QualityLandscapeTab({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return _QualitySingleCategoryTab(
      projectId: projectId,
      category: InspectionCategoryKey.landscape,
      items: QualityChecklistItems.landscape,
    );
  }
}

class _QualitySingleCategoryTab extends StatelessWidget {
  const _QualitySingleCategoryTab({
    required this.projectId,
    required this.category,
    required this.items,
  });

  final String projectId;
  final InspectionCategoryKey category;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        AppDimensions.md,
        AppDimensions.lg,
        AppDimensions.xl,
      ),
      children: [
        QualityChecklistSection(
          projectId: projectId,
          category: category,
          items: items,
        ),
      ],
    );
  }
}

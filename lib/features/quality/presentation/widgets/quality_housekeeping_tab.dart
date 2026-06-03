import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../constants/quality_checklist_items.dart';
import 'quality_checklist_section.dart';

class QualityHousekeepingTab extends StatelessWidget {
  const QualityHousekeepingTab({required this.projectId, super.key});

  final String projectId;

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
          category: InspectionCategoryKey.housekeepingIndoor,
          items: QualityChecklistItems.housekeepingIndoor,
        ),
        const SizedBox(height: AppDimensions.lg),
        QualityChecklistSection(
          projectId: projectId,
          category: InspectionCategoryKey.housekeepingOutdoor,
          items: QualityChecklistItems.housekeepingOutdoor,
        ),
      ],
    );
  }
}

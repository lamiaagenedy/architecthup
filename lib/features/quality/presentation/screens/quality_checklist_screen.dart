import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../projects/domain/entities/project_list_item.dart';
import '../constants/quality_checklist_items.dart';
import '../providers/inspection_checklist_provider.dart';
import '../widgets/quality_category_tabs.dart';
import '../widgets/quality_housekeeping_tab.dart';

class QualityChecklistScreen extends ConsumerStatefulWidget {
  const QualityChecklistScreen({required this.project, super.key})
    : _missingProjectId = null;

  const QualityChecklistScreen.missing({required String projectId, super.key})
    : project = null,
      _missingProjectId = projectId;

  final ProjectListItem? project;
  final String? _missingProjectId;

  @override
  ConsumerState<QualityChecklistScreen> createState() =>
      _QualityChecklistScreenState();
}

class _QualityChecklistScreenState extends ConsumerState<QualityChecklistScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    if (project == null) {
      return _MissingChecklistView(projectId: widget._missingProjectId ?? '');
    }

    final state = ref.watch(inspectionChecklistProvider(project.id));
    final notifier = ref.read(inspectionChecklistProvider(project.id).notifier);

    final housekeepingIndoorAverage = notifier.categoryAverage(
      InspectionCategoryKey.housekeepingIndoor,
    );
    final housekeepingOutdoorAverage = notifier.categoryAverage(
      InspectionCategoryKey.housekeepingOutdoor,
    );
    final maintenanceAverage = notifier.categoryAverage(
      InspectionCategoryKey.maintenance,
    );
    final securityAverage = notifier.categoryAverage(
      InspectionCategoryKey.security,
    );
    final landscapeAverage = notifier.categoryAverage(
      InspectionCategoryKey.landscape,
    );
    final overallAverage = notifier.overallAverage();

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.lg,
              AppDimensions.md,
              AppDimensions.lg,
              AppDimensions.sm,
            ),
            child: _InspectionSummaryCard(
              projectName: project.name,
              overallAverage: overallAverage,
              housekeepingAverage: _combinedAverage(
                state.entries[InspectionCategoryKey.housekeepingIndoor] ??
                    const [],
                state.entries[InspectionCategoryKey.housekeepingOutdoor] ??
                    const [],
              ),
              maintenanceAverage: maintenanceAverage,
              securityAverage: securityAverage,
              landscapeAverage: landscapeAverage,
            ),
          ),
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: '🏠 Housekeeping'),
                Tab(text: '🔧 Maintenance'),
                Tab(text: '🛡️ Security'),
                Tab(text: '🌳 Landscape'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                QualityHousekeepingTab(
                  projectId: project.id,
                  indoorAverage: housekeepingIndoorAverage,
                  outdoorAverage: housekeepingOutdoorAverage,
                ),
                QualityMaintenanceTab(
                  projectId: project.id,
                  average: maintenanceAverage,
                ),
                QualitySecurityTab(
                  projectId: project.id,
                  average: securityAverage,
                ),
                QualityLandscapeTab(
                  projectId: project.id,
                  average: landscapeAverage,
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.lg,
                AppDimensions.sm,
                AppDimensions.lg,
                AppDimensions.md,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Inspection saved')),
                    );
                  },
                  child: const Text('Save Inspection'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InspectionSummaryCard extends StatelessWidget {
  const _InspectionSummaryCard({
    required this.projectName,
    required this.overallAverage,
    required this.housekeepingAverage,
    required this.maintenanceAverage,
    required this.securityAverage,
    required this.landscapeAverage,
  });

  final String projectName;
  final double overallAverage;
  final double housekeepingAverage;
  final double maintenanceAverage;
  final double securityAverage;
  final double landscapeAverage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            projectName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            'Inspection Score: ${_format(overallAverage)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Wrap(
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.sm,
            children: [
              _ScorePill(
                label: 'Housekeeping',
                value: _format(housekeepingAverage),
              ),
              _ScorePill(
                label: 'Maintenance',
                value: _format(maintenanceAverage),
              ),
              _ScorePill(label: 'Security', value: _format(securityAverage)),
              _ScorePill(label: 'Landscape', value: _format(landscapeAverage)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MissingChecklistView extends StatelessWidget {
  const _MissingChecklistView({required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Text(
          'Checklist data is unavailable for "$projectId". Open this screen from a project details page.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

double _combinedAverage(
  List<InspectionItemState> first,
  List<InspectionItemState> second,
) {
  final rated = [
    ...first.map((item) => item.rating),
    ...second.map((item) => item.rating),
  ].whereType<int>().toList();

  if (rated.isEmpty) {
    return 0;
  }

  final sum = rated.reduce((acc, score) => acc + score);
  return sum / rated.length;
}

String _format(double value) {
  if (value == 0) {
    return '-';
  }

  return value.toStringAsFixed(1);
}

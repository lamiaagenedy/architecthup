import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/design_tokens.dart';
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

    final screenHeight = MediaQuery.sizeOf(context).height;
    final compactScoreMaxHeight = screenHeight * 0.15;

    final state = ref.watch(inspectionChecklistProvider(project.id));
    final notifier = ref.read(inspectionChecklistProvider(project.id).notifier);

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
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Quality Checklist',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.lg,
                  AppDimensions.md,
                  AppDimensions.lg,
                  AppDimensions.sm,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: compactScoreMaxHeight),
                  child: _InspectionSummaryCard(
                    projectName: project.name,
                    overallAverage: overallAverage,
                    housekeepingAverage: _combinedAverage(
                      state.entries[InspectionCategoryKey.housekeepingIndoor] ??
                          const <InspectionItemState>[],
                      state.entries[InspectionCategoryKey
                              .housekeepingOutdoor] ??
                          const <InspectionItemState>[],
                    ),
                    maintenanceAverage: maintenanceAverage,
                    securityAverage: securityAverage,
                    landscapeAverage: landscapeAverage,
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedTabBarDelegate(
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: const [
                      Tab(
                        child: Text(
                          '🏠 Housekeeping',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Tab(
                        child: Text(
                          '🔧 Maintenance',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Tab(
                        child: Text(
                          '🛡️ Security',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Tab(
                        child: Text(
                          '🌳 Landscape',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: true,
              child: TabBarView(
                controller: _tabController,
                children: [
                  QualityHousekeepingTab(projectId: project.id),
                  QualityMaintenanceTab(projectId: project.id),
                  QualitySecurityTab(projectId: project.id),
                  QualityLandscapeTab(projectId: project.id),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.lg,
              AppDimensions.sm,
              AppDimensions.lg,
              AppDimensions.sm,
            ),
            child: SizedBox(
              height: 44,
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
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: AppDimensions.cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    projectName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  'Overall ${_format(overallAverage)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Row(
              children: [
                Expanded(
                  child: _ScorePill(
                    label: '🏠',
                    value: _format(housekeepingAverage),
                  ),
                ),
                const SizedBox(width: AppDimensions.xs),
                Expanded(
                  child: _ScorePill(
                    label: '🔧',
                    value: _format(maintenanceAverage),
                  ),
                ),
                const SizedBox(width: AppDimensions.xs),
                Expanded(
                  child: _ScorePill(
                    label: '🛡️',
                    value: _format(securityAverage),
                  ),
                ),
                const SizedBox(width: AppDimensions.xs),
                Expanded(
                  child: _ScorePill(
                    label: '🌳',
                    value: _format(landscapeAverage),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        horizontal: AppDimensions.xs,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          '$label $value',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _PinnedTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedTabBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => kTextTabBarHeight;

  @override
  double get maxExtent => kTextTabBarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _PinnedTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
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
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
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
    return '—';
  }

  return value.toStringAsFixed(1);
}

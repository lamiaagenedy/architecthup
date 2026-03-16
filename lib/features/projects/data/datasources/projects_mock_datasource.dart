import '../../domain/entities/project_list_item.dart';

class ProjectsMockDatasource {
  Future<List<ProjectListItem>> loadProjects() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    return const [
      ProjectListItem(
        id: 'p-001',
        name: 'North Gate Residences',
        location: 'Riyadh, Site A',
        status: ProjectStatus.inProgress,
        stage: 'Structure and facade',
        progress: 0.72,
        budgetLabel: 'SAR 2.5M',
        updatedLabel: 'Updated 25 min ago',
        nextMilestone: 'Facade inspection this Thursday',
      ),
      ProjectListItem(
        id: 'p-002',
        name: 'Palm Business Center',
        location: 'Jeddah, Block C',
        status: ProjectStatus.inProgress,
        stage: 'MEP coordination',
        progress: 0.58,
        budgetLabel: 'SAR 4.1M',
        updatedLabel: 'Updated 1 hr ago',
        nextMilestone: 'Resolve electrical clash review',
      ),
      ProjectListItem(
        id: 'p-003',
        name: 'Al Waha Villas',
        location: 'Dammam, Cluster 2',
        status: ProjectStatus.pending,
        stage: 'Interior finishing',
        progress: 0.86,
        budgetLabel: 'SAR 1.8M',
        updatedLabel: 'Updated 2 hr ago',
        nextMilestone: 'Approve joinery material submission',
      ),
      ProjectListItem(
        id: 'p-004',
        name: 'Harbor Service Hub',
        location: 'Jubail, Sector 4',
        status: ProjectStatus.completed,
        stage: 'Handover close-out',
        progress: 1,
        budgetLabel: 'SAR 3.2M',
        updatedLabel: 'Updated yesterday',
        nextMilestone: 'Archive close-out documentation',
      ),
      ProjectListItem(
        id: 'p-005',
        name: 'Wadi Admin Offices',
        location: 'Riyadh, Campus West',
        status: ProjectStatus.pending,
        stage: 'Mobilization planning',
        progress: 0.18,
        budgetLabel: 'SAR 1.1M',
        updatedLabel: 'Updated yesterday',
        nextMilestone: 'Finalize kickoff and procurement plan',
      ),
    ];
  }
}

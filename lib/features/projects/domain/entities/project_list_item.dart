class ProjectListItem {
  const ProjectListItem({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.stage,
    required this.progress,
    required this.budgetLabel,
    required this.updatedLabel,
    required this.nextMilestone,
  });

  final String id;
  final String name;
  final String location;
  final ProjectStatus status;
  final String stage;
  final double progress;
  final String budgetLabel;
  final String updatedLabel;
  final String nextMilestone;
}

enum ProjectStatus {
  pending('Pending'),
  inProgress('In progress'),
  completed('Completed');

  const ProjectStatus(this.label);

  final String label;
}

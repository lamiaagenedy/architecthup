import '../entities/project_list_item.dart';

abstract class ProjectsRepository {
  Future<List<ProjectListItem>> loadProjects();
}

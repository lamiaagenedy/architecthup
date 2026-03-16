import '../../domain/entities/project_list_item.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_mock_datasource.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  ProjectsRepositoryImpl(this._datasource);

  final ProjectsMockDatasource _datasource;

  @override
  Future<List<ProjectListItem>> loadProjects() {
    return _datasource.loadProjects();
  }
}

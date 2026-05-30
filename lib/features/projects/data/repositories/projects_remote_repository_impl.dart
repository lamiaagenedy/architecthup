import '../../domain/entities/project_list_item.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_remote_datasource.dart';

class ProjectsRemoteRepositoryImpl implements ProjectsRepository {
  ProjectsRemoteRepositoryImpl(this._datasource);

  final ProjectsRemoteDatasource _datasource;

  @override
  Future<List<ProjectListItem>> loadProjects() {
    return _datasource.loadSupervisorProjects();
  }
}

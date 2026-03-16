import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/projects_mock_datasource.dart';
import '../../data/repositories/projects_repository_impl.dart';
import '../../domain/entities/project_list_item.dart';
import '../../domain/repositories/projects_repository.dart';

final projectsMockDatasourceProvider = Provider<ProjectsMockDatasource>(
  (ref) => ProjectsMockDatasource(),
);

final projectsRepositoryProvider = Provider<ProjectsRepository>(
  (ref) => ProjectsRepositoryImpl(ref.watch(projectsMockDatasourceProvider)),
);

final projectsQueryProvider = StateProvider<String>((ref) => '');

final projectsStatusFilterProvider = StateProvider<ProjectStatus?>(
  (ref) => null,
);

final projectsListProvider = FutureProvider<List<ProjectListItem>>(
  (ref) => ref.watch(projectsRepositoryProvider).loadProjects(),
);

final filteredProjectsProvider = Provider<AsyncValue<List<ProjectListItem>>>((
  ref,
) {
  final projectsAsync = ref.watch(projectsListProvider);
  final query = ref.watch(projectsQueryProvider).trim().toLowerCase();
  final status = ref.watch(projectsStatusFilterProvider);

  return projectsAsync.whenData((projects) {
    return projects.where((project) {
      final matchesQuery =
          query.isEmpty ||
          project.name.toLowerCase().contains(query) ||
          project.location.toLowerCase().contains(query);
      final matchesStatus = status == null || project.status == status;
      return matchesQuery && matchesStatus;
    }).toList();
  });
});

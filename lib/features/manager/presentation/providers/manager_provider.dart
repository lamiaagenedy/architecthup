import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../data/datasources/manager_remote_datasource.dart';

final managerRemoteDatasourceProvider = Provider<ManagerRemoteDatasource>(
  (ref) => ManagerRemoteDatasource(ref.watch(dioClientProvider)),
);

final managerDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(managerRemoteDatasourceProvider).loadDashboard();
});

final managerUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(managerRemoteDatasourceProvider).loadUsers();
});

final managerProjectsApiProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
      return ref.watch(managerRemoteDatasourceProvider).loadManagerProjects();
    });

final managerReportProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, projectId) {
      return ref.watch(managerRemoteDatasourceProvider).loadReport(projectId);
    });

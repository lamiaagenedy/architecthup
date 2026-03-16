import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/dashboard_mock_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/repositories/dashboard_repository.dart';

final dashboardMockDatasourceProvider = Provider<DashboardMockDatasource>(
  (ref) => DashboardMockDatasource(),
);

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepositoryImpl(ref.watch(dashboardMockDatasourceProvider)),
);

final dashboardSnapshotProvider = FutureProvider<DashboardSnapshot>(
  (ref) => ref.watch(dashboardRepositoryProvider).loadDashboard(),
);

import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_mock_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._datasource);

  final DashboardMockDatasource _datasource;

  @override
  Future<DashboardSnapshot> loadDashboard() {
    return _datasource.loadDashboard();
  }
}

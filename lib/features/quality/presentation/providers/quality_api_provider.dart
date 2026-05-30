import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../data/datasources/quality_remote_datasource.dart';
import '../../domain/entities/inspection_entities.dart';

final qualityRemoteDatasourceProvider = Provider<QualityRemoteDatasource>(
  (ref) => QualityRemoteDatasource(ref.watch(dioClientProvider)),
);

final projectServicesProvider = FutureProvider.autoDispose
    .family<List<InspectionService>, String>((ref, projectId) {
      return ref.watch(qualityRemoteDatasourceProvider).loadServices(projectId);
    });

final serviceChecklistProvider = FutureProvider.autoDispose
    .family<List<ChecklistItem>, String>((ref, serviceId) {
      return ref
          .watch(qualityRemoteDatasourceProvider)
          .loadChecklist(serviceId);
    });

final projectStatsProvider = FutureProvider.autoDispose
    .family<ProjectStats, String>((ref, projectId) {
      return ref
          .watch(qualityRemoteDatasourceProvider)
          .loadProjectStats(projectId);
    });

final checklistControllerProvider = StateNotifierProvider.autoDispose
    .family<ChecklistController, AsyncValue<List<ChecklistItem>>, String>(
      (ref, serviceId) {
        return ChecklistController(ref, serviceId);
      },
    );

class ChecklistController extends StateNotifier<AsyncValue<List<ChecklistItem>>> {
  ChecklistController(this._ref, this._serviceId)
    : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;
  final String _serviceId;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _ref
          .read(qualityRemoteDatasourceProvider)
          .loadChecklist(_serviceId),
    );
  }

  Future<void> saveScore(String itemId, int score) async {
    await _ref
        .read(qualityRemoteDatasourceProvider)
        .saveScore(itemId, score);

    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current
          .map(
            (item) => item.id == itemId ? item.copyWith(score: score) : item,
          )
          .toList(),
    );

    _ref.invalidate(projectServicesProvider);
  }

  Future<void> saveComment(String itemId, String comment) async {
    await _ref
        .read(qualityRemoteDatasourceProvider)
        .saveComment(itemId, comment);

    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current
          .map(
            (item) =>
                item.id == itemId ? item.copyWith(comment: comment) : item,
          )
          .toList(),
    );
  }

  Future<void> refresh() => _load();
}

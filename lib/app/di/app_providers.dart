import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../app/bootstrap/app_bootstrap.dart';
import '../../core/config/app_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../features/auth/data/datasources/local/auth_local_datasource.dart';
import '../../features/auth/data/datasources/remote/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/remote/mock_auth_remote_datasource.dart';
import '../../features/auth/data/datasources/remote/network_auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_auth_session_usecase.dart';
import '../../features/auth/domain/usecases/load_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../shared/data/local/app_database.dart';
import '../../shared/data/local/preferences_store.dart';

final appBootstrapProvider = Provider<AppBootstrap>(
  (ref) =>
      throw UnimplementedError('AppBootstrap must be overridden in main().'),
);

final appConfigProvider = Provider<AppConfig>(
  (ref) => ref.watch(appBootstrapProvider).config,
);

final preferencesBoxProvider = Provider<Box<dynamic>>(
  (ref) => ref.watch(appBootstrapProvider).preferencesBox,
);

final authBoxProvider = Provider<Box<dynamic>>(
  (ref) => ref.watch(appBootstrapProvider).authBox,
);

final preferencesStoreProvider = Provider<PreferencesStore>(
  (ref) => PreferencesStore(ref.watch(preferencesBoxProvider)),
);

final dioClientProvider = Provider<DioClient>(
  (ref) => DioClient(config: ref.watch(appConfigProvider)),
);

final networkInfoProvider = Provider<NetworkInfo>((ref) => const NetworkInfo());

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>(
  (ref) => AuthLocalDatasource(ref.watch(authBoxProvider)),
);

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMockAuth) {
    return MockAuthRemoteDatasource();
  }

  return NetworkAuthRemoteDatasource(ref.watch(dioClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    localDatasource: ref.watch(authLocalDatasourceProvider),
    remoteDatasource: ref.watch(authRemoteDatasourceProvider),
  ),
);

final getAuthSessionUsecaseProvider = Provider<GetAuthSessionUsecase>(
  (ref) => GetAuthSessionUsecase(ref.watch(authRepositoryProvider)),
);

final loadCurrentUserUsecaseProvider = Provider<LoadCurrentUserUsecase>(
  (ref) => LoadCurrentUserUsecase(ref.watch(authRepositoryProvider)),
);

final loginUsecaseProvider = Provider<LoginUsecase>(
  (ref) => LoginUsecase(ref.watch(authRepositoryProvider)),
);

final logoutUsecaseProvider = Provider<LogoutUsecase>(
  (ref) => LogoutUsecase(ref.watch(authRepositoryProvider)),
);

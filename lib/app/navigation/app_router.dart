import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/maps/presentation/screens/map_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/project_details/presentation/screens/project_details_screen.dart';
import '../../features/projects/presentation/screens/projects_list_screen.dart';
import '../../features/projects/domain/entities/project_list_item.dart';
import '../../features/quality/presentation/screens/quality_checklist_screen.dart';
import '../../features/splash/presentation/providers/splash_flow_provider.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/tasks/presentation/screens/tasks_list_screen.dart';
import 'app_shell_scaffold.dart';
import 'navigation_observer.dart';
import 'route_names.dart';
import 'router_refresh_notifier.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = RouterRefreshNotifier(
    authState: ref.read(authControllerProvider),
    splashState: ref.read(splashFlowProvider),
  );

  ref
    ..onDispose(refreshNotifier.dispose)
    ..listen<AuthState>(authControllerProvider, (previous, next) {
      refreshNotifier.updateAuthState(next);
    })
    ..listen<SplashFlowState>(splashFlowProvider, (previous, next) {
      refreshNotifier.updateSplashState(next);
    });

  return GoRouter(
    initialLocation: RouteNames.splash,
    observers: [AppNavigationObserver()],
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = refreshNotifier.authState;
      final splashState = refreshNotifier.splashState;
      final location = state.matchedLocation;
      final isAtSplash = location == RouteNames.splash;
      final isAtLogin = location == RouteNames.login;

      if (!splashState.isComplete || authState.isChecking) {
        return isAtSplash ? null : RouteNames.splash;
      }

      if (!authState.isAuthenticated) {
        return isAtLogin ? null : RouteNames.login;
      }

      if (isAtSplash || isAtLogin) {
        return RouteNames.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                name: 'dashboard',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DashboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.projects,
                name: 'projects',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProjectsListScreen()),
                routes: [
                  GoRoute(
                    path: RouteNames.projectDetailsPath,
                    name: 'project-details',
                    builder: (context, state) {
                      final extraProject = state.extra;
                      if (extraProject is! ProjectListItem) {
                        final projectId = state.pathParameters['projectId'];

                        return ProjectDetailsScreen.missing(
                          projectId: projectId ?? '',
                        );
                      }

                      return ProjectDetailsScreen(project: extraProject);
                    },
                    routes: [
                      GoRoute(
                        path: RouteNames.projectChecklistPath,
                        name: 'project-checklist',
                        builder: (context, state) {
                          final extraProject = state.extra;
                          if (extraProject is! ProjectListItem) {
                            final projectId = state.pathParameters['projectId'];

                            return QualityChecklistScreen.missing(
                              projectId: projectId ?? '',
                            );
                          }

                          return QualityChecklistScreen(project: extraProject);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.tasks,
                name: 'tasks',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: TasksListScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.map,
                name: 'map',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: MapScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.profile,
                name: 'profile',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

abstract final class RouteNames {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String projects = '/projects';
  static const String projectDetailsPath = ':projectId';
  static const String tasks = '/tasks';
  static const String map = '/map';
  static const String profile = '/profile';

  static String projectDetails(String projectId) => '$projects/$projectId';
}

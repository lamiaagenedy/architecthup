abstract final class RouteNames {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String projects = '/projects';
  static const String projectDetailsPath = ':projectId';
  static const String projectServicesPath = 'services';
  static const String serviceChecklistPath = ':serviceId/checklist';
  static const String projectChecklistPath = 'checklist';
  static const String tasks = '/tasks';
  static const String map = '/map';
  static const String profile = '/profile';

  static const String managerDashboard = '/manager/dashboard';
  static const String managerUsers = '/manager/users';
  static const String managerProjects = '/manager/projects';
  static const String managerReportPath = ':projectId';

  static String projectDetails(String projectId) => '$projects/$projectId';

  static String projectServices(String projectId) =>
      '${projectDetails(projectId)}/$projectServicesPath';

  static String serviceChecklist(String projectId, String serviceId) =>
      '${projectServices(projectId)}/$serviceId/checklist';

  static String projectChecklist(String projectId) =>
      '${projectDetails(projectId)}/$projectChecklistPath';

  static String managerReport(String projectId) =>
      '$managerProjects/$projectId/report';
}

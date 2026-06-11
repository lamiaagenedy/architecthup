import '../../../../core/exceptions/network_exception.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/project_list_item.dart';

class ProjectsRemoteDatasource {
  ProjectsRemoteDatasource(this._dioClient);

  final DioClient _dioClient;

  Future<List<ProjectListItem>> loadSupervisorProjects() async {
    try {
      final response = await _dioClient.dio.get<dynamic>('/projects/mine');
      final rows = ApiResponseParser.extractList(response);
      return rows.map(_mapProject).toList();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to load supervisor projects',
        error: error,
        stackTrace: stackTrace,
      );
      throw NetworkException('Unable to load assigned projects.');
    }
  }

  ProjectListItem _mapProject(Map<String, dynamic> json) {
    final progressPercent = _parseNum(
      json['progress'],
      field: 'progress',
    ).toDouble();
    final progress = progressPercent / 100;
    final grade = json['grade'] as String? ?? '—';

    ProjectStatus status;
    if (progressPercent >= 100) {
      status = ProjectStatus.completed;
    } else if (progressPercent > 0) {
      status = ProjectStatus.inProgress;
    } else {
      status = ProjectStatus.pending;
    }

    return ProjectListItem(
      id: json['p_id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Untitled',
      location: json['location'] as String? ?? '',
      status: status,
      stage: grade,
      progress: progress,
      budgetLabel: json['company_name'] as String? ?? '',
      updatedLabel: 'Grade: $grade',
      nextMilestone: '${progressPercent.round()}% inspected',
      supervisorName: json['supervisor_name'] as String?,
      companyName: json['company_name'] as String?,
      grade: grade,
      uId: json['u_id']?.toString() ?? '',
    );
  }

  num _parseNum(dynamic value, {required String field}) {
    if (value is num) {
      return value;
    }
    final parsed = num.tryParse(value?.toString() ?? '');
    if (parsed == null) {
      AppLogger.warning('Unexpected $field value: $value');
      return 0;
    }
    return parsed;
  }
}

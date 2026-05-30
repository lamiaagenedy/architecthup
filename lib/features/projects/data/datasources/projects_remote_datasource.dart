import '../../../../core/exceptions/network_exception.dart';
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
    } catch (error) {
      throw NetworkException(error.toString());
    }
  }

  ProjectListItem _mapProject(Map<String, dynamic> json) {
    final progressPercent = (json['progress'] as num?)?.toDouble() ?? 0;
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
      id: '${json['p_id']}',
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
      uId: json['u_id']?.toString(),
    );
  }
}

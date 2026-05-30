import 'package:dio/dio.dart';

import '../../../../core/exceptions/network_exception.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/inspection_entities.dart';

class QualityRemoteDatasource {
  QualityRemoteDatasource(this._dioClient);

  final DioClient _dioClient;

  Future<List<InspectionService>> loadServices(String projectId) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        '/services/$projectId',
      );
      final rows = ApiResponseParser.extractList(response);

      return rows
          .map(
            (json) => InspectionService(
              id: '${json['s_id']}',
              name: json['name'] as String? ?? '',
              rating: (json['rating'] as num?)?.toDouble() ?? 0,
              progress: (json['progress'] as num?)?.toInt() ?? 0,
              projectId: projectId,
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<List<ChecklistItem>> loadChecklist(String serviceId) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        '/checklist/$serviceId',
      );
      final rows = ApiResponseParser.extractList(response);

      return rows
          .map(
            (json) => ChecklistItem(
              id: '${json['C_ID']}',
              itemNumber: (json['item_number'] as num?)?.toInt() ?? 0,
              textAr: json['text_ar'] as String? ?? '',
              textEn: json['text_en'] as String? ?? json['Name'] as String? ?? '',
              score: (json['Score'] as num?)?.toInt(),
              comment: json['Comment'] as String?,
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<void> saveScore(String checklistId, int score) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        '/checklist/saveScore',
        data: {'c_id': int.parse(checklistId), 'score': score},
      );
      ApiResponseParser.ensureSuccess(response);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<void> saveComment(String checklistId, String comment) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        '/checklist/saveComment',
        data: {'c_id': int.parse(checklistId), 'comment': comment},
      );
      ApiResponseParser.ensureSuccess(response);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<ProjectStats> loadProjectStats(String projectId) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        '/stats/project/$projectId',
      );
      final data = ApiResponseParser.extractData(response);
      final services = (data['services'] as List? ?? [])
          .map(
            (item) => ServiceStats(
              id: '${(item as Map)['s_id']}',
              name: item['name'] as String? ?? '',
              rating: (item['rating'] as num?)?.toDouble() ?? 0,
              progress: (item['progress'] as num?)?.toInt() ?? 0,
              grade: item['grade'] as String? ?? '',
            ),
          )
          .toList();

      return ProjectStats(
        projectId: '${data['project_id']}',
        projectName: data['project_name'] as String? ?? '',
        overallProgress: (data['overall_progress'] as num?)?.toInt() ?? 0,
        overallScore: (data['overall_score'] as num?)?.toDouble() ?? 0,
        grade: data['grade'] as String? ?? '',
        services: services,
      );
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  NetworkException _mapError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return NetworkException(
        data['message'] as String? ?? 'Network request failed',
      );
    }

    return NetworkException(error.message ?? 'Network request failed');
  }
}

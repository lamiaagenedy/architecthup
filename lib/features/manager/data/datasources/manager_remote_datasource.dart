import 'package:dio/dio.dart';

import '../../../../core/exceptions/network_exception.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_client.dart';

class ManagerRemoteDatasource {
  ManagerRemoteDatasource(this._dioClient);

  final DioClient _dioClient;

  Future<Map<String, dynamic>> loadDashboard() async {
    return _handleRequest(
      action: 'Unable to load manager dashboard.',
      request: () async {
        final response = await _dioClient.dio.get<dynamic>(
          '/manager/dashboard',
        );
        return ApiResponseParser.extractData(response);
      },
    );
  }

  Future<List<Map<String, dynamic>>> loadUsers() async {
    return _handleRequest(
      action: 'Unable to load supervisors.',
      request: () async {
        final response = await _dioClient.dio.get<dynamic>('/manager/users');
        return ApiResponseParser.extractList(response);
      },
    );
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    await _handleRequest(
      action: 'Unable to create supervisor.',
      request: () async {
        final response = await _dioClient.dio.post<dynamic>(
          '/manager/createUser',
          data: {'name': name, 'email': email, 'password': password},
        );
        ApiResponseParser.ensureSuccess(response);
      },
    );
  }

  Future<void> deleteUser(String userId) async {
    await _handleRequest(
      action: 'Unable to delete supervisor.',
      request: () async {
        final response = await _dioClient.dio.delete<dynamic>(
          '/manager/deleteUser/$userId',
        );
        ApiResponseParser.ensureSuccess(response);
      },
    );
  }

  Future<void> createProject({
    required String name,
    required String location,
    required String companyName,
    required int supervisorId,
  }) async {
    await _handleRequest(
      action: 'Unable to create project.',
      request: () async {
        final response = await _dioClient.dio.post<dynamic>(
          '/manager/createProject',
          data: {
            'name': name,
            'location': location,
            'company_name': companyName,
            'u_id': supervisorId,
          },
        );
        ApiResponseParser.ensureSuccess(response);
      },
    );
  }

  Future<void> deleteProject(String projectId) async {
    await _handleRequest(
      action: 'Unable to delete project.',
      request: () async {
        final response = await _dioClient.dio.delete<dynamic>(
          '/manager/deleteProject/$projectId',
        );
        ApiResponseParser.ensureSuccess(response);
      },
    );
  }

  Future<void> assignProject({
    required int projectId,
    required int supervisorId,
  }) async {
    await _handleRequest(
      action: 'Unable to reassign project.',
      request: () async {
        final response = await _dioClient.dio.put<dynamic>(
          '/manager/assignProject',
          data: {'p_id': projectId, 'u_id': supervisorId},
        );
        ApiResponseParser.ensureSuccess(response);
      },
    );
  }

  Future<List<Map<String, dynamic>>> loadManagerProjects() async {
    return _handleRequest(
      action: 'Unable to load projects.',
      request: () async {
        final response = await _dioClient.dio.get<dynamic>('/manager/projects');
        return ApiResponseParser.extractList(response);
      },
    );
  }

  Future<void> flagReinspection(String projectId) async {
    await _handleRequest(
      action: 'Unable to flag reinspection.',
      request: () async {
        final response = await _dioClient.dio.put<dynamic>(
          '/manager/flagReinspection/$projectId',
        );
        ApiResponseParser.ensureSuccess(response);
      },
    );
  }

  Future<Map<String, dynamic>> loadReport(String projectId) async {
    return _handleRequest(
      action: 'Unable to load project report.',
      request: () async {
        final response = await _dioClient.dio.get<dynamic>(
          '/manager/report/$projectId',
        );
        return ApiResponseParser.extractData(response);
      },
    );
  }

  Future<List<int>> downloadReportPdf(String projectId) async {
    try {
      final response = await _dioClient.dio.get<List<int>>(
        '/manager/report/$projectId/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? <int>[];
    } on DioException catch (error) {
      throw NetworkException(error.message ?? 'Failed to download PDF');
    }
  }

  Future<T> _handleRequest<T>({
    required String action,
    required Future<T> Function() request,
  }) async {
    try {
      return await request();
    } on DioException catch (error, stackTrace) {
      AppLogger.error(action, error: error, stackTrace: stackTrace);
      throw NetworkException(error.message ?? action);
    } catch (error, stackTrace) {
      AppLogger.error(action, error: error, stackTrace: stackTrace);
      throw NetworkException(action);
    }
  }
}

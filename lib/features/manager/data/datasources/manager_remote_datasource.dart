import 'package:dio/dio.dart';

import '../../../../core/exceptions/network_exception.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_client.dart';

class ManagerRemoteDatasource {
  ManagerRemoteDatasource(this._dioClient);

  final DioClient _dioClient;

  Future<Map<String, dynamic>> loadDashboard() async {
    final response = await _dioClient.dio.get<dynamic>('/manager/dashboard');
    return ApiResponseParser.extractData(response);
  }

  Future<List<Map<String, dynamic>>> loadUsers() async {
    final response = await _dioClient.dio.get<dynamic>('/manager/users');
    return ApiResponseParser.extractList(response);
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.dio.post<dynamic>(
      '/manager/createUser',
      data: {'name': name, 'email': email, 'password': password},
    );
    ApiResponseParser.ensureSuccess(response);
  }

  Future<void> deleteUser(String userId) async {
    final response = await _dioClient.dio.delete<dynamic>(
      '/manager/deleteUser/$userId',
    );
    ApiResponseParser.ensureSuccess(response);
  }

  Future<void> createProject({
    required String name,
    required String location,
    required String companyName,
    required int supervisorId,
  }) async {
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
  }

  Future<void> deleteProject(String projectId) async {
    final response = await _dioClient.dio.delete<dynamic>(
      '/manager/deleteProject/$projectId',
    );
    ApiResponseParser.ensureSuccess(response);
  }

  Future<void> assignProject({
    required int projectId,
    required int supervisorId,
  }) async {
    final response = await _dioClient.dio.put<dynamic>(
      '/manager/assignProject',
      data: {'p_id': projectId, 'u_id': supervisorId},
    );
    ApiResponseParser.ensureSuccess(response);
  }

  Future<List<Map<String, dynamic>>> loadManagerProjects() async {
    final response = await _dioClient.dio.get<dynamic>('/manager/projects');
    return ApiResponseParser.extractList(response);
  }

  Future<void> flagReinspection(String projectId) async {
    final response = await _dioClient.dio.put<dynamic>(
      '/manager/flagReinspection/$projectId',
    );
    ApiResponseParser.ensureSuccess(response);
  }

  Future<Map<String, dynamic>> loadReport(String projectId) async {
    final response = await _dioClient.dio.get<dynamic>(
      '/manager/report/$projectId',
    );
    return ApiResponseParser.extractData(response);
  }

  Future<List<int>> downloadReportPdf(String projectId) async {
    try {
      final response = await _dioClient.dio.get<List<int>>(
        '/manager/report/$projectId/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? <int>[];
    } on DioException catch (error) {
      throw NetworkException(
        error.message ?? 'Failed to download PDF',
      );
    }
  }
}

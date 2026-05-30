import 'package:dio/dio.dart';

import '../exceptions/network_exception.dart';

class ApiResponseParser {
  static Map<String, dynamic> extractData(Response<dynamic> response) {
    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw NetworkException('Unexpected response format');
    }

    if (data['status'] == 'error') {
      throw NetworkException( data['message'] as String? ?? 'Request failed',
      );
    }

    if (data.containsKey('data')) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }

    if (data['success'] == true && data.containsKey('data')) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }

    return data;
  }

  static List<Map<String, dynamic>> extractList(Response<dynamic> response) {
    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw NetworkException('Unexpected response format');
    }

    if (data['status'] == 'error') {
      throw NetworkException( data['message'] as String? ?? 'Request failed',
      );
    }

    final payload = data['data'];
    if (payload is List) {
      return payload
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }

    throw NetworkException('Expected list in response data');
  }

  static void ensureSuccess(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['status'] == 'error') {
        throw NetworkException(
          data['message'] as String? ?? 'Request failed',
        );
      }
      if (data['success'] == false) {
        throw NetworkException(
          data['message'] as String? ?? 'Request failed',
        );
      }
    }
  }
}

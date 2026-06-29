import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';

class PublicDashboardRemoteDataSource {
  PublicDashboardRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(ApiEndpoints.tasks);
      final data = response.data;

      if (data == null) return [];

      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } on DioException catch (error) {
      throw ApiException(
        message: _messageFromDio(error),
        statusCode: error.response?.statusCode,
      );
    }
  }

  String _messageFromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['detail'] != null) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        return detail.first.toString();
      }
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to reach the server. Check your connection and API URL.';
    }

    return error.message ?? 'Unexpected network error.';
  }
}

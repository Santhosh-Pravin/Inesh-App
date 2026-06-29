// services/dashboard_service.dart
// Handles all HTTP communication. UI never imports http directly.
//
// pubspec.yaml:  http: ^1.2.0

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_models.dart';

class ApiConfig {
  ApiConfig._();
  static const String baseUrl    = 'http://118.91.232.233:3001';
  static const String dashboard  = '$baseUrl/dcumonitor/dashboard';
  static const Duration timeout  = Duration(seconds: 15);
}

class ApiResult<T> {
  final T?      data;
  final String? error;
  const ApiResult.success(T this.data) : error = null;
  const ApiResult.failure(String this.error) : data = null;
  bool get isSuccess => data != null;
}

class DashboardService {
  DashboardService._();
  static final DashboardService instance = DashboardService._();
  final http.Client _client = http.Client();
  Future<ApiResult<DashboardResponse>> fetchDashboard() async {
    try {
      final response = await _client
          .get(Uri.parse(ApiConfig.dashboard),
               headers: {'Accept': 'application/json'})
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResult.success(DashboardResponse.fromJson(json));
      }
      return ApiResult.failure(
          'Server error ${response.statusCode}: ${response.reasonPhrase}');
    } on TimeoutException {
      return const ApiResult.failure(
          'Request timed out. Check your network connection.');
    } on FormatException catch (e) {
      return ApiResult.failure('Failed to parse response: ${e.message}');
    } catch (e) {
      return ApiResult.failure('Network error: ${e.toString()}');
    }
  }
  void dispose() => _client.close();
}

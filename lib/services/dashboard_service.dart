// services/dashboard_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import '../models/dashboard_models.dart';

class ApiConfig {
  ApiConfig._();
  static const String baseUrl   = 'http://118.91.232.233:3001';
  static const String dashboard = '$baseUrl/dcumonitor/dashboard';
  static const Duration timeout = Duration(seconds: 15);
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
    dev.log('→ GET ${ApiConfig.dashboard}', name: 'DashboardService');
    try {
      final response = await _client
          .get(Uri.parse(ApiConfig.dashboard),
               headers: {'Accept': 'application/json'})
          .timeout(ApiConfig.timeout);

      dev.log('← HTTP ${response.statusCode}', name: 'DashboardService');
      dev.log('   body preview: ${response.body.substring(0, response.body.length.clamp(0, 300))}',
              name: 'DashboardService');

      if (response.statusCode == 200) {
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final data = DashboardResponse.fromJson(json);
          dev.log('✓ parsed ${data.dcus.length} DCUs', name: 'DashboardService');
          return ApiResult.success(data);
        } on FormatException catch (e) {
          dev.log('✗ JSON parse error: $e', name: 'DashboardService');
          return ApiResult.failure('JSON parse error: ${e.message}\n\nRaw: ${response.body.substring(0, response.body.length.clamp(0, 200))}');
        } catch (e, st) {
          dev.log('✗ model error: $e\n$st', name: 'DashboardService');
          return ApiResult.failure('Data mapping error: $e');
        }
      }

      return ApiResult.failure(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}\n\n${response.body.substring(0, response.body.length.clamp(0, 200))}');

    } on TimeoutException {
      dev.log('✗ timeout after ${ApiConfig.timeout.inSeconds}s', name: 'DashboardService');
      return const ApiResult.failure('Request timed out (15s).\nIs the device on the same network as the server?');
    } catch (e, st) {
      dev.log('✗ network error: $e\n$st', name: 'DashboardService');
      return ApiResult.failure('Network error: $e');
    }
  }

  void dispose() => _client.close();
}
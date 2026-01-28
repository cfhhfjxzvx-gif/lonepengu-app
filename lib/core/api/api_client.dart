import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../services/logger_service.dart';

/// HTTP Client wrapper for API calls
/// Handles authentication, retries, and error handling
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _accessToken;

  // ═══════════════════════════════════════════════════════════════
  // TOKEN MANAGEMENT
  // ═══════════════════════════════════════════════════════════════

  void setToken(String? token) {
    _accessToken = token;
  }

  void clearToken() {
    _accessToken = null;
  }

  bool get hasToken => _accessToken != null && _accessToken!.isNotEmpty;

  // ═══════════════════════════════════════════════════════════════
  // HTTP METHODS
  // ═══════════════════════════════════════════════════════════════

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String url, {
    Map<String, String>? queryParams,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(Duration(seconds: ApiConfig.requestTimeout));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String url, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: _getHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: ApiConfig.requestTimeout));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String url, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: _getHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: ApiConfig.requestTimeout));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String url, {
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await http
          .delete(Uri.parse(url), headers: _getHeaders())
          .timeout(Duration(seconds: ApiConfig.requestTimeout));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  Map<String, String> _getHeaders() {
    if (_accessToken != null) {
      return ApiConfig.authHeaders(_accessToken!);
    }
    return ApiConfig.defaultHeaders;
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic json)? fromJson,
  ) {
    LoggerService.debug(
      'API Response [${response.statusCode}]: ${response.request?.url}',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse.success(null as T);
      }

      final json = jsonDecode(response.body);

      if (fromJson != null) {
        return ApiResponse.success(fromJson(json));
      }

      return ApiResponse.success(json as T);
    }

    // Handle error responses
    String message = 'An error occurred';
    String? errorCode;

    try {
      final json = jsonDecode(response.body);
      message = json['message'] ?? json['error'] ?? message;
      errorCode = json['code'];
    } catch (_) {
      message = response.reasonPhrase ?? message;
    }

    LoggerService.error('API Error: $message', null);

    return ApiResponse.error(
      message,
      errorCode: errorCode,
      statusCode: response.statusCode,
    );
  }

  ApiResponse<T> _handleError<T>(dynamic error) {
    LoggerService.error('API Exception', error);

    String message;
    String errorCode = 'NETWORK_ERROR';

    if (error is SocketException) {
      message = 'No internet connection';
      errorCode = 'NO_INTERNET';
    } else if (error is TimeoutException) {
      message = 'Request timed out';
      errorCode = 'TIMEOUT';
    } else if (error is FormatException) {
      message = 'Invalid response format';
      errorCode = 'PARSE_ERROR';
    } else {
      message = error.toString();
    }

    return ApiResponse.error(message, errorCode: errorCode);
  }
}

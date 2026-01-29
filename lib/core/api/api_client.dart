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
    int retries = 1,
  }) async {
    int attempts = 0;
    while (attempts <= retries) {
      try {
        final uri = Uri.parse(url).replace(queryParameters: queryParams);
        final response = await http
            .get(uri, headers: _getHeaders())
            .timeout(Duration(seconds: ApiConfig.requestTimeout));

        return _handleResponse<T>(response, fromJson);
      } catch (e) {
        attempts++;
        if (attempts > retries) {
          return _handleError<T>(e);
        }
        await Future.delayed(Duration(seconds: 1)); // Small delay before retry
      }
    }
    return ApiResponse.error('Maximum retries exceeded');
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String url, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? fromJson,
    int retries = 1,
  }) async {
    int attempts = 0;
    while (attempts <= retries) {
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
        attempts++;
        if (attempts > retries) {
          return _handleError<T>(e);
        }
        await Future.delayed(Duration(seconds: 1)); // Small delay before retry
      }
    }
    return ApiResponse.error('Maximum retries exceeded');
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String url, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? fromJson,
    int retries = 1,
  }) async {
    int attempts = 0;
    while (attempts <= retries) {
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
        attempts++;
        if (attempts > retries) {
          return _handleError<T>(e);
        }
        await Future.delayed(Duration(seconds: 1));
      }
    }
    return ApiResponse.error('Maximum retries exceeded');
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String url, {
    T Function(dynamic json)? fromJson,
    int retries = 1,
  }) async {
    int attempts = 0;
    while (attempts <= retries) {
      try {
        final response = await http
            .delete(Uri.parse(url), headers: _getHeaders())
            .timeout(Duration(seconds: ApiConfig.requestTimeout));

        return _handleResponse<T>(response, fromJson);
      } catch (e) {
        attempts++;
        if (attempts > retries) {
          return _handleError<T>(e);
        }
        await Future.delayed(Duration(seconds: 1));
      }
    }
    return ApiResponse.error('Maximum retries exceeded');
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
    LoggerService.apiResponse(
      response.request?.url.toString() ?? '',
      response.statusCode,
      response.body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse.success(null as T);
      }

      try {
        final json = jsonDecode(response.body);

        if (fromJson != null) {
          return ApiResponse.success(fromJson(json));
        }

        return ApiResponse.success(json as T);
      } catch (e) {
        LoggerService.error('JSON Decode Error', e);
        return ApiResponse.error(
          'Failed to parse server response',
          errorCode: 'PARSE_ERROR',
          statusCode: response.statusCode,
        );
      }
    }

    // Handle error responses
    String message = 'An error occurred';
    String? errorCode;

    try {
      if (response.body.isNotEmpty) {
        final json = jsonDecode(response.body);
        message = json['message'] ?? json['error'] ?? message;
        errorCode = json['code'];
      }
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
      // Don't just assume no internet; it could be server down or wrong URL
      message =
          'Unable to connect to server. Please check your connection or try again later.';
      errorCode = 'CONNECTION_FAILED';
    } else if (error is TimeoutException) {
      message = 'Request timed out. The server might be busy.';
      errorCode = 'TIMEOUT';
    } else if (error is FormatException) {
      message = 'Invalid response format';
      errorCode = 'PARSE_ERROR';
    } else {
      message = 'An unexpected error occurred: ${error.toString()}';
    }

    return ApiResponse.error(message, errorCode: errorCode);
  }
}

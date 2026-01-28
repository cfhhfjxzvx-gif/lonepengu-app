/// API Configuration for LonePengu Backend
///
/// Configure your backend URL and API settings here.
/// Use environment variables for production deployment.

class ApiConfig {
  // ═══════════════════════════════════════════════════════════════
  // BASE URL CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  /// Development backend URL
  static const String devBaseUrl = 'http://localhost:3000/api';

  /// Production backend URL (replace with your actual backend URL)
  static const String prodBaseUrl = 'https://api.lonepengu.com/api';

  /// Current environment
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  /// Active base URL
  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;

  // ═══════════════════════════════════════════════════════════════
  // API ENDPOINTS
  // ═══════════════════════════════════════════════════════════════

  /// Authentication endpoints
  static String get authLogin => '$baseUrl/auth/login';
  static String get authLogout => '$baseUrl/auth/logout';
  static String get authRefresh => '$baseUrl/auth/refresh';
  static String get authValidate => '$baseUrl/auth/validate';

  /// User endpoints
  static String get userMe => '$baseUrl/user/me';
  static String get userUpdate => '$baseUrl/user/update';
  static String get userPreferences => '$baseUrl/user/preferences';
  static String get userAppState => '$baseUrl/user/app-state';

  // ═══════════════════════════════════════════════════════════════
  // REQUEST CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  /// Request timeout in seconds
  static const int requestTimeout = 30;

  /// Session expiry in hours (30 days)
  static const int sessionExpiryHours = 720;

  /// Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-App-Version': '1.0.0',
    'X-Platform': 'flutter',
  };

  /// Get headers with auth token
  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}

/// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? errorCode;
  final int statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
    this.statusCode = 200,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: 200,
    );
  }

  factory ApiResponse.error(
    String message, {
    String? errorCode,
    int statusCode = 500,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
    );
  }

  bool get isError => !success;
}

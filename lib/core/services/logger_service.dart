import 'package:flutter/foundation.dart';

/// Centralized Logger Service
/// Provides consistent logging across the app
class LoggerService {
  static bool _enabled = true;
  static LogLevel _minLevel = LogLevel.debug;

  /// Enable/disable logging
  static void setEnabled(bool enabled) => _enabled = enabled;

  /// Set minimum log level
  static void setMinLevel(LogLevel level) => _minLevel = level;

  /// Debug log
  static void debug(String message, [dynamic data]) {
    _log(LogLevel.debug, message, data);
  }

  /// Info log
  static void info(String message, [dynamic data]) {
    _log(LogLevel.info, message, data);
  }

  /// Warning log
  static void warning(String message, [dynamic data]) {
    _log(LogLevel.warning, message, data);
  }

  /// Error log
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error);
    if (stackTrace != null && kDebugMode) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Internal log method
  static void _log(LogLevel level, String message, [dynamic data]) {
    if (!_enabled) return;
    if (level.index < _minLevel.index) return;

    final prefix = _getPrefix(level);
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);

    if (kDebugMode) {
      debugPrint('[$timestamp] $prefix $message');
      if (data != null) {
        debugPrint('  Data: $data');
      }
    }

    // In production, you could send to crash reporting service
    if (level == LogLevel.error && !kDebugMode) {
      // TODO: Send to Sentry, Crashlytics, etc.
    }
  }

  static String _getPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍 DEBUG';
      case LogLevel.info:
        return 'ℹ️ INFO';
      case LogLevel.warning:
        return '⚠️ WARN';
      case LogLevel.error:
        return '❌ ERROR';
    }
  }

  /// Log API request
  static void apiRequest(String method, String url, [dynamic body]) {
    debug('API $method: $url', body);
  }

  /// Log API response
  static void apiResponse(String url, int statusCode, [dynamic body]) {
    if (statusCode >= 200 && statusCode < 300) {
      debug('API Response [$statusCode]: $url');
    } else {
      warning('API Response [$statusCode]: $url', body);
    }
  }

  /// Log app lifecycle
  static void lifecycle(String state) {
    info('App Lifecycle: $state');
  }

  /// Log navigation
  static void navigation(String route) {
    debug('Navigation: $route');
  }

  /// Log auth events
  static void auth(String event, [dynamic data]) {
    info('Auth: $event', data);
  }
}

enum LogLevel { debug, info, warning, error }

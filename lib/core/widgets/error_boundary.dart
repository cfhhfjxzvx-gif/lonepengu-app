import 'package:flutter/material.dart';
import '../design/lp_design.dart';
import '../services/logger_service.dart';

/// Global Error Boundary Widget
/// Catches and handles errors gracefully without crashing the app
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails error)? errorBuilder;
  final VoidCallback? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();
    // Set up global error handler
    FlutterError.onError = _handleFlutterError;
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    LoggerService.error(
      'Flutter Error: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );

    widget.onError?.call();

    // Only update state if it's a rendering error
    if (details.library == 'rendering library' ||
        details.library == 'widgets library') {
      setState(() => _error = details);
    }
  }

  void _reset() {
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          _DefaultErrorWidget(error: _error!, onRetry: _reset);
    }
    return widget.child;
  }
}

/// Default error display widget
class _DefaultErrorWidget extends StatelessWidget {
  final FlutterErrorDetails error;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.report_gmailerrorred_rounded,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
              ),
              const Gap(height: 32),
              Text(
                'Something went wrong',
                style: LPText.hLG.copyWith(color: theme.colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const Gap(height: 12),
              Text(
                'An unexpected error occurred in the application layer. Our team has been notified.',
                style: LPText.bodySM.copyWith(
                  color: isDark
                      ? LPColors.textSecondaryDark
                      : LPColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(height: 48),
              AppButton.primary(
                label: 'Restore Workspace',
                icon: Icons.refresh_rounded,
                onTap: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Async Error Handler
/// Use this to wrap async operations
class AsyncErrorHandler {
  /// Execute async operation with error handling
  static Future<T?> run<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    void Function(dynamic error)? onError,
  }) async {
    try {
      return await operation();
    } catch (e, stack) {
      LoggerService.error(errorMessage ?? 'Async operation failed', e, stack);
      onError?.call(e);
      return null;
    }
  }

  /// Execute async operation with fallback
  static Future<T> runWithFallback<T>(
    Future<T> Function() operation,
    T fallback, {
    String? errorMessage,
  }) async {
    try {
      return await operation();
    } catch (e, stack) {
      LoggerService.error(errorMessage ?? 'Async operation failed', e, stack);
      return fallback;
    }
  }
}

/// Error Display Helpers
class ErrorDisplayHelper {
  /// Show error snackbar
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: LPColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: LPRadius.smBorder),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: LPColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: LPRadius.smBorder),
      ),
    );
  }

  /// Show warning snackbar
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: LPColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: LPRadius.smBorder),
      ),
    );
  }
}

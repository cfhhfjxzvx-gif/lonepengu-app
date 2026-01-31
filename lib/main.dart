import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/services/app_lifecycle_observer.dart';
import 'core/services/logger_service.dart';
import 'core/widgets/error_boundary.dart';
import 'core/theme/theme_manager.dart';
import 'core/widgets/app_bootstrap.dart';
import 'routes/root_router.dart';

void main() async {
  // ═══════════════════════════════════════════════════════════════
  // GLOBAL ERROR HANDLING
  // ═══════════════════════════════════════════════════════════════

  // Catch all uncaught async errors
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Set up Flutter error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        LoggerService.error(
          'Flutter Error: ${details.exceptionAsString()}',
          details.exception,
          details.stack,
        );
        // In production, send to crash reporting
        if (kReleaseMode) {
          // TODO: Send to Sentry/Crashlytics
        }
      };

      // ═══════════════════════════════════════════════════════════════
      // INITIALIZATION
      // ═══════════════════════════════════════════════════════════════

      LoggerService.info('LonePengu App Starting');

      // ═══════════════════════════════════════════════════════════════
      // RUN APP IMMEIDATELY
      // ═══════════════════════════════════════════════════════════════

      runApp(const AppBootstrap(child: LonePenguApp()));
    },
    (error, stackTrace) {
      // Handle uncaught async errors
      LoggerService.error('Uncaught Error', error, stackTrace);
    },
  );
}

/// Main App Widget
class LonePenguApp extends StatefulWidget {
  const LonePenguApp({super.key});

  @override
  State<LonePenguApp> createState() => _LonePenguAppState();
}

class _LonePenguAppState extends State<LonePenguApp> {
  @override
  void dispose() {
    // Clean up lifecycle observer
    AppLifecycleObserver.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ═══════════════════════════════════════════════════════════════
    // PROVIDERS
    // ═══════════════════════════════════════════════════════════════
    return MultiProvider(
      providers: [
        // Auth Provider - manages authentication state
        ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
        ),
        // Theme Manager
        ChangeNotifierProvider<ThemeManager>.value(
          value: ThemeManager.instance,
        ),
      ],
      child: const _AppContent(),
    );
  }
}

/// App Content (separated for Provider access)
class _AppContent extends StatelessWidget {
  const _AppContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        return ErrorBoundary(
          onError: () {
            LoggerService.error('Error boundary triggered');
          },
          child: MaterialApp(
            title: 'LonePengu',
            debugShowCheckedModeBanner: false,

            // Theme
            theme: themeManager.lightTheme,
            darkTheme: themeManager.darkTheme,
            themeMode: themeManager.themeMode,

            // STRICT NAVIGATION: Use RootRouter for logic
            home: RootRouter(),

            // Global Error Widget
            builder: (context, child) {
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Something went wrong.\nPlease restart the app.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                );
              };
              return child ?? const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}

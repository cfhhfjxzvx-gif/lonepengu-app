import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/design/lp_design.dart';
import 'core/providers/auth_provider.dart';
import 'core/services/app_lifecycle_observer.dart';
import 'core/services/logger_service.dart';
import 'core/services/secure_storage_service.dart';
import 'core/widgets/error_boundary.dart';
import 'core/theme/theme_manager.dart';
import 'routes/app_router.dart';

// Feature Storage
import 'features/content_studio/data/draft_storage.dart';
import 'features/scheduler/data/scheduler_storage.dart';
import 'features/settings/data/settings_storage.dart';
import 'features/account_management/data/account_storage.dart';
import 'features/notifications/data/notification_storage.dart';

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

      // Initialize secure storage first (required for auth)
      await SecureStorageService.instance.init();

      // Initialize Feature Storage
      await Future.wait([
        DraftStorage.init(),
        SchedulerStorage.init(),
        SettingsStorage.init(),
        AccountStorage.init(),
        NotificationStorage.init(),
      ]);

      // Initialize Theme
      await ThemeManager.instance.init();

      // Initialize App Lifecycle Observer (prevents restart issues)
      AppLifecycleObserver.instance.init(
        onResume: () {
          LoggerService.lifecycle('App resumed - maintaining state');
          // DO NOT reinitialize anything here
          // State is already preserved
        },
        onPause: () {
          LoggerService.lifecycle('App paused - saving state');
          // State is automatically saved by the observer
        },
      );

      LoggerService.info('Initialization complete');

      // ═══════════════════════════════════════════════════════════════
      // RUN APP
      // ═══════════════════════════════════════════════════════════════

      runApp(const LonePenguApp());
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
          child: MaterialApp.router(
            title: 'LonePengu',
            debugShowCheckedModeBanner: false,

            // Theme
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeManager.themeMode,

            // Router
            routerConfig: AppRouter.router,

            // Builder for global widgets
            builder: (context, child) {
              // You can add global widgets here
              // Like connectivity indicator, etc.
              return child ?? const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}

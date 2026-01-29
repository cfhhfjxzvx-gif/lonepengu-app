import 'package:flutter/material.dart';
import '../services/logger_service.dart';
import '../services/secure_storage_service.dart';
import '../services/app_lifecycle_observer.dart';
import '../providers/auth_provider.dart';
import '../theme/theme_manager.dart';

// Feature Storage
import '../../features/content_studio/data/draft_storage.dart';
import '../../features/scheduler/data/scheduler_storage.dart';
import '../../features/settings/data/settings_storage.dart';
import '../../features/account_management/data/account_storage.dart';
import '../../features/notifications/data/notification_storage.dart';

/// AppBootstrap handles the critical async initialization of the app.
/// It renders a Splash Screen immediately, ensuring no white screen on launch.
class AppBootstrap extends StatefulWidget {
  final Widget child;

  const AppBootstrap({super.key, required this.child});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      LoggerService.info('AppBootstrap: Starting initialization');

      // 1. Initialize secure storage first (required for auth)
      await SecureStorageService.instance.init();

      // 2. Initialize Feature Storage (Concurrent)
      await Future.wait([
        DraftStorage.init(),
        SchedulerStorage.init(),
        SettingsStorage.init(),
        AccountStorage.init(),
        NotificationStorage.init(),
      ]);

      // 3. Initialize AuthProvider (restores session)
      // This is safe even if it takes time, as we are showing a splash UI
      await AuthProvider.instance.initialize();

      // 4. Initialize Theme
      await ThemeManager.instance.init();

      // 5. Initialize Lifecycle Observer
      // Note: Logic moved here from main.dart
      AppLifecycleObserver.instance.init(
        onResume: () {
          LoggerService.lifecycle('App resumed - maintaining state');
        },
        onPause: () {
          LoggerService.lifecycle('App paused - saving state');
        },
      );

      LoggerService.info('AppBootstrap: Initialization complete');
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e, stack) {
      LoggerService.error('AppBootstrap: Initialization Failed', e, stack);
      if (mounted) {
        setState(() {
          _error = e.toString();
          // Even on error, we might want to let the app proceed or show a specific error screen
          // For now, we'll mark as initialized so the user isn't stuck on splash forever,
          // but arguably a "Retry" screen is better.
          // Let's set initialized = true and rely on ErrorBoundary or UI to handle broken state,
          // OR show a red screen only if it's truly fatal.
          // BUT per user request: "The app must ALWAYS render a visible screen"
          // So we proceed.
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If not initialized, showing a safe, hardcoded Splash Screen
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF1E3A5F), // LonePengu Blue (Dark)
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hardcoded Logo implementation to be safe
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      );
    }

    // Once initialized, render the actual app
    return widget.child;
  }
}

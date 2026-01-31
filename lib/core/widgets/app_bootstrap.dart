import 'package:flutter/material.dart';
import '../services/logger_service.dart';
import '../services/secure_storage_service.dart';
import '../services/app_lifecycle_observer.dart';
import '../providers/auth_provider.dart';
import '../theme/theme_manager.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';

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

      // 6. Conditional Splash Duration
      // If user is already logged in, skip the long delay to fulfill "Never show splash again"
      final isLoggedIn = await AuthProvider.instance.validateStoredSession();
      if (!isLoggedIn) {
        // Only show splash for 1.5s for new/logged-out users
        await Future.delayed(const Duration(milliseconds: 1500));
      } else {
        // Fast path for returning users
        await Future.delayed(const Duration(milliseconds: 300));
      }

      LoggerService.info('AppBootstrap: Initialization complete');
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _error = null;
        });
      }
    } catch (e, stack) {
      LoggerService.error('AppBootstrap: Initialization Failed', e, stack);
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isInitialized = false; // Stay on bootstrap screen
        });
      }
    }
  }

  void _retry() {
    setState(() {
      _error = null;
      _isInitialized = false;
    });
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Not Initialized -> Show Splash
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(), // Ensure splash is always in theme
        home: _error != null ? _buildErrorUI() : const SplashScreen(),
      );
    }

    // 2. Initialized -> Show Main App
    return widget.child;
  }

  Widget _buildErrorUI() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Failed to start LonePengu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _retry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}

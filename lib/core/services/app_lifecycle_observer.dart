import 'package:flutter/material.dart';
import '../services/logger_service.dart';
import '../services/secure_storage_service.dart';

/// App Lifecycle Observer
/// Prevents app restart issues and maintains state when backgrounded
class AppLifecycleObserver extends WidgetsBindingObserver {
  static AppLifecycleObserver? _instance;
  static AppLifecycleObserver get instance =>
      _instance ??= AppLifecycleObserver._();

  AppLifecycleObserver._();

  // Current app state
  AppLifecycleState _currentState = AppLifecycleState.resumed;
  AppLifecycleState get currentState => _currentState;

  // Callbacks
  VoidCallback? _onResume;
  VoidCallback? _onPause;
  VoidCallback? _onInactive;
  VoidCallback? _onDetached;
  VoidCallback? _onHidden;

  // State preservation
  String? _lastRoute;
  Map<String, dynamic>? _preservedState;
  bool _isInitialized = false;

  // ═══════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════

  /// Initialize the observer
  void init({
    VoidCallback? onResume,
    VoidCallback? onPause,
    VoidCallback? onInactive,
    VoidCallback? onDetached,
    VoidCallback? onHidden,
  }) {
    if (_isInitialized) return;

    _onResume = onResume;
    _onPause = onPause;
    _onInactive = onInactive;
    _onDetached = onDetached;
    _onHidden = onHidden;

    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;

    LoggerService.lifecycle('Observer initialized');
  }

  /// Dispose the observer
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
    LoggerService.lifecycle('Observer disposed');
  }

  // ═══════════════════════════════════════════════════════════════
  // LIFECYCLE HANDLING
  // ═══════════════════════════════════════════════════════════════

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final previousState = _currentState;
    _currentState = state;

    LoggerService.lifecycle('State changed: $previousState -> $state');

    switch (state) {
      case AppLifecycleState.resumed:
        _handleResumed(previousState);
        break;
      case AppLifecycleState.paused:
        _handlePaused();
        break;
      case AppLifecycleState.inactive:
        _handleInactive();
        break;
      case AppLifecycleState.detached:
        _handleDetached();
        break;
      case AppLifecycleState.hidden:
        _handleHidden();
        break;
    }
  }

  void _handleResumed(AppLifecycleState previousState) {
    LoggerService.lifecycle('App resumed from: $previousState');

    // CRITICAL: Do NOT reinitialize or restart on resume
    // Only restore minimal necessary state

    // If coming back from paused/hidden, just continue
    // No need to reload data or reset navigation

    _onResume?.call();
  }

  void _handlePaused() {
    LoggerService.lifecycle('App paused - saving state');

    // Save current state before going to background
    _saveCurrentState();

    _onPause?.call();
  }

  void _handleInactive() {
    LoggerService.lifecycle('App inactive');
    _onInactive?.call();
  }

  void _handleDetached() {
    LoggerService.lifecycle('App detached');
    _onDetached?.call();
  }

  void _handleHidden() {
    LoggerService.lifecycle('App hidden');
    _onHidden?.call();
  }

  // ═══════════════════════════════════════════════════════════════
  // STATE PRESERVATION
  // ═══════════════════════════════════════════════════════════════

  /// Save current route for restoration
  void setCurrentRoute(String route) {
    _lastRoute = route;
    // Persist to storage for surviving app kills
    SecureStorageService.instance.saveLastRoute(route);
  }

  /// Get last known route
  String? getLastRoute() => _lastRoute;

  /// Save state for preservation
  void preserveState(String key, dynamic value) {
    _preservedState ??= {};
    _preservedState![key] = value;
  }

  /// Get preserved state
  T? getPreservedState<T>(String key) {
    return _preservedState?[key] as T?;
  }

  /// Clear preserved state
  void clearPreservedState() {
    _preservedState = null;
  }

  Future<void> _saveCurrentState() async {
    if (_lastRoute != null) {
      await SecureStorageService.instance.saveLastRoute(_lastRoute!);
    }
    if (_preservedState != null && _preservedState!.isNotEmpty) {
      await SecureStorageService.instance.saveAppState(_preservedState!);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Check if app is in foreground
  bool get isInForeground => _currentState == AppLifecycleState.resumed;

  /// Check if app is in background
  bool get isInBackground =>
      _currentState == AppLifecycleState.paused ||
      _currentState == AppLifecycleState.hidden;

  /// Check if app was just resumed (useful for refresh logic)
  bool _wasJustResumed = false;
  bool get wasJustResumed {
    if (_wasJustResumed) {
      _wasJustResumed = false;
      return true;
    }
    return false;
  }
}

/// Mixin for StatefulWidgets that need lifecycle awareness
mixin AppLifecycleAware<T extends StatefulWidget> on State<T> {
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    _lastLifecycleState = AppLifecycleObserver.instance.currentState;
  }

  /// Called when app resumes
  /// Override this instead of checking lifecycle manually
  void onAppResumed() {
    // Override in subclass if needed
  }

  /// Called when app pauses
  void onAppPaused() {
    // Override in subclass if needed
  }

  /// Check if app just resumed (useful in build/didChangeDependencies)
  bool checkIfResumed() {
    final currentState = AppLifecycleObserver.instance.currentState;
    if (_lastLifecycleState != AppLifecycleState.resumed &&
        currentState == AppLifecycleState.resumed) {
      _lastLifecycleState = currentState;
      return true;
    }
    _lastLifecycleState = currentState;
    return false;
  }
}

/// Widget that automatically preserves its state
/// Use this for screens that should maintain state across backgrounding
class StatePreservingWidget extends StatefulWidget {
  final Widget child;
  final String stateKey;

  const StatePreservingWidget({
    super.key,
    required this.child,
    required this.stateKey,
  });

  @override
  State<StatePreservingWidget> createState() => _StatePreservingWidgetState();
}

class _StatePreservingWidgetState extends State<StatePreservingWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

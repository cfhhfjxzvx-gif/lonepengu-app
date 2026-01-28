/// Analytics Service - BRD Section 7: Success Metrics (KPIs)
///
/// Provides analytics tracking with:
/// - Local storage for MVP
/// - Future Firebase/Mixpanel integration support
/// - Session tracking
/// - Event batching

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_events.dart';

/// Abstract analytics service interface
/// Replace with Firebase/Mixpanel implementation later
abstract class AnalyticsService {
  /// Initialize the analytics service
  Future<void> initialize();

  /// Track an event
  Future<void> track(AnalyticsEvent event);

  /// Track a screen view
  Future<void> trackScreenView(String screenName);

  /// Track signup
  Future<void> trackSignup({String? method});

  /// Track post created
  Future<void> trackPostCreated({
    required String contentType,
    required List<String> platforms,
  });

  /// Track AI generation
  Future<void> trackAIGeneration({
    required String assetType,
    required int creditsUsed,
    String? style,
  });

  /// Track session start
  Future<void> trackSessionStart();

  /// Track session end
  Future<void> trackSessionEnd();

  /// Set user ID
  Future<void> setUserId(String userId);

  /// Clear user data
  Future<void> clearUserData();

  /// Get local analytics summary
  Future<Map<String, dynamic>> getLocalSummary();
}

/// Local analytics implementation for MVP
/// Stores counters locally and uses debugPrint for logging
class LocalAnalyticsService implements AnalyticsService {
  static const String _storageKey = 'analytics_counters';
  static const String _eventsKey = 'analytics_events';
  static const int _maxStoredEvents = 100;

  SharedPreferences? _prefs;
  String? _userId;
  String? _sessionId;
  DateTime? _sessionStartTime;
  final List<AnalyticsEvent> _eventBuffer = [];

  // Counters
  int _screenViews = 0;
  int _postsCreated = 0;
  int _aiGenerations = 0;
  int _sessionsCount = 0;
  int _totalCreditsUsed = 0;

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadCounters();
    await trackSessionStart();
  }

  Future<void> _loadCounters() async {
    try {
      final countersJson = _prefs?.getString(_storageKey);
      if (countersJson != null) {
        final counters = jsonDecode(countersJson) as Map<String, dynamic>;
        _screenViews = counters['screenViews'] ?? 0;
        _postsCreated = counters['postsCreated'] ?? 0;
        _aiGenerations = counters['aiGenerations'] ?? 0;
        _sessionsCount = counters['sessionsCount'] ?? 0;
        _totalCreditsUsed = counters['totalCreditsUsed'] ?? 0;
      }
    } catch (e) {
      debugPrint('[Analytics] Error loading counters: $e');
    }
  }

  Future<void> _saveCounters() async {
    try {
      await _prefs?.setString(
        _storageKey,
        jsonEncode({
          'screenViews': _screenViews,
          'postsCreated': _postsCreated,
          'aiGenerations': _aiGenerations,
          'sessionsCount': _sessionsCount,
          'totalCreditsUsed': _totalCreditsUsed,
          'lastUpdated': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      debugPrint('[Analytics] Error saving counters: $e');
    }
  }

  @override
  Future<void> track(AnalyticsEvent event) async {
    // Log event
    debugPrint(
      '[Analytics] ${event.type.name}: ${jsonEncode(event.properties)}',
    );

    // Add to buffer
    _eventBuffer.add(event);

    // Save periodically
    if (_eventBuffer.length >= 10) {
      await _flushEventBuffer();
    }

    // Update counters based on event type
    switch (event.type) {
      case AnalyticsEventType.screenViewed:
        _screenViews++;
        break;
      case AnalyticsEventType.postCreated:
        _postsCreated++;
        break;
      case AnalyticsEventType.aiTextGenerated:
      case AnalyticsEventType.aiImageGenerated:
      case AnalyticsEventType.aiVideoGenerated:
        _aiGenerations++;
        _totalCreditsUsed += (event.properties?['credits_used'] ?? 0) as int;
        break;
      case AnalyticsEventType.sessionStarted:
        _sessionsCount++;
        break;
      default:
        break;
    }

    await _saveCounters();
  }

  Future<void> _flushEventBuffer() async {
    try {
      // Load existing events
      final eventsJson = _prefs?.getString(_eventsKey);
      List<Map<String, dynamic>> events = [];
      if (eventsJson != null) {
        events = List<Map<String, dynamic>>.from(jsonDecode(eventsJson));
      }

      // Add new events
      for (final event in _eventBuffer) {
        events.add(event.toJson());
      }

      // Keep only recent events
      if (events.length > _maxStoredEvents) {
        events = events.sublist(events.length - _maxStoredEvents);
      }

      // Save
      await _prefs?.setString(_eventsKey, jsonEncode(events));
      _eventBuffer.clear();
    } catch (e) {
      debugPrint('[Analytics] Error flushing events: $e');
    }
  }

  @override
  Future<void> trackScreenView(String screenName) async {
    await track(AnalyticsEvent.screenView(screenName, userId: _userId));
  }

  @override
  Future<void> trackSignup({String? method}) async {
    await track(
      AnalyticsEvent(
        type: AnalyticsEventType.signUpCompleted,
        timestamp: DateTime.now(),
        userId: _userId,
        sessionId: _sessionId,
        properties: {'method': method ?? 'email'},
      ),
    );
  }

  @override
  Future<void> trackPostCreated({
    required String contentType,
    required List<String> platforms,
  }) async {
    await track(
      AnalyticsEvent.postCreated(
        contentType: contentType,
        platforms: platforms,
        userId: _userId,
      ),
    );
  }

  @override
  Future<void> trackAIGeneration({
    required String assetType,
    required int creditsUsed,
    String? style,
  }) async {
    await track(
      AnalyticsEvent.aiGeneration(
        assetType: assetType,
        creditsUsed: creditsUsed,
        style: style,
        userId: _userId,
      ),
    );
  }

  @override
  Future<void> trackSessionStart() async {
    _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    _sessionStartTime = DateTime.now();

    await track(
      AnalyticsEvent(
        type: AnalyticsEventType.sessionStarted,
        timestamp: DateTime.now(),
        userId: _userId,
        sessionId: _sessionId,
      ),
    );
  }

  @override
  Future<void> trackSessionEnd() async {
    final duration = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!).inSeconds
        : 0;

    await track(
      AnalyticsEvent(
        type: AnalyticsEventType.sessionEnded,
        timestamp: DateTime.now(),
        userId: _userId,
        sessionId: _sessionId,
        properties: {'duration_seconds': duration},
      ),
    );

    await _flushEventBuffer();
  }

  @override
  Future<void> setUserId(String userId) async {
    _userId = userId;
    debugPrint('[Analytics] User ID set: $userId');
  }

  @override
  Future<void> clearUserData() async {
    _userId = null;
    _eventBuffer.clear();
    _screenViews = 0;
    _postsCreated = 0;
    _aiGenerations = 0;
    _sessionsCount = 0;
    _totalCreditsUsed = 0;
    await _prefs?.remove(_storageKey);
    await _prefs?.remove(_eventsKey);
    debugPrint('[Analytics] User data cleared');
  }

  @override
  Future<Map<String, dynamic>> getLocalSummary() async {
    return {
      'screenViews': _screenViews,
      'postsCreated': _postsCreated,
      'aiGenerations': _aiGenerations,
      'sessionsCount': _sessionsCount,
      'totalCreditsUsed': _totalCreditsUsed,
      'currentSessionId': _sessionId,
      'userId': _userId,
    };
  }
}

/// Analytics service provider singleton
class Analytics {
  static AnalyticsService? _instance;

  /// Get the analytics service instance
  static AnalyticsService get instance {
    _instance ??= LocalAnalyticsService();
    return _instance!;
  }

  /// Set a custom analytics service (for production)
  static void setInstance(AnalyticsService service) {
    _instance = service;
  }

  /// Convenience method to track screen views
  static Future<void> screenView(String name) => instance.trackScreenView(name);

  /// Convenience method to track events
  static Future<void> track(AnalyticsEvent event) => instance.track(event);

  /// Convenience method to track post creation
  static Future<void> postCreated({
    required String contentType,
    required List<String> platforms,
  }) =>
      instance.trackPostCreated(contentType: contentType, platforms: platforms);

  /// Convenience method to track AI generation
  static Future<void> aiGeneration({
    required String assetType,
    required int creditsUsed,
    String? style,
  }) => instance.trackAIGeneration(
    assetType: assetType,
    creditsUsed: creditsUsed,
    style: style,
  );
}

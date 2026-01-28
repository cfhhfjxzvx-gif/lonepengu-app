/// Fallback & Queue System - BRD Section 11: Risks & Mitigations
///
/// Provides:
/// - AI outage fallback logic
/// - Rate limit simulation
/// - Request queue simulation
/// - Local usage counters for cost control

import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Request priority levels
enum RequestPriority { low, normal, high, critical }

/// Queued request model
class QueuedRequest<T> {
  final String id;
  final Future<T> Function() execute;
  final RequestPriority priority;
  final DateTime createdAt;
  final Completer<T> completer;
  int retryCount;
  String? error;

  QueuedRequest({
    required this.id,
    required this.execute,
    this.priority = RequestPriority.normal,
    this.retryCount = 0,
  }) : createdAt = DateTime.now(),
       completer = Completer<T>();

  Future<T> get future => completer.future;
}

/// Queue status
enum QueueStatus { idle, processing, paused, rateLimited }

/// Request queue for rate limiting and retries
class RequestQueue<T> {
  final int maxConcurrent;
  final int maxRetries;
  final Duration retryDelay;
  final Duration rateLimitDelay;

  QueueStatus _status = QueueStatus.idle;
  int _activeRequests = 0;
  final Queue<QueuedRequest<T>> _queue = Queue();
  final List<QueuedRequest<T>> _completed = [];
  final List<QueuedRequest<T>> _failed = [];

  RequestQueue({
    this.maxConcurrent = 3,
    this.maxRetries = 2,
    this.retryDelay = const Duration(seconds: 2),
    this.rateLimitDelay = const Duration(seconds: 30),
  });

  QueueStatus get status => _status;
  int get pendingCount => _queue.length;
  int get activeCount => _activeRequests;
  int get completedCount => _completed.length;
  int get failedCount => _failed.length;

  /// Add a request to the queue
  Future<T> enqueue(
    String id,
    Future<T> Function() execute, {
    RequestPriority priority = RequestPriority.normal,
  }) {
    final request = QueuedRequest<T>(
      id: id,
      execute: execute,
      priority: priority,
    );

    // Insert based on priority
    if (priority == RequestPriority.critical) {
      _queue.addFirst(request);
    } else if (priority == RequestPriority.high) {
      // Insert after critical items
      final criticalCount = _queue
          .where((r) => r.priority == RequestPriority.critical)
          .length;
      final list = _queue.toList();
      list.insert(criticalCount, request);
      _queue.clear();
      _queue.addAll(list);
    } else {
      _queue.add(request);
    }

    _processQueue();
    return request.future;
  }

  /// Process the queue
  void _processQueue() {
    if (_status == QueueStatus.paused || _status == QueueStatus.rateLimited) {
      return;
    }

    while (_activeRequests < maxConcurrent && _queue.isNotEmpty) {
      final request = _queue.removeFirst();
      _executeRequest(request);
    }

    _status = _activeRequests > 0 ? QueueStatus.processing : QueueStatus.idle;
  }

  /// Execute a single request
  Future<void> _executeRequest(QueuedRequest<T> request) async {
    _activeRequests++;

    try {
      final result = await request.execute();
      request.completer.complete(result);
      _completed.add(request);
      debugPrint('[Queue] Request ${request.id} completed');
    } catch (e) {
      request.error = e.toString();
      request.retryCount++;

      if (_isRateLimitError(e)) {
        // Rate limited - pause queue
        _status = QueueStatus.rateLimited;
        _queue.addFirst(request); // Re-queue at front
        debugPrint(
          '[Queue] Rate limited, pausing for ${rateLimitDelay.inSeconds}s',
        );

        Future.delayed(rateLimitDelay, () {
          _status = QueueStatus.idle;
          _processQueue();
        });
      } else if (request.retryCount <= maxRetries) {
        // Retry
        debugPrint(
          '[Queue] Request ${request.id} failed, retry ${request.retryCount}/$maxRetries',
        );
        _queue.addFirst(request);

        Future.delayed(retryDelay, _processQueue);
      } else {
        // Max retries exceeded
        request.completer.completeError(e);
        _failed.add(request);
        debugPrint('[Queue] Request ${request.id} failed permanently: $e');
      }
    } finally {
      _activeRequests--;
      _processQueue();
    }
  }

  bool _isRateLimitError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('rate limit') ||
        errorString.contains('429') ||
        errorString.contains('too many requests');
  }

  /// Pause the queue
  void pause() {
    _status = QueueStatus.paused;
    debugPrint('[Queue] Paused');
  }

  /// Resume the queue
  void resume() {
    _status = QueueStatus.idle;
    _processQueue();
    debugPrint('[Queue] Resumed');
  }

  /// Clear the queue
  void clear() {
    for (final request in _queue) {
      request.completer.completeError('Queue cleared');
    }
    _queue.clear();
    _status = QueueStatus.idle;
    debugPrint('[Queue] Cleared');
  }

  /// Get queue stats
  Map<String, dynamic> getStats() {
    return {
      'status': _status.name,
      'pending': pendingCount,
      'active': activeCount,
      'completed': completedCount,
      'failed': failedCount,
    };
  }
}

/// Usage counter for cost control
class UsageCounter {
  final String name;
  final int dailyLimit;
  final int monthlyLimit;

  int _dailyUsage = 0;
  int _monthlyUsage = 0;
  DateTime _dailyResetAt = DateTime.now();
  DateTime _monthlyResetAt = DateTime.now();

  UsageCounter({
    required this.name,
    this.dailyLimit = 100,
    this.monthlyLimit = 1000,
  });

  int get dailyUsage => _dailyUsage;
  int get monthlyUsage => _monthlyUsage;
  int get dailyRemaining => dailyLimit - _dailyUsage;
  int get monthlyRemaining => monthlyLimit - _monthlyUsage;
  bool get hasReachedDailyLimit => _dailyUsage >= dailyLimit;
  bool get hasReachedMonthlyLimit => _monthlyUsage >= monthlyLimit;

  /// Check and reset counters if needed
  void _checkReset() {
    final now = DateTime.now();

    // Daily reset
    if (now.difference(_dailyResetAt).inDays >= 1) {
      _dailyUsage = 0;
      _dailyResetAt = DateTime(now.year, now.month, now.day);
      debugPrint('[UsageCounter] $name daily counter reset');
    }

    // Monthly reset
    if (now.month != _monthlyResetAt.month ||
        now.year != _monthlyResetAt.year) {
      _monthlyUsage = 0;
      _monthlyResetAt = DateTime(now.year, now.month, 1);
      debugPrint('[UsageCounter] $name monthly counter reset');
    }
  }

  /// Increment usage
  bool increment([int amount = 1]) {
    _checkReset();

    if (_dailyUsage + amount > dailyLimit) {
      debugPrint('[UsageCounter] $name daily limit reached');
      return false;
    }

    if (_monthlyUsage + amount > monthlyLimit) {
      debugPrint('[UsageCounter] $name monthly limit reached');
      return false;
    }

    _dailyUsage += amount;
    _monthlyUsage += amount;
    debugPrint(
      '[UsageCounter] $name usage: $_dailyUsage/$dailyLimit daily, $_monthlyUsage/$monthlyLimit monthly',
    );
    return true;
  }

  /// Check if can use
  bool canUse([int amount = 1]) {
    _checkReset();
    return _dailyUsage + amount <= dailyLimit &&
        _monthlyUsage + amount <= monthlyLimit;
  }

  /// Get stats
  Map<String, dynamic> getStats() {
    _checkReset();
    return {
      'name': name,
      'dailyUsage': _dailyUsage,
      'dailyLimit': dailyLimit,
      'dailyRemaining': dailyRemaining,
      'monthlyUsage': _monthlyUsage,
      'monthlyLimit': monthlyLimit,
      'monthlyRemaining': monthlyRemaining,
    };
  }
}

/// Fallback provider for AI services
class AIFallbackProvider {
  final List<String> _fallbackCaptions = [
    "✨ Something amazing is happening! Stay tuned for more updates.",
    "🚀 We're working on something special. What do you think?",
    "💡 New ideas are brewing. Can't wait to share them with you!",
    "🎯 Focus. Create. Inspire. Repeat.",
    "🌟 Every day is a new opportunity to create something beautiful.",
  ];

  final List<String> _fallbackHashtags = [
    '#content',
    '#creation',
    '#socialmedia',
    '#marketing',
    '#brand',
    '#creative',
    '#design',
    '#inspiration',
  ];

  /// Get fallback caption when AI is unavailable
  String getFallbackCaption({String? context}) {
    final index =
        (context?.hashCode ?? DateTime.now().millisecondsSinceEpoch) %
        _fallbackCaptions.length;
    return _fallbackCaptions[index.abs()];
  }

  /// Get fallback hashtags when AI is unavailable
  List<String> getFallbackHashtags({int count = 5, String? context}) {
    final startIndex =
        (context?.hashCode ?? DateTime.now().millisecondsSinceEpoch) %
        _fallbackHashtags.length;
    final result = <String>[];
    for (var i = 0; i < count && i < _fallbackHashtags.length; i++) {
      result.add(
        _fallbackHashtags[(startIndex.abs() + i) % _fallbackHashtags.length],
      );
    }
    return result;
  }

  /// Get fallback message for unavailable feature
  String getUnavailableMessage(String feature) {
    return '$feature is temporarily unavailable. Please try again later.';
  }
}

/// Global usage counters
class UsageManager {
  static final UsageCounter aiText = UsageCounter(
    name: 'AI Text',
    dailyLimit: 50,
    monthlyLimit: 500,
  );

  static final UsageCounter aiImage = UsageCounter(
    name: 'AI Image',
    dailyLimit: 20,
    monthlyLimit: 200,
  );

  static final UsageCounter aiVideo = UsageCounter(
    name: 'AI Video',
    dailyLimit: 5,
    monthlyLimit: 50,
  );

  static final UsageCounter scheduling = UsageCounter(
    name: 'Scheduling',
    dailyLimit: 50,
    monthlyLimit: 500,
  );

  static final AIFallbackProvider fallback = AIFallbackProvider();

  static Map<String, dynamic> getAllStats() {
    return {
      'aiText': aiText.getStats(),
      'aiImage': aiImage.getStats(),
      'aiVideo': aiVideo.getStats(),
      'scheduling': scheduling.getStats(),
    };
  }
}

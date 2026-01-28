import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'scheduler_models.dart';

/// Storage service for scheduler data using SharedPreferences
/// Works on Web, Android, and iOS
class SchedulerStorage {
  static const String _scheduledPostsKey = 'scheduled_posts';
  static const String _queueItemsKey = 'queue_items';
  static const String _queuePausedKey = 'queue_paused';
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ==================== SCHEDULED POSTS ====================

  /// Save a scheduled post
  static Future<bool> saveScheduledPost(ScheduledPost post) async {
    try {
      final posts = await loadAllScheduledPosts();

      final existingIndex = posts.indexWhere((p) => p.id == post.id);
      if (existingIndex >= 0) {
        posts[existingIndex] = post;
      } else {
        posts.insert(0, post);
      }

      return await _saveScheduledPosts(posts);
    } catch (e) {
      return false;
    }
  }

  /// Load all scheduled posts
  static Future<List<ScheduledPost>> loadAllScheduledPosts() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_scheduledPostsKey);
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => ScheduledPost.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Load scheduled posts by status
  static Future<List<ScheduledPost>> loadPostsByStatus(
    ScheduleStatus status,
  ) async {
    final posts = await loadAllScheduledPosts();
    return posts.where((p) => p.status == status).toList();
  }

  /// Load scheduled posts for a specific date
  static Future<List<ScheduledPost>> loadPostsForDate(DateTime date) async {
    final posts = await loadAllScheduledPosts();
    return posts
        .where(
          (p) =>
              p.scheduledAt.year == date.year &&
              p.scheduledAt.month == date.month &&
              p.scheduledAt.day == date.day,
        )
        .toList();
  }

  /// Update post status
  static Future<bool> updatePostStatus(
    String postId,
    ScheduleStatus status,
  ) async {
    try {
      final posts = await loadAllScheduledPosts();
      final index = posts.indexWhere((p) => p.id == postId);
      if (index >= 0) {
        posts[index] = posts[index].copyWith(status: status);
        return await _saveScheduledPosts(posts);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Delete a scheduled post
  static Future<bool> deleteScheduledPost(String postId) async {
    try {
      final posts = await loadAllScheduledPosts();
      posts.removeWhere((p) => p.id == postId);
      return await _saveScheduledPosts(posts);
    } catch (e) {
      return false;
    }
  }

  /// Save scheduled posts list
  static Future<bool> _saveScheduledPosts(List<ScheduledPost> posts) async {
    try {
      final prefs = await _preferences;
      final jsonList = posts.map((p) => p.toJson()).toList();
      return await prefs.setString(_scheduledPostsKey, jsonEncode(jsonList));
    } catch (e) {
      return false;
    }
  }

  // ==================== QUEUE ITEMS ====================

  /// Save a queue item
  static Future<bool> saveQueueItem(QueueItem item) async {
    try {
      final items = await loadAllQueueItems();

      final existingIndex = items.indexWhere((i) => i.id == item.id);
      if (existingIndex >= 0) {
        items[existingIndex] = item;
      } else {
        items.add(item);
      }

      return await _saveQueueItems(items);
    } catch (e) {
      return false;
    }
  }

  /// Load all queue items (sorted by orderIndex)
  static Future<List<QueueItem>> loadAllQueueItems() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_queueItemsKey);
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final items = jsonList
          .map((json) => QueueItem.fromJson(json as Map<String, dynamic>))
          .toList();

      items.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return items;
    } catch (e) {
      return [];
    }
  }

  /// Reorder queue items
  static Future<bool> reorderQueueItems(List<QueueItem> items) async {
    try {
      // Update order indices
      final reorderedItems = <QueueItem>[];
      for (int i = 0; i < items.length; i++) {
        reorderedItems.add(items[i].copyWith(orderIndex: i));
      }
      return await _saveQueueItems(reorderedItems);
    } catch (e) {
      return false;
    }
  }

  /// Delete a queue item
  static Future<bool> deleteQueueItem(String itemId) async {
    try {
      final items = await loadAllQueueItems();
      items.removeWhere((i) => i.id == itemId);
      // Reorder remaining items
      final reorderedItems = <QueueItem>[];
      for (int i = 0; i < items.length; i++) {
        reorderedItems.add(items[i].copyWith(orderIndex: i));
      }
      return await _saveQueueItems(reorderedItems);
    } catch (e) {
      return false;
    }
  }

  /// Save queue items list
  static Future<bool> _saveQueueItems(List<QueueItem> items) async {
    try {
      final prefs = await _preferences;
      final jsonList = items.map((i) => i.toJson()).toList();
      return await prefs.setString(_queueItemsKey, jsonEncode(jsonList));
    } catch (e) {
      return false;
    }
  }

  // ==================== QUEUE STATE ====================

  /// Check if queue is paused
  static Future<bool> isQueuePaused() async {
    try {
      final prefs = await _preferences;
      return prefs.getBool(_queuePausedKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Set queue paused state
  static Future<bool> setQueuePaused(bool paused) async {
    try {
      final prefs = await _preferences;
      return await prefs.setBool(_queuePausedKey, paused);
    } catch (e) {
      return false;
    }
  }

  // ==================== MOCK PUBLISHING ====================

  /// Simulate publishing (changes status from scheduled to published)
  /// This is a mock implementation for MVP
  static Future<void> simulatePublishing() async {
    try {
      final posts = await loadAllScheduledPosts();
      final now = DateTime.now();

      for (final post in posts) {
        if (post.status == ScheduleStatus.scheduled &&
            post.scheduledAt.isBefore(now)) {
          // Randomly decide success or failure (90% success rate)
          final success = DateTime.now().millisecond % 10 != 0;
          await updatePostStatus(
            post.id,
            success ? ScheduleStatus.published : ScheduleStatus.failed,
          );
        }
      }
    } catch (e) {
      // Silently fail for mock
    }
  }
}

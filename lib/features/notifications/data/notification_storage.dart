import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_model.dart';

class NotificationStorage {
  static const String _key = 'user_notifications';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Seed some initial data if empty
    if (_prefs?.getString(_key) == null) {
      await _seedInitialData();
    }
  }

  static Future<void> _seedInitialData() async {
    final initial = [
      NotificationModel(
        id: '1',
        title: 'Welcome to LonePengu!',
        description:
            'Start creating your first content with AI Content Studio.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.success,
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'Scheduler Tip',
        description:
            'Scheduling posts at peak times can increase engagement by 40%.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: NotificationType.info,
        isRead: true,
      ),
      NotificationModel(
        id: '3',
        title: 'Draft Saved',
        description: 'Your "Summer Campaign" draft was saved successfully.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.info,
        isRead: true,
      ),
    ];
    await saveAll(initial);
  }

  static Future<List<NotificationModel>> loadAll() async {
    final data = _prefs?.getString(_key);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((j) => NotificationModel.fromJson(j)).toList();
  }

  static Future<void> saveAll(List<NotificationModel> notifications) async {
    final data = jsonEncode(notifications.map((n) => n.toJson()).toList());
    await _prefs?.setString(_key, data);
  }

  static Future<void> markAsRead(String id) async {
    final all = await loadAll();
    final updated = all.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    await saveAll(updated);
  }

  static Future<void> deleteNotification(String id) async {
    final all = await loadAll();
    all.removeWhere((n) => n.id == id);
    await saveAll(all);
  }
}

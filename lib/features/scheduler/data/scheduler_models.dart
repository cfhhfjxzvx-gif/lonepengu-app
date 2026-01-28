import 'dart:convert';
import '../../content_studio/data/content_models.dart';

/// Status for scheduled posts
enum ScheduleStatus { scheduled, published, failed }

/// Extension for ScheduleStatus display
extension ScheduleStatusX on ScheduleStatus {
  String get displayName {
    switch (this) {
      case ScheduleStatus.scheduled:
        return 'Scheduled';
      case ScheduleStatus.published:
        return 'Published';
      case ScheduleStatus.failed:
        return 'Failed';
    }
  }

  String get icon {
    switch (this) {
      case ScheduleStatus.scheduled:
        return '🕐';
      case ScheduleStatus.published:
        return '✅';
      case ScheduleStatus.failed:
        return '❌';
    }
  }
}

/// Arguments for scheduling content from various entry points
class ScheduleArgs {
  final String? contentId;
  final ContentMode? contentType;
  final List<SocialPlatform> platforms;
  final DateTime? suggestedTime;
  final String? caption;
  final String? previewText;

  const ScheduleArgs({
    this.contentId,
    this.contentType,
    this.platforms = const [],
    this.suggestedTime,
    this.caption,
    this.previewText,
  });
}

/// Scheduled post model
class ScheduledPost {
  final String id;
  final String? contentId;
  final ContentMode contentType;
  final List<SocialPlatform> platforms;
  final DateTime scheduledAt;
  final ScheduleStatus status;
  final DateTime createdAt;
  final String? caption;
  final String? previewText;

  const ScheduledPost({
    required this.id,
    this.contentId,
    required this.contentType,
    required this.platforms,
    required this.scheduledAt,
    this.status = ScheduleStatus.scheduled,
    required this.createdAt,
    this.caption,
    this.previewText,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'contentId': contentId,
    'contentType': contentType.index,
    'platforms': platforms.map((p) => p.index).toList(),
    'scheduledAt': scheduledAt.toIso8601String(),
    'status': status.index,
    'createdAt': createdAt.toIso8601String(),
    'caption': caption,
    'previewText': previewText,
  };

  factory ScheduledPost.fromJson(Map<String, dynamic> json) {
    return ScheduledPost(
      id: json['id'] as String? ?? '',
      contentId: json['contentId'] as String?,
      contentType: ContentMode.values[json['contentType'] as int? ?? 0],
      platforms:
          (json['platforms'] as List?)
              ?.map((i) => SocialPlatform.values[i as int])
              .toList() ??
          [],
      scheduledAt:
          DateTime.tryParse(json['scheduledAt'] as String? ?? '') ??
          DateTime.now(),
      status: ScheduleStatus.values[json['status'] as int? ?? 0],
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      caption: json['caption'] as String?,
      previewText: json['previewText'] as String?,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ScheduledPost.fromJsonString(String jsonString) {
    return ScheduledPost.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  ScheduledPost copyWith({
    String? id,
    String? contentId,
    ContentMode? contentType,
    List<SocialPlatform>? platforms,
    DateTime? scheduledAt,
    ScheduleStatus? status,
    DateTime? createdAt,
    String? caption,
    String? previewText,
  }) {
    return ScheduledPost(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      platforms: platforms ?? this.platforms,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      caption: caption ?? this.caption,
      previewText: previewText ?? this.previewText,
    );
  }

  /// Get display text for the post
  String get displayText {
    if (previewText != null && previewText!.isNotEmpty) {
      return previewText!.length > 60
          ? '${previewText!.substring(0, 60)}...'
          : previewText!;
    }
    if (caption != null && caption!.isNotEmpty) {
      return caption!.length > 60
          ? '${caption!.substring(0, 60)}...'
          : caption!;
    }
    return '${contentType.displayName} Post';
  }
}

/// Queue item for auto-publish queue
class QueueItem {
  final String id;
  final String? contentId;
  final ContentMode contentType;
  final List<SocialPlatform> platforms;
  final int orderIndex;
  final String? caption;
  final String? previewText;
  final DateTime createdAt;

  const QueueItem({
    required this.id,
    this.contentId,
    required this.contentType,
    required this.platforms,
    required this.orderIndex,
    this.caption,
    this.previewText,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'contentId': contentId,
    'contentType': contentType.index,
    'platforms': platforms.map((p) => p.index).toList(),
    'orderIndex': orderIndex,
    'caption': caption,
    'previewText': previewText,
    'createdAt': createdAt.toIso8601String(),
  };

  factory QueueItem.fromJson(Map<String, dynamic> json) {
    return QueueItem(
      id: json['id'] as String? ?? '',
      contentId: json['contentId'] as String?,
      contentType: ContentMode.values[json['contentType'] as int? ?? 0],
      platforms:
          (json['platforms'] as List?)
              ?.map((i) => SocialPlatform.values[i as int])
              .toList() ??
          [],
      orderIndex: json['orderIndex'] as int? ?? 0,
      caption: json['caption'] as String?,
      previewText: json['previewText'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  QueueItem copyWith({
    String? id,
    String? contentId,
    ContentMode? contentType,
    List<SocialPlatform>? platforms,
    int? orderIndex,
    String? caption,
    String? previewText,
    DateTime? createdAt,
  }) {
    return QueueItem(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      platforms: platforms ?? this.platforms,
      orderIndex: orderIndex ?? this.orderIndex,
      caption: caption ?? this.caption,
      previewText: previewText ?? this.previewText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get display text for the queue item
  String get displayText {
    if (previewText != null && previewText!.isNotEmpty) {
      return previewText!.length > 60
          ? '${previewText!.substring(0, 60)}...'
          : previewText!;
    }
    if (caption != null && caption!.isNotEmpty) {
      return caption!.length > 60
          ? '${caption!.substring(0, 60)}...'
          : caption!;
    }
    return '${contentType.displayName} Post';
  }
}

/// Optimal time suggestion helper (mock)
class OptimalTimeSuggestion {
  /// Get suggested optimal posting times (mock implementation)
  static List<DateTime> getSuggestedTimes() {
    final now = DateTime.now();
    return [
      // Today + 2 hours (if still in business hours)
      now.add(const Duration(hours: 2)),
      // Tomorrow 10:00 AM
      DateTime(now.year, now.month, now.day + 1, 10, 0),
      // Tomorrow 2:00 PM
      DateTime(now.year, now.month, now.day + 1, 14, 0),
      // Tomorrow 6:00 PM
      DateTime(now.year, now.month, now.day + 1, 18, 0),
    ];
  }

  /// Get display string for suggested time
  static String getDisplayString(DateTime time) {
    final now = DateTime.now();
    final isToday =
        time.day == now.day && time.month == now.month && time.year == now.year;
    final isTomorrow =
        time.day == now.day + 1 &&
        time.month == now.month &&
        time.year == now.year;

    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    final timeStr = '$displayHour:$minute $period';

    if (isToday) {
      return 'Today $timeStr';
    } else if (isTomorrow) {
      return 'Tomorrow $timeStr';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[time.month - 1]} ${time.day} $timeStr';
    }
  }
}

import '../../content_studio/data/content_models.dart';

/// Analytics overview metrics
class AnalyticsOverview {
  final int totalPosts;
  final int totalEngagement;
  final double avgEngagementRate;
  final double growthPercentage;

  const AnalyticsOverview({
    this.totalPosts = 0,
    this.totalEngagement = 0,
    this.avgEngagementRate = 0.0,
    this.growthPercentage = 0.0,
  });

  /// Format engagement rate as percentage string
  String get formattedEngagementRate =>
      '${avgEngagementRate.toStringAsFixed(1)}%';

  /// Format growth percentage with sign
  String get formattedGrowthPercentage {
    final sign = growthPercentage >= 0 ? '+' : '';
    return '$sign${growthPercentage.toStringAsFixed(1)}%';
  }

  /// Check if growth is positive
  bool get isGrowthPositive => growthPercentage >= 0;

  /// Format large numbers with K/M suffix
  String get formattedEngagement {
    if (totalEngagement >= 1000000) {
      return '${(totalEngagement / 1000000).toStringAsFixed(1)}M';
    } else if (totalEngagement >= 1000) {
      return '${(totalEngagement / 1000).toStringAsFixed(1)}K';
    }
    return totalEngagement.toString();
  }
}

/// Single data point for engagement trend chart
class EngagementPoint {
  final DateTime date;
  final int value;

  const EngagementPoint({required this.date, required this.value});

  /// Format date for chart label
  String get shortDateLabel {
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
    return '${months[date.month - 1]} ${date.day}';
  }

  String get weekdayLabel {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }
}

/// Analytics data for a specific platform
class PlatformAnalytics {
  final SocialPlatform platform;
  final int postsCount;
  final int engagement;
  final double engagementRate;

  const PlatformAnalytics({
    required this.platform,
    this.postsCount = 0,
    this.engagement = 0,
    this.engagementRate = 0.0,
  });

  /// Format engagement for display
  String get formattedEngagement {
    if (engagement >= 1000000) {
      return '${(engagement / 1000000).toStringAsFixed(1)}M';
    } else if (engagement >= 1000) {
      return '${(engagement / 1000).toStringAsFixed(1)}K';
    }
    return engagement.toString();
  }

  /// Get platform color
  int get platformColorValue {
    switch (platform) {
      case SocialPlatform.instagram:
        return 0xFFE4405F;
      case SocialPlatform.facebook:
        return 0xFF1877F2;
      case SocialPlatform.linkedin:
        return 0xFF0A66C2;
      case SocialPlatform.x:
        return 0xFF1A1A2E;
    }
  }
}

/// Top performing post data
class TopPost {
  final String id;
  final SocialPlatform platform;
  final ContentMode contentType;
  final int engagement;
  final int likes;
  final int comments;
  final int shares;
  final DateTime date;
  final String? caption;

  const TopPost({
    required this.id,
    required this.platform,
    required this.contentType,
    this.engagement = 0,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    required this.date,
    this.caption,
  });

  /// Get preview text
  String get previewText {
    if (caption != null && caption!.isNotEmpty) {
      return caption!.length > 50
          ? '${caption!.substring(0, 50)}...'
          : caption!;
    }
    return '${contentType.displayName} Post';
  }

  /// Format date for display
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final postDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(postDate).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';

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
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Format engagement for display
  String get formattedEngagement {
    if (engagement >= 1000000) {
      return '${(engagement / 1000000).toStringAsFixed(1)}M';
    } else if (engagement >= 1000) {
      return '${(engagement / 1000).toStringAsFixed(1)}K';
    }
    return engagement.toString();
  }
}

/// Time range options for analytics
enum AnalyticsTimeRange { week7, week14, month30 }

extension AnalyticsTimeRangeX on AnalyticsTimeRange {
  String get displayName {
    switch (this) {
      case AnalyticsTimeRange.week7:
        return '7 Days';
      case AnalyticsTimeRange.week14:
        return '14 Days';
      case AnalyticsTimeRange.month30:
        return '30 Days';
    }
  }

  int get days {
    switch (this) {
      case AnalyticsTimeRange.week7:
        return 7;
      case AnalyticsTimeRange.week14:
        return 14;
      case AnalyticsTimeRange.month30:
        return 30;
    }
  }
}

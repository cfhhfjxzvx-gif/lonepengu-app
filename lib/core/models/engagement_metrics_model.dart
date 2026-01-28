/// Engagement Metrics Model - BRD Section 6: Database Entities
///
/// Represents engagement metrics and analytics from the database schema

import 'dart:convert';

/// Metric time period
enum MetricPeriod { day, week, month, quarter, year, allTime }

extension MetricPeriodX on MetricPeriod {
  String get displayName {
    switch (this) {
      case MetricPeriod.day:
        return 'Today';
      case MetricPeriod.week:
        return 'This Week';
      case MetricPeriod.month:
        return 'This Month';
      case MetricPeriod.quarter:
        return 'This Quarter';
      case MetricPeriod.year:
        return 'This Year';
      case MetricPeriod.allTime:
        return 'All Time';
    }
  }

  int get daysCount {
    switch (this) {
      case MetricPeriod.day:
        return 1;
      case MetricPeriod.week:
        return 7;
      case MetricPeriod.month:
        return 30;
      case MetricPeriod.quarter:
        return 90;
      case MetricPeriod.year:
        return 365;
      case MetricPeriod.allTime:
        return 3650; // ~10 years
    }
  }
}

/// Post-level metrics
class PostMetrics {
  final String postId;
  final String? platformPostId;
  final int impressions;
  final int reach;
  final int likes;
  final int comments;
  final int shares;
  final int saves;
  final int clicks;
  final double engagementRate;
  final DateTime recordedAt;

  const PostMetrics({
    required this.postId,
    this.platformPostId,
    this.impressions = 0,
    this.reach = 0,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
    this.clicks = 0,
    this.engagementRate = 0.0,
    required this.recordedAt,
  });

  /// Total engagement (likes + comments + shares + saves)
  int get totalEngagement => likes + comments + shares + saves;

  factory PostMetrics.fromJson(Map<String, dynamic> json) {
    return PostMetrics(
      postId: json['postId'] ?? '',
      platformPostId: json['platformPostId'],
      impressions: json['impressions'] ?? 0,
      reach: json['reach'] ?? 0,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      saves: json['saves'] ?? 0,
      clicks: json['clicks'] ?? 0,
      engagementRate: (json['engagementRate'] ?? 0.0).toDouble(),
      recordedAt: DateTime.tryParse(json['recordedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'postId': postId,
    'platformPostId': platformPostId,
    'impressions': impressions,
    'reach': reach,
    'likes': likes,
    'comments': comments,
    'shares': shares,
    'saves': saves,
    'clicks': clicks,
    'engagementRate': engagementRate,
    'recordedAt': recordedAt.toIso8601String(),
  };
}

/// Platform-level aggregated metrics
class PlatformMetrics {
  final String platform;
  final int totalPosts;
  final int totalImpressions;
  final int totalReach;
  final int totalEngagement;
  final double avgEngagementRate;
  final int followerCount;
  final int followerGrowth;
  final MetricPeriod period;
  final DateTime startDate;
  final DateTime endDate;

  const PlatformMetrics({
    required this.platform,
    this.totalPosts = 0,
    this.totalImpressions = 0,
    this.totalReach = 0,
    this.totalEngagement = 0,
    this.avgEngagementRate = 0.0,
    this.followerCount = 0,
    this.followerGrowth = 0,
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  /// Growth percentage
  double get growthPercentage {
    if (followerCount == 0) return 0;
    return (followerGrowth / followerCount) * 100;
  }

  factory PlatformMetrics.fromJson(Map<String, dynamic> json) {
    return PlatformMetrics(
      platform: json['platform'] ?? '',
      totalPosts: json['totalPosts'] ?? 0,
      totalImpressions: json['totalImpressions'] ?? 0,
      totalReach: json['totalReach'] ?? 0,
      totalEngagement: json['totalEngagement'] ?? 0,
      avgEngagementRate: (json['avgEngagementRate'] ?? 0.0).toDouble(),
      followerCount: json['followerCount'] ?? 0,
      followerGrowth: json['followerGrowth'] ?? 0,
      period: MetricPeriod.values.firstWhere(
        (p) => p.name == json['period'],
        orElse: () => MetricPeriod.month,
      ),
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'totalPosts': totalPosts,
    'totalImpressions': totalImpressions,
    'totalReach': totalReach,
    'totalEngagement': totalEngagement,
    'avgEngagementRate': avgEngagementRate,
    'followerCount': followerCount,
    'followerGrowth': followerGrowth,
    'period': period.name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
  };
}

/// Overall engagement metrics model
class EngagementMetricsModel {
  final String id;
  final String userId;
  final MetricPeriod period;
  final int totalPosts;
  final int totalImpressions;
  final int totalReach;
  final int totalEngagement;
  final double avgEngagementRate;
  final double growthPercentage;
  final List<PlatformMetrics> platformBreakdown;
  final List<PostMetrics> topPosts;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime calculatedAt;

  const EngagementMetricsModel({
    required this.id,
    required this.userId,
    required this.period,
    this.totalPosts = 0,
    this.totalImpressions = 0,
    this.totalReach = 0,
    this.totalEngagement = 0,
    this.avgEngagementRate = 0.0,
    this.growthPercentage = 0.0,
    this.platformBreakdown = const [],
    this.topPosts = const [],
    required this.startDate,
    required this.endDate,
    required this.calculatedAt,
  });

  factory EngagementMetricsModel.fromJson(Map<String, dynamic> json) {
    return EngagementMetricsModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      period: MetricPeriod.values.firstWhere(
        (p) => p.name == json['period'],
        orElse: () => MetricPeriod.month,
      ),
      totalPosts: json['totalPosts'] ?? 0,
      totalImpressions: json['totalImpressions'] ?? 0,
      totalReach: json['totalReach'] ?? 0,
      totalEngagement: json['totalEngagement'] ?? 0,
      avgEngagementRate: (json['avgEngagementRate'] ?? 0.0).toDouble(),
      growthPercentage: (json['growthPercentage'] ?? 0.0).toDouble(),
      platformBreakdown:
          (json['platformBreakdown'] as List<dynamic>?)
              ?.map((p) => PlatformMetrics.fromJson(p))
              .toList() ??
          [],
      topPosts:
          (json['topPosts'] as List<dynamic>?)
              ?.map((p) => PostMetrics.fromJson(p))
              .toList() ??
          [],
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      calculatedAt:
          DateTime.tryParse(json['calculatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'period': period.name,
    'totalPosts': totalPosts,
    'totalImpressions': totalImpressions,
    'totalReach': totalReach,
    'totalEngagement': totalEngagement,
    'avgEngagementRate': avgEngagementRate,
    'growthPercentage': growthPercentage,
    'platformBreakdown': platformBreakdown.map((p) => p.toJson()).toList(),
    'topPosts': topPosts.map((p) => p.toJson()).toList(),
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'calculatedAt': calculatedAt.toIso8601String(),
  };

  /// Serialize to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Deserialize from JSON string
  factory EngagementMetricsModel.fromJsonString(String json) =>
      EngagementMetricsModel.fromJson(jsonDecode(json));
}

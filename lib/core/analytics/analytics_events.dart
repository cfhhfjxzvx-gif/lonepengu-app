/// Analytics Events - BRD Section 7: Success Metrics (KPIs)
///
/// Defines all trackable analytics events for:
/// - Acquisition metrics
/// - Engagement metrics
/// - Retention metrics
/// - Revenue metrics

/// Analytics event types
enum AnalyticsEventType {
  // Acquisition
  appOpened,
  signUpStarted,
  signUpCompleted,
  loginCompleted,
  onboardingStarted,
  onboardingCompleted,
  referralClicked,

  // Engagement
  sessionStarted,
  sessionEnded,
  screenViewed,
  postCreated,
  postScheduled,
  postPublished,
  aiTextGenerated,
  aiImageGenerated,
  aiVideoGenerated,
  templateUsed,
  brandKitCreated,
  socialAccountConnected,
  socialAccountDisconnected,
  contentExported,
  draftSaved,
  draftDeleted,

  // Retention
  dailyActive,
  weeklyActive,
  monthlyActive,
  featureUsed,
  notificationClicked,
  appBackgrounded,
  appResumed,

  // Revenue
  subscriptionViewed,
  subscriptionStarted,
  subscriptionCancelled,
  purchaseCompleted,
  creditsPurchased,
  creditsUsed,
}

extension AnalyticsEventTypeX on AnalyticsEventType {
  String get name {
    return toString().split('.').last;
  }

  String get category {
    switch (this) {
      case AnalyticsEventType.appOpened:
      case AnalyticsEventType.signUpStarted:
      case AnalyticsEventType.signUpCompleted:
      case AnalyticsEventType.loginCompleted:
      case AnalyticsEventType.onboardingStarted:
      case AnalyticsEventType.onboardingCompleted:
      case AnalyticsEventType.referralClicked:
        return 'acquisition';

      case AnalyticsEventType.sessionStarted:
      case AnalyticsEventType.sessionEnded:
      case AnalyticsEventType.screenViewed:
      case AnalyticsEventType.postCreated:
      case AnalyticsEventType.postScheduled:
      case AnalyticsEventType.postPublished:
      case AnalyticsEventType.aiTextGenerated:
      case AnalyticsEventType.aiImageGenerated:
      case AnalyticsEventType.aiVideoGenerated:
      case AnalyticsEventType.templateUsed:
      case AnalyticsEventType.brandKitCreated:
      case AnalyticsEventType.socialAccountConnected:
      case AnalyticsEventType.socialAccountDisconnected:
      case AnalyticsEventType.contentExported:
      case AnalyticsEventType.draftSaved:
      case AnalyticsEventType.draftDeleted:
        return 'engagement';

      case AnalyticsEventType.dailyActive:
      case AnalyticsEventType.weeklyActive:
      case AnalyticsEventType.monthlyActive:
      case AnalyticsEventType.featureUsed:
      case AnalyticsEventType.notificationClicked:
      case AnalyticsEventType.appBackgrounded:
      case AnalyticsEventType.appResumed:
        return 'retention';

      case AnalyticsEventType.subscriptionViewed:
      case AnalyticsEventType.subscriptionStarted:
      case AnalyticsEventType.subscriptionCancelled:
      case AnalyticsEventType.purchaseCompleted:
      case AnalyticsEventType.creditsPurchased:
      case AnalyticsEventType.creditsUsed:
        return 'revenue';
    }
  }
}

/// Analytics event model
class AnalyticsEvent {
  final AnalyticsEventType type;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;
  final Map<String, dynamic>? properties;

  const AnalyticsEvent({
    required this.type,
    required this.timestamp,
    this.userId,
    this.sessionId,
    this.properties,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'category': type.category,
    'timestamp': timestamp.toIso8601String(),
    'userId': userId,
    'sessionId': sessionId,
    'properties': properties,
  };

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      type: AnalyticsEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AnalyticsEventType.screenViewed,
      ),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      userId: json['userId'],
      sessionId: json['sessionId'],
      properties: json['properties'],
    );
  }

  /// Create a screen view event
  factory AnalyticsEvent.screenView(String screenName, {String? userId}) {
    return AnalyticsEvent(
      type: AnalyticsEventType.screenViewed,
      timestamp: DateTime.now(),
      userId: userId,
      properties: {'screen_name': screenName},
    );
  }

  /// Create a post created event
  factory AnalyticsEvent.postCreated({
    required String contentType,
    required List<String> platforms,
    String? userId,
  }) {
    return AnalyticsEvent(
      type: AnalyticsEventType.postCreated,
      timestamp: DateTime.now(),
      userId: userId,
      properties: {
        'content_type': contentType,
        'platforms': platforms,
        'platform_count': platforms.length,
      },
    );
  }

  /// Create an AI generation event
  factory AnalyticsEvent.aiGeneration({
    required String assetType,
    required int creditsUsed,
    String? style,
    String? userId,
  }) {
    AnalyticsEventType eventType;
    switch (assetType) {
      case 'image':
        eventType = AnalyticsEventType.aiImageGenerated;
        break;
      case 'video':
        eventType = AnalyticsEventType.aiVideoGenerated;
        break;
      default:
        eventType = AnalyticsEventType.aiTextGenerated;
    }

    return AnalyticsEvent(
      type: eventType,
      timestamp: DateTime.now(),
      userId: userId,
      properties: {
        'asset_type': assetType,
        'credits_used': creditsUsed,
        'style': style,
      },
    );
  }
}

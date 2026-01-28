/// Content Item Model - BRD Section 6: Database Entities
///
/// Represents content items (posts, captions, media) from the database schema

import 'dart:convert';

/// Content types
enum ContentType { caption, image, video, carousel, story, reel, article }

extension ContentTypeX on ContentType {
  String get displayName {
    switch (this) {
      case ContentType.caption:
        return 'Caption';
      case ContentType.image:
        return 'Image Post';
      case ContentType.video:
        return 'Video';
      case ContentType.carousel:
        return 'Carousel';
      case ContentType.story:
        return 'Story';
      case ContentType.reel:
        return 'Reel';
      case ContentType.article:
        return 'Article';
    }
  }

  String get icon {
    switch (this) {
      case ContentType.caption:
        return '✍️';
      case ContentType.image:
        return '🖼️';
      case ContentType.video:
        return '🎬';
      case ContentType.carousel:
        return '📑';
      case ContentType.story:
        return '📱';
      case ContentType.reel:
        return '🎞️';
      case ContentType.article:
        return '📝';
    }
  }
}

/// Content status
enum ContentStatus { draft, ready, scheduled, published, failed, archived }

extension ContentStatusX on ContentStatus {
  String get displayName {
    switch (this) {
      case ContentStatus.draft:
        return 'Draft';
      case ContentStatus.ready:
        return 'Ready';
      case ContentStatus.scheduled:
        return 'Scheduled';
      case ContentStatus.published:
        return 'Published';
      case ContentStatus.failed:
        return 'Failed';
      case ContentStatus.archived:
        return 'Archived';
    }
  }

  bool get isEditable =>
      this == ContentStatus.draft || this == ContentStatus.ready;
  bool get canSchedule => this == ContentStatus.ready;
  bool get canPublish =>
      this == ContentStatus.ready || this == ContentStatus.scheduled;
}

/// Media item within content
class MediaItem {
  final String id;
  final String url;
  final String? thumbnailUrl;
  final String mimeType;
  final int? width;
  final int? height;
  final int? durationSeconds;
  final int? sizeBytes;
  final String? altText;

  const MediaItem({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    required this.mimeType,
    this.width,
    this.height,
    this.durationSeconds,
    this.sizeBytes,
    this.altText,
  });

  bool get isImage => mimeType.startsWith('image/');
  bool get isVideo => mimeType.startsWith('video/');

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      mimeType: json['mimeType'] ?? 'image/jpeg',
      width: json['width'],
      height: json['height'],
      durationSeconds: json['durationSeconds'],
      sizeBytes: json['sizeBytes'],
      altText: json['altText'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'thumbnailUrl': thumbnailUrl,
    'mimeType': mimeType,
    'width': width,
    'height': height,
    'durationSeconds': durationSeconds,
    'sizeBytes': sizeBytes,
    'altText': altText,
  };
}

/// Content item model
class ContentItemModel {
  final String id;
  final String userId;
  final String? brandKitId;
  final ContentType type;
  final ContentStatus status;
  final String? caption;
  final List<String> hashtags;
  final List<MediaItem> media;
  final List<String> targetPlatforms;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final Map<String, dynamic>? platformMetadata;
  final String? templateId;
  final bool isAiGenerated;

  const ContentItemModel({
    required this.id,
    required this.userId,
    this.brandKitId,
    required this.type,
    this.status = ContentStatus.draft,
    this.caption,
    this.hashtags = const [],
    this.media = const [],
    this.targetPlatforms = const [],
    required this.createdAt,
    required this.updatedAt,
    this.scheduledAt,
    this.publishedAt,
    this.platformMetadata,
    this.templateId,
    this.isAiGenerated = false,
  });

  factory ContentItemModel.fromJson(Map<String, dynamic> json) {
    return ContentItemModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      brandKitId: json['brandKitId'],
      type: ContentType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ContentType.caption,
      ),
      status: ContentStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ContentStatus.draft,
      ),
      caption: json['caption'],
      hashtags: List<String>.from(json['hashtags'] ?? []),
      media:
          (json['media'] as List<dynamic>?)
              ?.map((m) => MediaItem.fromJson(m))
              .toList() ??
          [],
      targetPlatforms: List<String>.from(json['targetPlatforms'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'])
          : null,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'])
          : null,
      platformMetadata: json['platformMetadata'],
      templateId: json['templateId'],
      isAiGenerated: json['isAiGenerated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'brandKitId': brandKitId,
    'type': type.name,
    'status': status.name,
    'caption': caption,
    'hashtags': hashtags,
    'media': media.map((m) => m.toJson()).toList(),
    'targetPlatforms': targetPlatforms,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'scheduledAt': scheduledAt?.toIso8601String(),
    'publishedAt': publishedAt?.toIso8601String(),
    'platformMetadata': platformMetadata,
    'templateId': templateId,
    'isAiGenerated': isAiGenerated,
  };

  ContentItemModel copyWith({
    String? id,
    String? userId,
    String? brandKitId,
    ContentType? type,
    ContentStatus? status,
    String? caption,
    List<String>? hashtags,
    List<MediaItem>? media,
    List<String>? targetPlatforms,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? scheduledAt,
    DateTime? publishedAt,
    Map<String, dynamic>? platformMetadata,
    String? templateId,
    bool? isAiGenerated,
  }) {
    return ContentItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      brandKitId: brandKitId ?? this.brandKitId,
      type: type ?? this.type,
      status: status ?? this.status,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      media: media ?? this.media,
      targetPlatforms: targetPlatforms ?? this.targetPlatforms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      publishedAt: publishedAt ?? this.publishedAt,
      platformMetadata: platformMetadata ?? this.platformMetadata,
      templateId: templateId ?? this.templateId,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
    );
  }

  /// Get formatted caption with hashtags
  String get fullCaption {
    if (hashtags.isEmpty) return caption ?? '';
    return '${caption ?? ''}\n\n${hashtags.join(' ')}';
  }

  /// Check if content has media
  bool get hasMedia => media.isNotEmpty;

  /// Get first media item
  MediaItem? get primaryMedia => media.isNotEmpty ? media.first : null;

  /// Serialize list to JSON string
  static String listToJson(List<ContentItemModel> items) {
    return jsonEncode(items.map((i) => i.toJson()).toList());
  }

  /// Deserialize list from JSON string
  static List<ContentItemModel> listFromJson(String jsonString) {
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((json) => ContentItemModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}

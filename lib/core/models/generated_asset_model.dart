/// Generated Asset Model - BRD Section 6: Database Entities
///
/// Represents AI-generated assets from the database schema

import 'dart:convert';

/// Asset type
enum GeneratedAssetType { image, video, caption, hashtags, carousel, animation }

extension GeneratedAssetTypeX on GeneratedAssetType {
  String get displayName {
    switch (this) {
      case GeneratedAssetType.image:
        return 'Image';
      case GeneratedAssetType.video:
        return 'Video';
      case GeneratedAssetType.caption:
        return 'Caption';
      case GeneratedAssetType.hashtags:
        return 'Hashtags';
      case GeneratedAssetType.carousel:
        return 'Carousel';
      case GeneratedAssetType.animation:
        return 'Animation';
    }
  }

  String get icon {
    switch (this) {
      case GeneratedAssetType.image:
        return '🖼️';
      case GeneratedAssetType.video:
        return '🎬';
      case GeneratedAssetType.caption:
        return '✍️';
      case GeneratedAssetType.hashtags:
        return '#️⃣';
      case GeneratedAssetType.carousel:
        return '📑';
      case GeneratedAssetType.animation:
        return '🎞️';
    }
  }

  int get baseCredits {
    switch (this) {
      case GeneratedAssetType.image:
        return 10;
      case GeneratedAssetType.video:
        return 50;
      case GeneratedAssetType.caption:
        return 5;
      case GeneratedAssetType.hashtags:
        return 2;
      case GeneratedAssetType.carousel:
        return 30;
      case GeneratedAssetType.animation:
        return 25;
    }
  }
}

/// Generation status
enum GenerationStatus { pending, processing, completed, failed, cancelled }

extension GenerationStatusX on GenerationStatus {
  String get displayName {
    switch (this) {
      case GenerationStatus.pending:
        return 'Pending';
      case GenerationStatus.processing:
        return 'Processing';
      case GenerationStatus.completed:
        return 'Completed';
      case GenerationStatus.failed:
        return 'Failed';
      case GenerationStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isTerminal =>
      this == GenerationStatus.completed ||
      this == GenerationStatus.failed ||
      this == GenerationStatus.cancelled;
}

/// Generated asset model
class GeneratedAssetModel {
  final String id;
  final String userId;
  final GeneratedAssetType type;
  final GenerationStatus status;
  final String prompt;
  final String? negativePrompt;
  final String? style;
  final String? resultUrl;
  final String? thumbnailUrl;
  final String? resultText;
  final List<String>? resultList;
  final int creditsUsed;
  final int? width;
  final int? height;
  final int? durationSeconds;
  final double? progress;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? parameters;
  final Map<String, dynamic>? metadata;

  const GeneratedAssetModel({
    required this.id,
    required this.userId,
    required this.type,
    this.status = GenerationStatus.pending,
    required this.prompt,
    this.negativePrompt,
    this.style,
    this.resultUrl,
    this.thumbnailUrl,
    this.resultText,
    this.resultList,
    this.creditsUsed = 0,
    this.width,
    this.height,
    this.durationSeconds,
    this.progress,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
    this.parameters,
    this.metadata,
  });

  factory GeneratedAssetModel.fromJson(Map<String, dynamic> json) {
    return GeneratedAssetModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: GeneratedAssetType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => GeneratedAssetType.image,
      ),
      status: GenerationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => GenerationStatus.pending,
      ),
      prompt: json['prompt'] ?? '',
      negativePrompt: json['negativePrompt'],
      style: json['style'],
      resultUrl: json['resultUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      resultText: json['resultText'],
      resultList: json['resultList'] != null
          ? List<String>.from(json['resultList'])
          : null,
      creditsUsed: json['creditsUsed'] ?? 0,
      width: json['width'],
      height: json['height'],
      durationSeconds: json['durationSeconds'],
      progress: json['progress']?.toDouble(),
      errorMessage: json['errorMessage'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
      parameters: json['parameters'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type.name,
    'status': status.name,
    'prompt': prompt,
    'negativePrompt': negativePrompt,
    'style': style,
    'resultUrl': resultUrl,
    'thumbnailUrl': thumbnailUrl,
    'resultText': resultText,
    'resultList': resultList,
    'creditsUsed': creditsUsed,
    'width': width,
    'height': height,
    'durationSeconds': durationSeconds,
    'progress': progress,
    'errorMessage': errorMessage,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'parameters': parameters,
    'metadata': metadata,
  };

  GeneratedAssetModel copyWith({
    String? id,
    String? userId,
    GeneratedAssetType? type,
    GenerationStatus? status,
    String? prompt,
    String? negativePrompt,
    String? style,
    String? resultUrl,
    String? thumbnailUrl,
    String? resultText,
    List<String>? resultList,
    int? creditsUsed,
    int? width,
    int? height,
    int? durationSeconds,
    double? progress,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? metadata,
  }) {
    return GeneratedAssetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      prompt: prompt ?? this.prompt,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      style: style ?? this.style,
      resultUrl: resultUrl ?? this.resultUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      resultText: resultText ?? this.resultText,
      resultList: resultList ?? this.resultList,
      creditsUsed: creditsUsed ?? this.creditsUsed,
      width: width ?? this.width,
      height: height ?? this.height,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      parameters: parameters ?? this.parameters,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if asset is media (image/video)
  bool get isMedia =>
      type == GeneratedAssetType.image ||
      type == GeneratedAssetType.video ||
      type == GeneratedAssetType.animation;

  /// Check if asset is text-based
  bool get isText =>
      type == GeneratedAssetType.caption || type == GeneratedAssetType.hashtags;

  /// Serialize list to JSON string
  static String listToJson(List<GeneratedAssetModel> assets) {
    return jsonEncode(assets.map((a) => a.toJson()).toList());
  }

  /// Deserialize list from JSON string
  static List<GeneratedAssetModel> listFromJson(String jsonString) {
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((json) => GeneratedAssetModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}

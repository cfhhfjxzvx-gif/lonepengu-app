/// Template Model - BRD Section 6: Database Entities
///
/// Represents content templates from the database schema

import 'dart:convert';

/// Template categories
enum TemplateCategory {
  promotional,
  engagement,
  educational,
  announcement,
  storytelling,
  seasonal,
  quotation,
  behindTheScenes,
  userGenerated,
  custom,
}

extension TemplateCategoryX on TemplateCategory {
  String get displayName {
    switch (this) {
      case TemplateCategory.promotional:
        return 'Promotional';
      case TemplateCategory.engagement:
        return 'Engagement';
      case TemplateCategory.educational:
        return 'Educational';
      case TemplateCategory.announcement:
        return 'Announcement';
      case TemplateCategory.storytelling:
        return 'Storytelling';
      case TemplateCategory.seasonal:
        return 'Seasonal';
      case TemplateCategory.quotation:
        return 'Quotation';
      case TemplateCategory.behindTheScenes:
        return 'Behind the Scenes';
      case TemplateCategory.userGenerated:
        return 'User Generated';
      case TemplateCategory.custom:
        return 'Custom';
    }
  }

  String get icon {
    switch (this) {
      case TemplateCategory.promotional:
        return '📢';
      case TemplateCategory.engagement:
        return '💬';
      case TemplateCategory.educational:
        return '📚';
      case TemplateCategory.announcement:
        return '📣';
      case TemplateCategory.storytelling:
        return '📖';
      case TemplateCategory.seasonal:
        return '🎉';
      case TemplateCategory.quotation:
        return '💬';
      case TemplateCategory.behindTheScenes:
        return '🎬';
      case TemplateCategory.userGenerated:
        return '👥';
      case TemplateCategory.custom:
        return '✨';
    }
  }
}

/// Template type
enum TemplateType { caption, image, carousel, video, story }

extension TemplateTypeX on TemplateType {
  String get displayName {
    switch (this) {
      case TemplateType.caption:
        return 'Caption Template';
      case TemplateType.image:
        return 'Image Template';
      case TemplateType.carousel:
        return 'Carousel Template';
      case TemplateType.video:
        return 'Video Template';
      case TemplateType.story:
        return 'Story Template';
    }
  }
}

/// Template variable placeholder
class TemplateVariable {
  final String name;
  final String placeholder;
  final String? defaultValue;
  final String? description;
  final bool required;

  const TemplateVariable({
    required this.name,
    required this.placeholder,
    this.defaultValue,
    this.description,
    this.required = true,
  });

  factory TemplateVariable.fromJson(Map<String, dynamic> json) {
    return TemplateVariable(
      name: json['name'] ?? '',
      placeholder: json['placeholder'] ?? '',
      defaultValue: json['defaultValue'],
      description: json['description'],
      required: json['required'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'placeholder': placeholder,
    'defaultValue': defaultValue,
    'description': description,
    'required': required,
  };
}

/// Template model
class TemplateModel {
  final String id;
  final String? userId; // null for system templates
  final String name;
  final String? description;
  final TemplateType type;
  final TemplateCategory category;
  final String content;
  final List<TemplateVariable> variables;
  final List<String> targetPlatforms;
  final String? thumbnailUrl;
  final bool isSystem;
  final bool isPublic;
  final int usageCount;
  final double? rating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const TemplateModel({
    required this.id,
    this.userId,
    required this.name,
    this.description,
    required this.type,
    required this.category,
    required this.content,
    this.variables = const [],
    this.targetPlatforms = const [],
    this.thumbnailUrl,
    this.isSystem = false,
    this.isPublic = false,
    this.usageCount = 0,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] ?? '',
      userId: json['userId'],
      name: json['name'] ?? '',
      description: json['description'],
      type: TemplateType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TemplateType.caption,
      ),
      category: TemplateCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => TemplateCategory.custom,
      ),
      content: json['content'] ?? '',
      variables:
          (json['variables'] as List<dynamic>?)
              ?.map((v) => TemplateVariable.fromJson(v))
              .toList() ??
          [],
      targetPlatforms: List<String>.from(json['targetPlatforms'] ?? []),
      thumbnailUrl: json['thumbnailUrl'],
      isSystem: json['isSystem'] ?? false,
      isPublic: json['isPublic'] ?? false,
      usageCount: json['usageCount'] ?? 0,
      rating: json['rating']?.toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'description': description,
    'type': type.name,
    'category': category.name,
    'content': content,
    'variables': variables.map((v) => v.toJson()).toList(),
    'targetPlatforms': targetPlatforms,
    'thumbnailUrl': thumbnailUrl,
    'isSystem': isSystem,
    'isPublic': isPublic,
    'usageCount': usageCount,
    'rating': rating,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'metadata': metadata,
  };

  TemplateModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    TemplateType? type,
    TemplateCategory? category,
    String? content,
    List<TemplateVariable>? variables,
    List<String>? targetPlatforms,
    String? thumbnailUrl,
    bool? isSystem,
    bool? isPublic,
    int? usageCount,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      content: content ?? this.content,
      variables: variables ?? this.variables,
      targetPlatforms: targetPlatforms ?? this.targetPlatforms,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isSystem: isSystem ?? this.isSystem,
      isPublic: isPublic ?? this.isPublic,
      usageCount: usageCount ?? this.usageCount,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Apply variables to template content
  String applyVariables(Map<String, String> values) {
    var result = content;
    for (final variable in variables) {
      final value = values[variable.name] ?? variable.defaultValue ?? '';
      result = result.replaceAll(variable.placeholder, value);
    }
    return result;
  }

  /// Serialize list to JSON string
  static String listToJson(List<TemplateModel> templates) {
    return jsonEncode(templates.map((t) => t.toJson()).toList());
  }

  /// Deserialize list from JSON string
  static List<TemplateModel> listFromJson(String jsonString) {
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((json) => TemplateModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}

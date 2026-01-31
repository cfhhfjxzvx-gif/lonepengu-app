import 'dart:convert';
import 'dart:typed_data';

/// Content generation mode
enum ContentMode { caption, image, carousel, video }

extension ContentModeX on ContentMode {
  String get displayName {
    switch (this) {
      case ContentMode.caption:
        return 'Caption';
      case ContentMode.image:
        return 'Image';
      case ContentMode.carousel:
        return 'Carousel';
      case ContentMode.video:
        return 'Motion Video';
    }
  }

  String get icon {
    switch (this) {
      case ContentMode.caption:
        return '✏️';
      case ContentMode.image:
        return '🖼️';
      case ContentMode.carousel:
        return '📑';
      case ContentMode.video:
        return '🎬';
    }
  }
}

/// Social platform
enum SocialPlatform { instagram, facebook, linkedin, x }

/// Content goal
enum ContentGoal { awareness, engagement, leads, sales }

/// Tone options
enum ContentTone { professional, friendly, bold, minimal, funny, luxury }

/// Content length
enum ContentLength { short, medium, long }

/// CTA options
enum CtaType { shopNow, learnMore, dmUs, signUp, bookACall }

/// Image style
enum ImageStyle { realistic, minimal, threeD, neon, elegant, productShot }

/// Aspect ratio
enum AppAspectRatio { square, fourByFive, nineBysSixteen, sixteenByNine }

/// Carousel style
enum CarouselStyle { tips, steps, beforeAfter, mythVsFact, promo }

/// Video style
enum VideoStyle { modern, clean, kineticText, productFocus }

/// Video duration
enum VideoDuration { fifteenSec, thirtySec, sixtySec }

/// Extensions for enum display names

extension SocialPlatformX on SocialPlatform {
  String get displayName {
    switch (this) {
      case SocialPlatform.instagram:
        return 'Instagram';
      case SocialPlatform.facebook:
        return 'Facebook';
      case SocialPlatform.linkedin:
        return 'LinkedIn';
      case SocialPlatform.x:
        return 'X';
    }
  }

  String get icon {
    switch (this) {
      case SocialPlatform.instagram:
        return '📸';
      case SocialPlatform.facebook:
        return '📘';
      case SocialPlatform.linkedin:
        return '💼';
      case SocialPlatform.x:
        return '𝕏';
    }
  }
}

extension ContentGoalX on ContentGoal {
  String get displayName {
    switch (this) {
      case ContentGoal.awareness:
        return 'Awareness';
      case ContentGoal.engagement:
        return 'Engagement';
      case ContentGoal.leads:
        return 'Leads';
      case ContentGoal.sales:
        return 'Sales';
    }
  }
}

extension ContentToneX on ContentTone {
  String get displayName {
    switch (this) {
      case ContentTone.professional:
        return 'Professional';
      case ContentTone.friendly:
        return 'Friendly';
      case ContentTone.bold:
        return 'Bold';
      case ContentTone.minimal:
        return 'Minimal';
      case ContentTone.funny:
        return 'Funny';
      case ContentTone.luxury:
        return 'Luxury';
    }
  }
}

extension ContentLengthX on ContentLength {
  String get displayName {
    switch (this) {
      case ContentLength.short:
        return 'Short';
      case ContentLength.medium:
        return 'Medium';
      case ContentLength.long:
        return 'Long';
    }
  }
}

extension CtaTypeX on CtaType {
  String get displayName {
    switch (this) {
      case CtaType.shopNow:
        return 'Shop now';
      case CtaType.learnMore:
        return 'Learn more';
      case CtaType.dmUs:
        return 'DM us';
      case CtaType.signUp:
        return 'Sign up';
      case CtaType.bookACall:
        return 'Book a call';
    }
  }
}

extension ImageStyleX on ImageStyle {
  String get displayName {
    switch (this) {
      case ImageStyle.realistic:
        return 'Realistic';
      case ImageStyle.minimal:
        return 'Minimal';
      case ImageStyle.threeD:
        return '3D';
      case ImageStyle.neon:
        return 'Neon';
      case ImageStyle.elegant:
        return 'Elegant';
      case ImageStyle.productShot:
        return 'Product Shot';
    }
  }
}

extension AppAspectRatioX on AppAspectRatio {
  String get displayName {
    switch (this) {
      case AppAspectRatio.square:
        return '1:1';
      case AppAspectRatio.fourByFive:
        return '4:5';
      case AppAspectRatio.nineBysSixteen:
        return '9:16';
      case AppAspectRatio.sixteenByNine:
        return '16:9';
    }
  }

  double get value {
    switch (this) {
      case AppAspectRatio.square:
        return 1.0;
      case AppAspectRatio.fourByFive:
        return 0.8;
      case AppAspectRatio.nineBysSixteen:
        return 0.5625;
      case AppAspectRatio.sixteenByNine:
        return 1.777;
    }
  }
}

extension CarouselStyleX on CarouselStyle {
  String get displayName {
    switch (this) {
      case CarouselStyle.tips:
        return 'Tips';
      case CarouselStyle.steps:
        return 'Steps';
      case CarouselStyle.beforeAfter:
        return 'Before-After';
      case CarouselStyle.mythVsFact:
        return 'Myth vs Fact';
      case CarouselStyle.promo:
        return 'Promo';
    }
  }
}

extension VideoStyleX on VideoStyle {
  String get displayName {
    switch (this) {
      case VideoStyle.modern:
        return 'Modern';
      case VideoStyle.clean:
        return 'Clean';
      case VideoStyle.kineticText:
        return 'Kinetic Text';
      case VideoStyle.productFocus:
        return 'Product Focus';
    }
  }
}

extension VideoDurationX on VideoDuration {
  String get displayName {
    switch (this) {
      case VideoDuration.fifteenSec:
        return '15s';
      case VideoDuration.thirtySec:
        return '30s';
      case VideoDuration.sixtySec:
        return '60s';
    }
  }

  int get seconds {
    switch (this) {
      case VideoDuration.fifteenSec:
        return 15;
      case VideoDuration.thirtySec:
        return 30;
      case VideoDuration.sixtySec:
        return 60;
    }
  }
}

/// Industry options
class Industries {
  static const List<String> all = [
    'Restaurant',
    'Fitness',
    'Tech',
    'Beauty',
    'Education',
    'Real Estate',
    'E-commerce',
    'Healthcare',
    'Finance',
    'Travel',
    'Fashion',
    'Other',
  ];
}

/// Caption variant model
class CaptionVariant {
  final String label;
  final String description;
  final String caption;
  final List<String> hashtags;

  const CaptionVariant({
    required this.label,
    required this.description,
    required this.caption,
    required this.hashtags,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'description': description,
    'caption': caption,
    'hashtags': hashtags,
  };

  factory CaptionVariant.fromJson(Map<String, dynamic> json) {
    return CaptionVariant(
      label: json['label'] as String,
      description: json['description'] as String,
      caption: json['caption'] as String,
      hashtags: List<String>.from(json['hashtags'] as List),
    );
  }
}

/// Carousel slide model
class CarouselSlide {
  final int slideNumber;
  final String title;
  final String body;
  final String visualSuggestion;

  const CarouselSlide({
    required this.slideNumber,
    required this.title,
    required this.body,
    required this.visualSuggestion,
  });

  Map<String, dynamic> toJson() => {
    'slideNumber': slideNumber,
    'title': title,
    'body': body,
    'visualSuggestion': visualSuggestion,
  };

  factory CarouselSlide.fromJson(Map<String, dynamic> json) {
    return CarouselSlide(
      slideNumber: json['slideNumber'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      visualSuggestion: json['visualSuggestion'] as String,
    );
  }
}

/// Generation request model
class GenerationRequest {
  final ContentMode mode;
  final String promptText;
  final String? industry;
  final ContentGoal goal;
  final List<SocialPlatform> platforms;
  final ContentTone tone;
  final ContentLength length;
  final CtaType cta;

  // Image specific
  final ImageStyle? imageStyle;
  final AppAspectRatio? aspectRatio;

  // Carousel specific
  final int? slideCount;
  final CarouselStyle? carouselStyle;

  // Video specific
  final VideoDuration? duration;
  final VideoStyle? videoStyle;

  const GenerationRequest({
    required this.mode,
    required this.promptText,
    this.industry,
    required this.goal,
    required this.platforms,
    required this.tone,
    required this.length,
    required this.cta,
    this.imageStyle,
    this.aspectRatio,
    this.slideCount,
    this.carouselStyle,
    this.duration,
    this.videoStyle,
  });

  GenerationRequest copyWith({
    ContentMode? mode,
    String? promptText,
    String? industry,
    ContentGoal? goal,
    List<SocialPlatform>? platforms,
    ContentTone? tone,
    ContentLength? length,
    CtaType? cta,
    ImageStyle? imageStyle,
    AppAspectRatio? aspectRatio,
    int? slideCount,
    CarouselStyle? carouselStyle,
    VideoDuration? duration,
    VideoStyle? videoStyle,
  }) {
    return GenerationRequest(
      mode: mode ?? this.mode,
      promptText: promptText ?? this.promptText,
      industry: industry ?? this.industry,
      goal: goal ?? this.goal,
      platforms: platforms ?? this.platforms,
      tone: tone ?? this.tone,
      length: length ?? this.length,
      cta: cta ?? this.cta,
      imageStyle: imageStyle ?? this.imageStyle,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      slideCount: slideCount ?? this.slideCount,
      carouselStyle: carouselStyle ?? this.carouselStyle,
      duration: duration ?? this.duration,
      videoStyle: videoStyle ?? this.videoStyle,
    );
  }
}

/// Generated content result
class GeneratedContent {
  final ContentMode mode;
  final List<CaptionVariant> captionVariants;
  final List<String> hashtags;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final List<CarouselSlide>? carouselSlides;
  final String? videoUrl;
  final DateTime generatedAt;

  const GeneratedContent({
    required this.mode,
    this.captionVariants = const [],
    this.hashtags = const [],
    this.imageUrl,
    this.imageBytes,
    this.carouselSlides,
    this.videoUrl,
    required this.generatedAt,
  });
}

/// User Intent Analysis result
class UserIntent {
  final String subject;
  final String style;
  final String emotion;
  final String contentIdea;
  final String imagePrompt;
  final String videoPrompt;
  final List<String> carouselTopics;
  final String targetAudience;

  const UserIntent({
    required this.subject,
    required this.style,
    required this.emotion,
    required this.contentIdea,
    required this.imagePrompt,
    required this.videoPrompt,
    required this.carouselTopics,
    required this.targetAudience,
  });

  factory UserIntent.defaultIntent(String rawInput) {
    return UserIntent(
      subject: rawInput,
      style: 'Professional',
      emotion: 'Positive',
      contentIdea: 'A post about $rawInput',
      imagePrompt: 'High quality realistic image related to $rawInput',
      videoPrompt: 'Cinematic motion video of $rawInput',
      carouselTopics: [
        'Introduction to $rawInput',
        'Key Benefits',
        'Next Steps',
      ],
      targetAudience: 'General Audience',
    );
  }

  factory UserIntent.fromJson(Map<String, dynamic> json) {
    return UserIntent(
      subject: json['subject'] ?? '',
      style: json['style'] ?? 'Modern',
      emotion: json['emotion'] ?? 'Inspirational',
      contentIdea: json['contentIdea'] ?? '',
      imagePrompt: json['imagePrompt'] ?? '',
      videoPrompt: json['videoPrompt'] ?? '',
      carouselTopics: List<String>.from(json['carouselTopics'] ?? []),
      targetAudience: json['targetAudience'] ?? 'Social Media Users',
    );
  }
}

/// Draft model for saved content
class ContentDraft {
  // ... existing code ...

  final String id;
  final DateTime createdAt;
  final ContentMode mode;
  final List<SocialPlatform> platforms;
  final String promptText;
  final String? caption;
  final List<String> hashtags;
  final String? imageUrl;
  final String? imageBytesBase64;
  final List<CarouselSlide>? carouselSlides;
  final String? videoUrl;
  final String? extraData; // For specialized module state (e.g. Editor layers)

  const ContentDraft({
    required this.id,
    required this.createdAt,
    required this.mode,
    required this.platforms,
    required this.promptText,
    this.caption,
    this.hashtags = const [],
    this.imageUrl,
    this.imageBytesBase64,
    this.carouselSlides,
    this.videoUrl,
    this.extraData,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'mode': mode.index,
    'platforms': platforms.map((p) => p.index).toList(),
    'promptText': promptText,
    'caption': caption,
    'hashtags': hashtags,
    'imageUrl': imageUrl,
    'imageBytesBase64': imageBytesBase64,
    'carouselSlides': carouselSlides?.map((s) => s.toJson()).toList(),
    'videoUrl': videoUrl,
    'extraData': extraData,
  };

  factory ContentDraft.fromJson(Map<String, dynamic> json) {
    return ContentDraft(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      mode: ContentMode.values[json['mode'] as int],
      platforms: (json['platforms'] as List)
          .map((i) => SocialPlatform.values[i as int])
          .toList(),
      promptText: json['promptText'] as String,
      caption: json['caption'] as String?,
      hashtags: json['hashtags'] != null
          ? List<String>.from(json['hashtags'] as List)
          : [],
      imageUrl: json['imageUrl'] as String?,
      imageBytesBase64: json['imageBytesBase64'] as String?,
      carouselSlides: json['carouselSlides'] != null
          ? (json['carouselSlides'] as List)
                .map((s) => CarouselSlide.fromJson(s as Map<String, dynamic>))
                .toList()
          : null,
      videoUrl: json['videoUrl'] as String?,
      extraData: json['extraData'] as String?,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ContentDraft.fromJsonString(String jsonString) {
    return ContentDraft.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  /// Get preview text for display
  String get previewText {
    if (caption != null && caption!.isNotEmpty) {
      return caption!.length > 80
          ? '${caption!.substring(0, 80)}...'
          : caption!;
    }
    return promptText.length > 80
        ? '${promptText.substring(0, 80)}...'
        : promptText;
  }
}

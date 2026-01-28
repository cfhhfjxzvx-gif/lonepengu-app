/// AI Text Generation Service Abstraction
/// BRD Section 5: API Integrations
///
/// Provides text generation capabilities for:
/// - Captions
/// - Hashtags
/// - Content ideas
/// - Post variations

/// Text generation request model
class TextGenerationRequest {
  final String prompt;
  final TextGenerationType type;
  final String? tone;
  final String? targetPlatform;
  final int? maxLength;
  final String? brandVoice;
  final List<String>? keywords;
  final String? industry;

  const TextGenerationRequest({
    required this.prompt,
    required this.type,
    this.tone,
    this.targetPlatform,
    this.maxLength,
    this.brandVoice,
    this.keywords,
    this.industry,
  });

  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    'type': type.name,
    'tone': tone,
    'targetPlatform': targetPlatform,
    'maxLength': maxLength,
    'brandVoice': brandVoice,
    'keywords': keywords,
    'industry': industry,
  };
}

/// Types of text generation
enum TextGenerationType {
  caption,
  hashtags,
  contentIdea,
  variation,
  translation,
  summary,
}

extension TextGenerationTypeX on TextGenerationType {
  String get displayName {
    switch (this) {
      case TextGenerationType.caption:
        return 'Caption';
      case TextGenerationType.hashtags:
        return 'Hashtags';
      case TextGenerationType.contentIdea:
        return 'Content Idea';
      case TextGenerationType.variation:
        return 'Variation';
      case TextGenerationType.translation:
        return 'Translation';
      case TextGenerationType.summary:
        return 'Summary';
    }
  }
}

/// Text generation result model
class TextGenerationResult {
  final bool success;
  final String? text;
  final List<String>? alternatives;
  final List<String>? hashtags;
  final String? error;
  final int? tokensUsed;
  final Duration? processingTime;

  const TextGenerationResult({
    required this.success,
    this.text,
    this.alternatives,
    this.hashtags,
    this.error,
    this.tokensUsed,
    this.processingTime,
  });

  factory TextGenerationResult.success({
    required String text,
    List<String>? alternatives,
    List<String>? hashtags,
    int? tokensUsed,
    Duration? processingTime,
  }) => TextGenerationResult(
    success: true,
    text: text,
    alternatives: alternatives,
    hashtags: hashtags,
    tokensUsed: tokensUsed,
    processingTime: processingTime,
  );

  factory TextGenerationResult.failure(String error) =>
      TextGenerationResult(success: false, error: error);
}

/// Abstract AI Text Service Interface
abstract class AITextService {
  /// Generate text based on request
  Future<TextGenerationResult> generateText(TextGenerationRequest request);

  /// Generate multiple caption variations
  Future<TextGenerationResult> generateCaptionVariations({
    required String topic,
    required int count,
    String? tone,
    String? platform,
  });

  /// Generate hashtags for content
  Future<TextGenerationResult> generateHashtags({
    required String content,
    required int count,
    String? platform,
  });

  /// Improve existing text
  Future<TextGenerationResult> improveText({
    required String text,
    String? targetTone,
    bool? makeMoreEngaging,
    bool? makeShorter,
  });

  /// Check content for issues
  Future<TextGenerationResult> analyzeContent({
    required String text,
    bool checkGrammar,
    bool checkTone,
    bool checkEngagement,
  });
}

/// Mock implementation for MVP
class MockAITextService implements AITextService {
  static const int _baseDelay = 800;

  // Mock caption templates
  static const List<String> _mockCaptions = [
    "✨ Every journey begins with a single step. What's yours? #motivation #journey",
    "🚀 Building something amazing, one day at a time. Stay tuned!",
    "💡 The best ideas come when you least expect them. Keep creating!",
    "🎯 Focus on progress, not perfection. You've got this!",
    "🌟 Small steps lead to big changes. Start today!",
  ];

  static const List<String> _mockHashtags = [
    '#motivation',
    '#inspiration',
    '#entrepreneur',
    '#business',
    '#success',
    '#goals',
    '#mindset',
    '#growth',
    '#startup',
    '#socialmedia',
    '#content',
    '#marketing',
    '#brand',
    '#creative',
  ];

  @override
  Future<TextGenerationResult> generateText(
    TextGenerationRequest request,
  ) async {
    final startTime = DateTime.now();
    await Future.delayed(
      Duration(milliseconds: _baseDelay + (request.prompt.length * 2)),
    );

    final processingTime = DateTime.now().difference(startTime);
    final mockIndex = request.prompt.hashCode.abs() % _mockCaptions.length;

    return TextGenerationResult.success(
      text: _mockCaptions[mockIndex],
      tokensUsed: 50 + (request.prompt.length ~/ 4),
      processingTime: processingTime,
    );
  }

  @override
  Future<TextGenerationResult> generateCaptionVariations({
    required String topic,
    required int count,
    String? tone,
    String? platform,
  }) async {
    await Future.delayed(Duration(milliseconds: _baseDelay * count));

    final variations = <String>[];
    for (var i = 0; i < count && i < _mockCaptions.length; i++) {
      variations.add(
        _mockCaptions[(topic.hashCode.abs() + i) % _mockCaptions.length],
      );
    }

    return TextGenerationResult.success(
      text: variations.first,
      alternatives: variations,
      tokensUsed: 30 * count,
    );
  }

  @override
  Future<TextGenerationResult> generateHashtags({
    required String content,
    required int count,
    String? platform,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final hashtags = <String>[];
    for (var i = 0; i < count && i < _mockHashtags.length; i++) {
      hashtags.add(
        _mockHashtags[(content.hashCode.abs() + i) % _mockHashtags.length],
      );
    }

    return TextGenerationResult.success(
      text: hashtags.join(' '),
      hashtags: hashtags,
      tokensUsed: 10 * count,
    );
  }

  @override
  Future<TextGenerationResult> improveText({
    required String text,
    String? targetTone,
    bool? makeMoreEngaging,
    bool? makeShorter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    var improved = text;
    if (makeMoreEngaging == true) {
      improved = "✨ $improved 🚀";
    }
    if (makeShorter == true && improved.length > 100) {
      improved = '${improved.substring(0, 97)}...';
    }

    return TextGenerationResult.success(
      text: improved,
      tokensUsed: text.length ~/ 4,
    );
  }

  @override
  Future<TextGenerationResult> analyzeContent({
    required String text,
    bool checkGrammar = true,
    bool checkTone = true,
    bool checkEngagement = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final feedback = StringBuffer();
    if (checkGrammar) feedback.writeln('✅ Grammar looks good');
    if (checkTone) feedback.writeln('✅ Tone is appropriate');
    if (checkEngagement) {
      if (text.contains('!') || text.contains('?')) {
        feedback.writeln('✅ Good engagement potential');
      } else {
        feedback.writeln('💡 Consider adding questions or CTAs');
      }
    }

    return TextGenerationResult.success(
      text: feedback.toString().trim(),
      tokensUsed: text.length ~/ 6,
    );
  }
}

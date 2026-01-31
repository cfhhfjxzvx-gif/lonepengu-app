import 'dart:math';
import '../../../core/services/xai_service.dart';
import '../../../core/services/logger_service.dart';
import 'content_models.dart';

/// Production-ready AI Content Generation Service
/// Uses xAI (Grok) for text and image generation
class AiContentService {
  static final _random = Random();

  /// Main entry point for generation (Strictly Isolated Modes)
  static Future<GeneratedContent> generateFromPrompt(
    GenerationRequest request, {
    Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.1);

      // 1. Analyze User Intent FIRST
      final intent = await XaiService.analyzeUserIntent(request.promptText);
      onProgress?.call(0.3);

      switch (request.mode) {
        case ContentMode.caption:
          return _handleCaptionGeneration(request, intent, onProgress);
        case ContentMode.image:
          return _handleImageGeneration(request, intent, onProgress);
        case ContentMode.carousel:
          return _handleCarouselGeneration(request, intent, onProgress);
        case ContentMode.video:
          return _handleVideoGeneration(request, intent, onProgress);
      }
    } catch (e) {
      LoggerService.error('Generation Error', e);
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // MODE HANDLERS
  // ═══════════════════════════════════════════════════════════════

  static Future<GeneratedContent> _handleCaptionGeneration(
    GenerationRequest request,
    UserIntent intent,
    Function(double)? onProgress,
  ) async {
    onProgress?.call(0.5);
    final variants = await XaiService.generateCaptions(
      prompt: request.promptText,
      intent: intent,
      tone: request.tone,
      goal: request.goal,
      platforms: request.platforms,
    );

    onProgress?.call(0.8);
    // Generate hashtags based on the extracted subject
    final hashtags = _generateHashtagsFromSubject(intent.subject);

    onProgress?.call(1.0);
    return GeneratedContent(
      mode: ContentMode.caption,
      captionVariants: variants,
      hashtags: hashtags,
      generatedAt: DateTime.now(),
    );
  }

  static Future<GeneratedContent> _handleImageGeneration(
    GenerationRequest request,
    UserIntent intent,
    Function(double)? onProgress,
  ) async {
    onProgress?.call(0.5);
    // Dynamic image generation based on expanded intent prompt
    final imageUrl = await XaiService.generateImage(
      prompt: request.promptText,
      intent: intent,
      style: request.imageStyle,
      ratio: request.aspectRatio,
    );

    onProgress?.call(1.0);
    return GeneratedContent(
      mode: ContentMode.image,
      imageUrl: imageUrl,
      captionVariants: [
        CaptionVariant(
          label: 'Mood',
          description: 'Reflecting the visual',
          caption: intent.contentIdea.isNotEmpty
              ? intent.contentIdea
              : 'Captured: ${intent.subject}. A visual exploration of ${intent.emotion} in ${intent.style} style.',
          hashtags: _generateHashtagsFromSubject(intent.subject),
        ),
      ],
      generatedAt: DateTime.now(),
    );
  }

  static Future<GeneratedContent> _handleCarouselGeneration(
    GenerationRequest request,
    UserIntent intent,
    Function(double)? onProgress,
  ) async {
    onProgress?.call(0.5);
    final slides = await XaiService.generateCarousel(
      prompt: request.promptText,
      intent: intent,
      slideCount: request.slideCount ?? 5,
    );

    onProgress?.call(1.0);
    return GeneratedContent(
      mode: ContentMode.carousel,
      carouselSlides: slides,
      captionVariants: [
        CaptionVariant(
          label: 'Overview',
          description: 'Carousel intro',
          caption:
              'Swipe through to learn about ${intent.subject}. ${intent.contentIdea}',
          hashtags: _generateHashtagsFromSubject(intent.subject),
        ),
      ],
      generatedAt: DateTime.now(),
    );
  }

  static Future<GeneratedContent> _handleVideoGeneration(
    GenerationRequest request,
    UserIntent intent,
    Function(double)? onProgress,
  ) async {
    onProgress?.call(0.5);

    // Dynamic Video Generation
    final videoUrl = await XaiService.generateVideo(
      prompt: request.promptText,
      intent: intent,
      ratio: request.aspectRatio,
    );

    onProgress?.call(1.0);
    return GeneratedContent(
      mode: ContentMode.video,
      videoUrl: videoUrl,
      captionVariants: [
        CaptionVariant(
          label: 'Motion',
          description: 'Dynamic motion',
          caption:
              'Bringing ${intent.subject} to life with cinematic motion. ✨',
          hashtags: _generateHashtagsFromSubject(intent.subject),
        ),
      ],
      generatedAt: DateTime.now(),
    );
  }

  // ═══════════════════════════════════════════
  // UTILS
  // ═══════════════════════════════════════════

  static List<String> _generateHashtagsFromSubject(String subject) {
    final cleanSubject = subject.replaceAll(' ', '');
    return [
      '#$cleanSubject',
      '#lonepengu',
      '#aipowered',
      '#socialmedia',
      '#originalcontent',
    ];
  }

  /// Surprise / Random Generation
  static Future<GeneratedContent> generateSurprise(
    GenerationRequest request,
  ) async {
    final modes = [ContentMode.caption, ContentMode.image];
    final randomMode = modes[_random.nextInt(modes.length)];
    return generateFromPrompt(request.copyWith(mode: randomMode));
  }
}

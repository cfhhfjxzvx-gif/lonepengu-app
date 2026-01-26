import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'content_models.dart';

/// Mocked AI Content Generation Service
/// Ready for real API integration later
class AiContentService {
  static final _random = Random();

  /// Main entry point for generation, routes based on mode/intent
  static Future<GeneratedContent> generateFromPrompt(
    GenerationRequest request, {
    Function(double)? onProgress,
  }) async {
    switch (request.mode) {
      case ContentMode.auto:
        // This case should be handled by the UI calling the specific generator
        // after intent detection, but we'll provide a fallback just in case.
        return generateCaption(request);
      case ContentMode.caption:
        return generateCaption(request);
      case ContentMode.image:
        return generateImage(request, onProgress: onProgress);
      case ContentMode.carousel:
        return generateCarousel(request, onProgress: onProgress);
      case ContentMode.video:
        return generateVideo(request, onProgress: onProgress);
    }
  }

  /// Generate caption content
  /// Simulates < 2s delay as per BRD
  static Future<GeneratedContent> generateCaption(
    GenerationRequest request,
  ) async {
    // Simulate API delay (1-2 seconds)
    await Future.delayed(Duration(milliseconds: 1000 + _random.nextInt(1000)));

    final variants = _generateCaptionVariants(request);
    final hashtags = _generateHashtags(request);

    return GeneratedContent(
      mode: ContentMode.caption,
      captionVariants: variants,
      hashtags: hashtags,
      generatedAt: DateTime.now(),
    );
  }

  /// Generate image content
  /// Simulates 5-10s delay as per BRD (<30s)
  static Future<GeneratedContent> generateImage(
    GenerationRequest request, {
    Function(double)? onProgress,
  }) async {
    // Simulate API delay with progress (5-10 seconds)
    final totalDuration = 5000 + _random.nextInt(5000);
    const steps = 20;
    final stepDuration = totalDuration ~/ steps;

    for (int i = 0; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      onProgress?.call(i / steps);
    }

    final variants = _generateCaptionVariants(request);
    final hashtags = _generateHashtags(request);

    // For universal web/mobile compatibility, we simulate fetching actual bytes
    // In a real app, this would be the response from from OpenAI/Stability/etc.
    Uint8List? bytes;
    try {
      final ByteData data = await rootBundle.load(
        'assets/images/lonepengu_logo.png',
      );
      bytes = data.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error loading mock image: $e');
    }

    return GeneratedContent(
      mode: ContentMode.image,
      captionVariants: variants,
      hashtags: hashtags,
      imageUrl: 'https://picsum.photos/800/800?random=${_random.nextInt(1000)}',
      imageBytes: bytes,
      generatedAt: DateTime.now(),
    );
  }

  /// Generate carousel content
  /// Simulates 3-5s delay
  static Future<GeneratedContent> generateCarousel(
    GenerationRequest request, {
    Function(double)? onProgress,
  }) async {
    final slideCount = request.slideCount ?? 5;
    final totalDuration = 3000 + _random.nextInt(2000);
    const steps = 10;
    final stepDuration = totalDuration ~/ steps;

    for (int i = 0; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      onProgress?.call(i / steps);
    }

    final slides = _generateCarouselSlides(request, slideCount);
    final variants = _generateCaptionVariants(request);
    final hashtags = _generateHashtags(request);

    return GeneratedContent(
      mode: ContentMode.carousel,
      captionVariants: variants,
      hashtags: hashtags,
      carouselSlides: slides,
      generatedAt: DateTime.now(),
    );
  }

  /// Generate video content
  /// Simulates 20-40s delay as per BRD (<2 min)
  static Future<GeneratedContent> generateVideo(
    GenerationRequest request, {
    Function(double)? onProgress,
  }) async {
    // Simulate API delay with progress (20-40 seconds)
    final totalDuration = 20000 + _random.nextInt(20000);
    const steps = 50;
    final stepDuration = totalDuration ~/ steps;

    for (int i = 0; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      onProgress?.call(i / steps);
    }

    final variants = _generateCaptionVariants(request);
    final hashtags = _generateHashtags(request);

    return GeneratedContent(
      mode: ContentMode.video,
      captionVariants: variants,
      hashtags: hashtags,
      videoUrl:
          'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
      generatedAt: DateTime.now(),
    );
  }

  /// Generate surprise content (random mode)
  static Future<GeneratedContent> generateSurprise(
    GenerationRequest request,
  ) async {
    final modes = [ContentMode.caption, ContentMode.image];
    final randomMode = modes[_random.nextInt(modes.length)];

    final newRequest = GenerationRequest(
      mode: randomMode,
      promptText: request.promptText.isEmpty
          ? _getRandomPrompt()
          : request.promptText,
      goal: request.goal,
      platforms: request.platforms,
      tone: request.tone,
      length: request.length,
      cta: request.cta,
    );

    if (randomMode == ContentMode.image) {
      return generateImage(newRequest);
    }
    return generateCaption(newRequest);
  }

  // Private helper methods

  static List<CaptionVariant> _generateCaptionVariants(
    GenerationRequest request,
  ) {
    final topic = request.promptText.isNotEmpty
        ? request.promptText
        : 'your amazing product';

    final cta = request.cta.displayName;

    return [
      CaptionVariant(
        label: 'Variant A',
        description: 'Recommended',
        caption: _getVariantACaption(topic, request.tone, cta),
        hashtags: _generateHashtags(request).take(8).toList(),
      ),
      CaptionVariant(
        label: 'Variant B',
        description: 'More salesy',
        caption: _getVariantBCaption(topic, request.tone, cta),
        hashtags: _generateHashtags(request).take(10).toList(),
      ),
      CaptionVariant(
        label: 'Variant C',
        description: 'More casual',
        caption: _getVariantCCaption(topic, request.tone, cta),
        hashtags: _generateHashtags(request).take(6).toList(),
      ),
    ];
  }

  static String _getVariantACaption(
    String topic,
    ContentTone tone,
    String cta,
  ) {
    switch (tone) {
      case ContentTone.professional:
        return '✨ Introducing something extraordinary: $topic\n\nWe\'re excited to share this with you. Our commitment to excellence drives everything we create.\n\n👉 $cta - Link in bio';
      case ContentTone.friendly:
        return 'Hey friends! 👋\n\nWe\'ve got something special for you today: $topic! We can\'t wait for you to experience it.\n\nDrop a ❤️ if you\'re excited!\n\n$cta 🔗';
      case ContentTone.bold:
        return '🔥 GAME CHANGER ALERT 🔥\n\n$topic is HERE and it\'s about to shake things up!\n\nDon\'t just watch the revolution — BE PART OF IT.\n\n$cta NOW ⚡';
      case ContentTone.minimal:
        return '$topic.\n\nSimple. Elegant. Effective.\n\n$cta ↗';
      case ContentTone.funny:
        return 'POV: You just discovered $topic and your life will never be the same 😅\n\n*chef\'s kiss* 👨‍🍳\n\n$cta before FOMO kicks in!';
      case ContentTone.luxury:
        return 'Experience unparalleled excellence with $topic.\n\nCrafted for the discerning. Designed for perfection.\n\nElevate your standards. $cta';
    }
  }

  static String _getVariantBCaption(
    String topic,
    ContentTone tone,
    String cta,
  ) {
    return '🚀 LIMITED TIME OFFER! 🚀\n\nDiscover $topic - the solution you\'ve been waiting for!\n\n✅ Premium quality\n✅ Trusted by thousands\n✅ Results guaranteed\n\n⏰ Don\'t miss out - $cta TODAY!\n\n#sale #limitedoffer #exclusive';
  }

  static String _getVariantCCaption(
    String topic,
    ContentTone tone,
    String cta,
  ) {
    return 'Just dropped: $topic 🙌\n\nHonestly, we\'re pretty proud of this one. Thought you might like it too!\n\nLet us know what you think in the comments 💬\n\n$cta if you\'re curious!';
  }

  static List<String> _generateHashtags(GenerationRequest request) {
    final baseHashtags = [
      'business',
      'entrepreneur',
      'success',
      'growth',
      'marketing',
      'socialmedia',
      'digitalmarketing',
      'brand',
      'startup',
      'motivation',
      'inspiration',
      'goals',
    ];

    final industryHashtags = _getIndustryHashtags(request.industry);
    final platformHashtags = _getPlatformHashtags(request.platforms);
    final goalHashtags = _getGoalHashtags(request.goal);

    final allHashtags = <String>{
      ...baseHashtags,
      ...industryHashtags,
      ...platformHashtags,
      ...goalHashtags,
    }.toList();

    allHashtags.shuffle(_random);
    return allHashtags.take(15).toList();
  }

  static List<String> _getIndustryHashtags(String? industry) {
    if (industry == null) return [];

    switch (industry.toLowerCase()) {
      case 'restaurant':
        return ['foodie', 'restaurant', 'delicious', 'foodporn', 'chef'];
      case 'fitness':
        return ['fitness', 'workout', 'gym', 'health', 'fitnessmotivation'];
      case 'tech':
        return ['technology', 'tech', 'innovation', 'software', 'ai'];
      case 'beauty':
        return ['beauty', 'skincare', 'makeup', 'beautytips', 'selfcare'];
      case 'education':
        return ['education', 'learning', 'students', 'knowledge', 'study'];
      case 'real estate':
        return ['realestate', 'property', 'home', 'investment', 'realtor'];
      case 'e-commerce':
        return ['ecommerce', 'onlineshopping', 'shop', 'deals', 'sale'];
      default:
        return [];
    }
  }

  static List<String> _getPlatformHashtags(List<SocialPlatform> platforms) {
    final hashtags = <String>[];
    for (final platform in platforms) {
      switch (platform) {
        case SocialPlatform.instagram:
          hashtags.addAll(['instadaily', 'instagood', 'photooftheday']);
          break;
        case SocialPlatform.facebook:
          hashtags.addAll(['facebook', 'fbpost', 'community']);
          break;
        case SocialPlatform.linkedin:
          hashtags.addAll(['linkedin', 'networking', 'professional']);
          break;
        case SocialPlatform.x:
          hashtags.addAll(['trending', 'viral', 'thread']);
          break;
      }
    }
    return hashtags;
  }

  static List<String> _getGoalHashtags(ContentGoal goal) {
    switch (goal) {
      case ContentGoal.awareness:
        return ['brandawareness', 'discover', 'explore'];
      case ContentGoal.engagement:
        return ['community', 'conversation', 'engage'];
      case ContentGoal.leads:
        return ['leadgeneration', 'growyourbusiness', 'opportunity'];
      case ContentGoal.sales:
        return ['sale', 'discount', 'shopnow', 'limitedoffer'];
    }
  }

  static List<CarouselSlide> _generateCarouselSlides(
    GenerationRequest request,
    int count,
  ) {
    final topic = request.promptText.isNotEmpty
        ? request.promptText
        : 'your topic';
    final style = request.carouselStyle ?? CarouselStyle.tips;

    return List.generate(count, (index) {
      return CarouselSlide(
        slideNumber: index + 1,
        title: _getSlideTitle(style, index, count, topic),
        body: _getSlideBody(style, index, topic),
        visualSuggestion: _getVisualSuggestion(style, index),
      );
    });
  }

  static String _getSlideTitle(
    CarouselStyle style,
    int index,
    int total,
    String topic,
  ) {
    if (index == 0) {
      return '$total ${style.displayName} About $topic';
    }

    switch (style) {
      case CarouselStyle.tips:
        return 'Tip #${index}';
      case CarouselStyle.steps:
        return 'Step ${index} of ${total - 1}';
      case CarouselStyle.beforeAfter:
        return index % 2 == 1 ? 'Before' : 'After';
      case CarouselStyle.mythVsFact:
        return index % 2 == 1 ? '❌ Myth' : '✅ Fact';
      case CarouselStyle.promo:
        return index == total - 1 ? 'Get Yours Now!' : 'Feature #$index';
    }
  }

  static String _getSlideBody(CarouselStyle style, int index, String topic) {
    if (index == 0) {
      return 'Swipe through to learn more about $topic and discover insights that will transform your approach.';
    }

    final bodies = [
      'This is a key insight that your audience needs to know about.',
      'Here\'s something that will change how you think about this topic.',
      'Most people don\'t realize this important fact.',
      'This is the secret that top performers use.',
      'Apply this and see immediate results.',
      'Don\'t skip this crucial step!',
      'This one tip alone can make a huge difference.',
      'Save this for later - you\'ll thank us!',
    ];

    return bodies[index % bodies.length];
  }

  static String _getVisualSuggestion(CarouselStyle style, int index) {
    if (index == 0) {
      return 'Bold headline with gradient background, brand logo in corner';
    }

    final suggestions = [
      'Icon + text on solid color background',
      'Split layout: image left, text right',
      'Full bleed image with text overlay',
      'Numbered list with checkmarks',
      'Quote style with quotation marks',
      'Comparison layout side by side',
      'Stats/numbers with large typography',
      'CTA button mockup with arrow',
    ];

    return suggestions[index % suggestions.length];
  }

  static String _getRandomPrompt() {
    final prompts = [
      'Exciting new product launch',
      'Behind the scenes of our team',
      'Customer success story',
      'Industry tips and tricks',
      'Motivational Monday content',
      'Weekend vibes and updates',
    ];
    return prompts[_random.nextInt(prompts.length)];
  }
}

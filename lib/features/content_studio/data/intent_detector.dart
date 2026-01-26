import 'content_models.dart';

class IntentDetectionResult {
  final ContentMode intent;
  final double confidence;
  final Map<String, dynamic> metadata;

  IntentDetectionResult({
    required this.intent,
    required this.confidence,
    this.metadata = const {},
  });
}

class IntentDetector {
  static IntentDetectionResult detectIntent(String promptText) {
    if (promptText.isEmpty) {
      return IntentDetectionResult(
        intent: ContentMode.caption,
        confidence: 0.0,
      );
    }

    final text = promptText.toLowerCase();

    // 1. Video Detection
    final videoKeywords = [
      'video',
      'motion',
      'reel',
      'story video',
      '15 sec',
      '30 sec',
      '60 sec',
      'animation',
      'clip',
      'mp4',
    ];
    final videoMatches = videoKeywords.where((k) => text.contains(k)).length;
    final videoDurationMatch = _detectVideoDuration(text);

    // 2. Carousel Detection
    final carouselKeywords = [
      'carousel',
      'slides',
      'slide',
      'steps',
      'tips',
      'myth vs fact',
      'before after',
      'presentation',
    ];
    final carouselMatches = carouselKeywords
        .where((k) => text.contains(k))
        .length;
    final slideCountMatch = _detectSlideCount(text);

    // 3. Image Detection
    final imageKeywords = [
      'image',
      'photo',
      'pic',
      'poster',
      'banner',
      'generate image',
      'create image',
      'animal',
      'dog',
      'cat',
      'horse',
      'product shot',
      'logo',
      'background',
      'illustration',
      'art',
      'painting',
    ];
    final imageMatches = imageKeywords.where((k) => text.contains(k)).length;

    // 4. Caption Detection
    final captionKeywords = [
      'caption',
      'write',
      'copy',
      'hook',
      'headline',
      'bio',
      'hashtags only',
      'text',
      'post',
    ];
    final captionMatches = captionKeywords
        .where((k) => text.contains(k))
        .length;

    // Logic: video > carousel > image > caption

    if (videoMatches > 0 || videoDurationMatch != null) {
      return IntentDetectionResult(
        intent: ContentMode.video,
        confidence: _calculateConfidence(videoMatches, 0.8),
        metadata: {'duration': videoDurationMatch ?? VideoDuration.thirtySec},
      );
    }

    if (carouselMatches > 0 || slideCountMatch != null) {
      return IntentDetectionResult(
        intent: ContentMode.carousel,
        confidence: _calculateConfidence(carouselMatches, 0.75),
        metadata: {'slideCount': slideCountMatch ?? 5},
      );
    }

    if (imageMatches > 0) {
      return IntentDetectionResult(
        intent: ContentMode.image,
        confidence: _calculateConfidence(imageMatches, 0.7),
      );
    }

    // Default to caption with low confidence or based on keywords
    return IntentDetectionResult(
      intent: ContentMode.caption,
      confidence: captionMatches > 0
          ? _calculateConfidence(captionMatches, 0.6)
          : 0.4,
    );
  }

  static double _calculateConfidence(int matches, double base) {
    if (matches == 0) return base;
    return (base + (matches * 0.05)).clamp(0.0, 0.98);
  }

  static VideoDuration? _detectVideoDuration(String text) {
    if (text.contains('15 sec') || text.contains('15s'))
      return VideoDuration.fifteenSec;
    if (text.contains('30 sec') || text.contains('30s'))
      return VideoDuration.thirtySec;
    if (text.contains('60 sec') || text.contains('60s'))
      return VideoDuration.sixtySec;
    return null;
  }

  static int? _detectSlideCount(String text) {
    final regExp = RegExp(r'(\d+)\s*(slides?|steps?|tips?)');
    final match = regExp.firstMatch(text);
    if (match != null) {
      final count = int.tryParse(match.group(1) ?? '');
      if (count != null && count >= 2 && count <= 10) {
        return count;
      }
    }
    return null;
  }
}

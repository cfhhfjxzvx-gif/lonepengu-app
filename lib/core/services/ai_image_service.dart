/// AI Image Generation Service Abstraction
/// BRD Section 5: API Integrations
///
/// Provides image generation and editing capabilities:
/// - Text-to-image generation
/// - Image enhancement
/// - Background removal
/// - Style transfer

/// Image generation request model
class ImageGenerationRequest {
  final String prompt;
  final ImageSize size;
  final ImageStyle? style;
  final String? negativePrompt;
  final int? seed;
  final double? guidanceScale;
  final int count;

  const ImageGenerationRequest({
    required this.prompt,
    this.size = ImageSize.square1024,
    this.style,
    this.negativePrompt,
    this.seed,
    this.guidanceScale,
    this.count = 1,
  });

  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    'size': size.name,
    'style': style?.name,
    'negativePrompt': negativePrompt,
    'seed': seed,
    'guidanceScale': guidanceScale,
    'count': count,
  };
}

/// Supported image sizes
enum ImageSize {
  square512,
  square1024,
  portrait768x1024,
  landscape1024x768,
  instagram1080x1080,
  instagramStory1080x1920,
  facebookCover1200x630,
  linkedInPost1200x627,
  twitterPost1200x675,
}

extension ImageSizeX on ImageSize {
  int get width {
    switch (this) {
      case ImageSize.square512:
        return 512;
      case ImageSize.square1024:
      case ImageSize.portrait768x1024:
        return 1024;
      case ImageSize.landscape1024x768:
        return 1024;
      case ImageSize.instagram1080x1080:
      case ImageSize.instagramStory1080x1920:
        return 1080;
      case ImageSize.facebookCover1200x630:
      case ImageSize.linkedInPost1200x627:
      case ImageSize.twitterPost1200x675:
        return 1200;
    }
  }

  int get height {
    switch (this) {
      case ImageSize.square512:
        return 512;
      case ImageSize.square1024:
        return 1024;
      case ImageSize.portrait768x1024:
        return 1024;
      case ImageSize.landscape1024x768:
        return 768;
      case ImageSize.instagram1080x1080:
        return 1080;
      case ImageSize.instagramStory1080x1920:
        return 1920;
      case ImageSize.facebookCover1200x630:
        return 630;
      case ImageSize.linkedInPost1200x627:
        return 627;
      case ImageSize.twitterPost1200x675:
        return 675;
    }
  }

  String get displayName {
    switch (this) {
      case ImageSize.square512:
        return '512×512';
      case ImageSize.square1024:
        return '1024×1024';
      case ImageSize.portrait768x1024:
        return '768×1024 Portrait';
      case ImageSize.landscape1024x768:
        return '1024×768 Landscape';
      case ImageSize.instagram1080x1080:
        return 'Instagram Post';
      case ImageSize.instagramStory1080x1920:
        return 'Instagram Story';
      case ImageSize.facebookCover1200x630:
        return 'Facebook Cover';
      case ImageSize.linkedInPost1200x627:
        return 'LinkedIn Post';
      case ImageSize.twitterPost1200x675:
        return 'Twitter Post';
    }
  }
}

/// Image generation styles
enum ImageStyle {
  photorealistic,
  digital_art,
  illustration,
  minimalist,
  abstract_art,
  vintage,
  neon,
  watercolor,
  sketch,
  cinematic,
}

extension ImageStyleX on ImageStyle {
  String get displayName {
    switch (this) {
      case ImageStyle.photorealistic:
        return 'Photorealistic';
      case ImageStyle.digital_art:
        return 'Digital Art';
      case ImageStyle.illustration:
        return 'Illustration';
      case ImageStyle.minimalist:
        return 'Minimalist';
      case ImageStyle.abstract_art:
        return 'Abstract';
      case ImageStyle.vintage:
        return 'Vintage';
      case ImageStyle.neon:
        return 'Neon';
      case ImageStyle.watercolor:
        return 'Watercolor';
      case ImageStyle.sketch:
        return 'Sketch';
      case ImageStyle.cinematic:
        return 'Cinematic';
    }
  }
}

/// Generated image model
class GeneratedImage {
  final String id;
  final String? url;
  final String? base64Data;
  final ImageSize size;
  final String prompt;
  final DateTime createdAt;

  const GeneratedImage({
    required this.id,
    this.url,
    this.base64Data,
    required this.size,
    required this.prompt,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'base64Data': base64Data,
    'size': size.name,
    'prompt': prompt,
    'createdAt': createdAt.toIso8601String(),
  };
}

/// Image generation result model
class ImageGenerationResult {
  final bool success;
  final List<GeneratedImage>? images;
  final String? error;
  final int? creditsUsed;
  final Duration? processingTime;

  const ImageGenerationResult({
    required this.success,
    this.images,
    this.error,
    this.creditsUsed,
    this.processingTime,
  });

  factory ImageGenerationResult.success({
    required List<GeneratedImage> images,
    int? creditsUsed,
    Duration? processingTime,
  }) => ImageGenerationResult(
    success: true,
    images: images,
    creditsUsed: creditsUsed,
    processingTime: processingTime,
  );

  factory ImageGenerationResult.failure(String error) =>
      ImageGenerationResult(success: false, error: error);
}

/// Abstract AI Image Service Interface
abstract class AIImageService {
  /// Generate images from text prompt
  Future<ImageGenerationResult> generateImage(ImageGenerationRequest request);

  /// Enhance an existing image
  Future<ImageGenerationResult> enhanceImage({
    required String imageUrl,
    double? brightnessAdjust,
    double? contrastAdjust,
    double? saturationAdjust,
    bool? upscale,
  });

  /// Remove background from image
  Future<ImageGenerationResult> removeBackground({required String imageUrl});

  /// Apply style transfer to image
  Future<ImageGenerationResult> applyStyleTransfer({
    required String imageUrl,
    required ImageStyle targetStyle,
  });

  /// Generate variations of an image
  Future<ImageGenerationResult> generateVariations({
    required String imageUrl,
    required int count,
  });
}

/// Mock implementation for MVP
class MockAIImageService implements AIImageService {
  static const int _baseDelay = 2000;

  // Mock placeholder image URLs (using placeholder service)
  String _getMockImageUrl(ImageSize size, String prompt) {
    // In production, this would be actual generated images
    // For MVP, return a mock placeholder concept
    return 'generated_${size.width}x${size.height}_${prompt.hashCode.abs()}';
  }

  @override
  Future<ImageGenerationResult> generateImage(
    ImageGenerationRequest request,
  ) async {
    final startTime = DateTime.now();
    await Future.delayed(Duration(milliseconds: _baseDelay * request.count));

    final images = <GeneratedImage>[];
    for (var i = 0; i < request.count; i++) {
      images.add(
        GeneratedImage(
          id: 'img_${DateTime.now().millisecondsSinceEpoch}_$i',
          url: _getMockImageUrl(request.size, '${request.prompt}_$i'),
          size: request.size,
          prompt: request.prompt,
          createdAt: DateTime.now(),
        ),
      );
    }

    return ImageGenerationResult.success(
      images: images,
      creditsUsed: request.count * 10,
      processingTime: DateTime.now().difference(startTime),
    );
  }

  @override
  Future<ImageGenerationResult> enhanceImage({
    required String imageUrl,
    double? brightnessAdjust,
    double? contrastAdjust,
    double? saturationAdjust,
    bool? upscale,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    return ImageGenerationResult.success(
      images: [
        GeneratedImage(
          id: 'enhanced_${DateTime.now().millisecondsSinceEpoch}',
          url: 'enhanced_$imageUrl',
          size: ImageSize.square1024,
          prompt: 'Enhanced image',
          createdAt: DateTime.now(),
        ),
      ],
      creditsUsed: 5,
    );
  }

  @override
  Future<ImageGenerationResult> removeBackground({
    required String imageUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    return ImageGenerationResult.success(
      images: [
        GeneratedImage(
          id: 'nobg_${DateTime.now().millisecondsSinceEpoch}',
          url: 'nobg_$imageUrl',
          size: ImageSize.square1024,
          prompt: 'Background removed',
          createdAt: DateTime.now(),
        ),
      ],
      creditsUsed: 3,
    );
  }

  @override
  Future<ImageGenerationResult> applyStyleTransfer({
    required String imageUrl,
    required ImageStyle targetStyle,
  }) async {
    await Future.delayed(const Duration(milliseconds: 2500));

    return ImageGenerationResult.success(
      images: [
        GeneratedImage(
          id: 'styled_${DateTime.now().millisecondsSinceEpoch}',
          url: 'styled_${targetStyle.name}_$imageUrl',
          size: ImageSize.square1024,
          prompt: 'Style: ${targetStyle.displayName}',
          createdAt: DateTime.now(),
        ),
      ],
      creditsUsed: 8,
    );
  }

  @override
  Future<ImageGenerationResult> generateVariations({
    required String imageUrl,
    required int count,
  }) async {
    await Future.delayed(Duration(milliseconds: 1500 * count));

    final images = <GeneratedImage>[];
    for (var i = 0; i < count; i++) {
      images.add(
        GeneratedImage(
          id: 'var_${DateTime.now().millisecondsSinceEpoch}_$i',
          url: 'variation_${i}_$imageUrl',
          size: ImageSize.square1024,
          prompt: 'Variation $i',
          createdAt: DateTime.now(),
        ),
      );
    }

    return ImageGenerationResult.success(
      images: images,
      creditsUsed: count * 5,
    );
  }
}

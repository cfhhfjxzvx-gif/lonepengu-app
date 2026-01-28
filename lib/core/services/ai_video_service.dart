/// AI Video Generation Service Abstraction
/// BRD Section 5: API Integrations
///
/// Provides video generation and editing capabilities:
/// - Text-to-video generation
/// - Image-to-video animation
/// - Video enhancement
/// - Video trimming/editing

/// Video generation status
enum VideoGenerationStatus { queued, processing, completed, failed }

extension VideoGenerationStatusX on VideoGenerationStatus {
  String get displayName {
    switch (this) {
      case VideoGenerationStatus.queued:
        return 'Queued';
      case VideoGenerationStatus.processing:
        return 'Processing';
      case VideoGenerationStatus.completed:
        return 'Completed';
      case VideoGenerationStatus.failed:
        return 'Failed';
    }
  }

  bool get isTerminal =>
      this == VideoGenerationStatus.completed ||
      this == VideoGenerationStatus.failed;
}

/// Video generation request model
class VideoGenerationRequest {
  final String prompt;
  final VideoSize size;
  final int durationSeconds;
  final VideoStyle? style;
  final String? sourceImageUrl;
  final bool? loop;

  const VideoGenerationRequest({
    required this.prompt,
    this.size = VideoSize.square,
    this.durationSeconds = 5,
    this.style,
    this.sourceImageUrl,
    this.loop,
  });

  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    'size': size.name,
    'durationSeconds': durationSeconds,
    'style': style?.name,
    'sourceImageUrl': sourceImageUrl,
    'loop': loop,
  };
}

/// Supported video sizes
enum VideoSize { square, portrait, landscape, instagramReel, tiktok, youtube }

extension VideoSizeX on VideoSize {
  int get width {
    switch (this) {
      case VideoSize.square:
        return 1080;
      case VideoSize.portrait:
      case VideoSize.instagramReel:
      case VideoSize.tiktok:
        return 1080;
      case VideoSize.landscape:
      case VideoSize.youtube:
        return 1920;
    }
  }

  int get height {
    switch (this) {
      case VideoSize.square:
        return 1080;
      case VideoSize.portrait:
      case VideoSize.instagramReel:
      case VideoSize.tiktok:
        return 1920;
      case VideoSize.landscape:
      case VideoSize.youtube:
        return 1080;
    }
  }

  String get aspectRatio {
    switch (this) {
      case VideoSize.square:
        return '1:1';
      case VideoSize.portrait:
      case VideoSize.instagramReel:
      case VideoSize.tiktok:
        return '9:16';
      case VideoSize.landscape:
      case VideoSize.youtube:
        return '16:9';
    }
  }

  String get displayName {
    switch (this) {
      case VideoSize.square:
        return 'Square (1:1)';
      case VideoSize.portrait:
        return 'Portrait (9:16)';
      case VideoSize.landscape:
        return 'Landscape (16:9)';
      case VideoSize.instagramReel:
        return 'Instagram Reel';
      case VideoSize.tiktok:
        return 'TikTok';
      case VideoSize.youtube:
        return 'YouTube';
    }
  }
}

/// Video generation styles
enum VideoStyle {
  realistic,
  animated,
  cinematic,
  documentary,
  promotional,
  slideshow,
}

extension VideoStyleX on VideoStyle {
  String get displayName {
    switch (this) {
      case VideoStyle.realistic:
        return 'Realistic';
      case VideoStyle.animated:
        return 'Animated';
      case VideoStyle.cinematic:
        return 'Cinematic';
      case VideoStyle.documentary:
        return 'Documentary';
      case VideoStyle.promotional:
        return 'Promotional';
      case VideoStyle.slideshow:
        return 'Slideshow';
    }
  }
}

/// Generated video model
class GeneratedVideo {
  final String id;
  final String? url;
  final String? thumbnailUrl;
  final VideoSize size;
  final int durationSeconds;
  final String prompt;
  final VideoGenerationStatus status;
  final double? progress;
  final DateTime createdAt;
  final String? error;

  const GeneratedVideo({
    required this.id,
    this.url,
    this.thumbnailUrl,
    required this.size,
    required this.durationSeconds,
    required this.prompt,
    required this.status,
    this.progress,
    required this.createdAt,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'thumbnailUrl': thumbnailUrl,
    'size': size.name,
    'durationSeconds': durationSeconds,
    'prompt': prompt,
    'status': status.name,
    'progress': progress,
    'createdAt': createdAt.toIso8601String(),
    'error': error,
  };

  GeneratedVideo copyWith({
    String? id,
    String? url,
    String? thumbnailUrl,
    VideoSize? size,
    int? durationSeconds,
    String? prompt,
    VideoGenerationStatus? status,
    double? progress,
    DateTime? createdAt,
    String? error,
  }) {
    return GeneratedVideo(
      id: id ?? this.id,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      size: size ?? this.size,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      prompt: prompt ?? this.prompt,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      error: error ?? this.error,
    );
  }
}

/// Video generation result model
class VideoGenerationResult {
  final bool success;
  final GeneratedVideo? video;
  final String? jobId;
  final String? error;
  final int? creditsUsed;
  final int? estimatedSeconds;

  const VideoGenerationResult({
    required this.success,
    this.video,
    this.jobId,
    this.error,
    this.creditsUsed,
    this.estimatedSeconds,
  });

  factory VideoGenerationResult.success({
    required GeneratedVideo video,
    String? jobId,
    int? creditsUsed,
    int? estimatedSeconds,
  }) => VideoGenerationResult(
    success: true,
    video: video,
    jobId: jobId,
    creditsUsed: creditsUsed,
    estimatedSeconds: estimatedSeconds,
  );

  factory VideoGenerationResult.queued({
    required String jobId,
    required GeneratedVideo video,
    int? estimatedSeconds,
  }) => VideoGenerationResult(
    success: true,
    video: video,
    jobId: jobId,
    estimatedSeconds: estimatedSeconds,
  );

  factory VideoGenerationResult.failure(String error) =>
      VideoGenerationResult(success: false, error: error);
}

/// Abstract AI Video Service Interface
abstract class AIVideoService {
  /// Generate video from text prompt
  Future<VideoGenerationResult> generateVideo(VideoGenerationRequest request);

  /// Generate video from image (animate image)
  Future<VideoGenerationResult> animateImage({
    required String imageUrl,
    required int durationSeconds,
    VideoSize? size,
    String? motionPrompt,
  });

  /// Check status of a video generation job
  Future<VideoGenerationResult> checkJobStatus(String jobId);

  /// Enhance an existing video
  Future<VideoGenerationResult> enhanceVideo({
    required String videoUrl,
    bool? upscale,
    bool? stabilize,
    bool? enhanceColors,
  });

  /// Create slideshow video from images
  Future<VideoGenerationResult> createSlideshow({
    required List<String> imageUrls,
    required int secondsPerImage,
    String? transitionStyle,
    String? backgroundMusicId,
  });
}

/// Mock implementation for MVP
class MockAIVideoService implements AIVideoService {
  static const int _baseDelay = 3000;
  final Map<String, GeneratedVideo> _jobs = {};

  @override
  Future<VideoGenerationResult> generateVideo(
    VideoGenerationRequest request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final jobId = 'job_${DateTime.now().millisecondsSinceEpoch}';
    final video = GeneratedVideo(
      id: jobId,
      size: request.size,
      durationSeconds: request.durationSeconds,
      prompt: request.prompt,
      status: VideoGenerationStatus.queued,
      progress: 0,
      createdAt: DateTime.now(),
    );

    _jobs[jobId] = video;

    // Simulate async processing
    _simulateProcessing(jobId, request.durationSeconds);

    return VideoGenerationResult.queued(
      jobId: jobId,
      video: video,
      estimatedSeconds: request.durationSeconds * 10,
    );
  }

  void _simulateProcessing(String jobId, int duration) {
    Future.delayed(const Duration(seconds: 2), () {
      if (_jobs.containsKey(jobId)) {
        _jobs[jobId] = _jobs[jobId]!.copyWith(
          status: VideoGenerationStatus.processing,
          progress: 0.3,
        );
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (_jobs.containsKey(jobId)) {
        _jobs[jobId] = _jobs[jobId]!.copyWith(progress: 0.7);
      }
    });

    Future.delayed(const Duration(seconds: 6), () {
      if (_jobs.containsKey(jobId)) {
        _jobs[jobId] = _jobs[jobId]!.copyWith(
          status: VideoGenerationStatus.completed,
          progress: 1.0,
          url: 'mock_video_$jobId.mp4',
          thumbnailUrl: 'mock_thumb_$jobId.jpg',
        );
      }
    });
  }

  @override
  Future<VideoGenerationResult> checkJobStatus(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final video = _jobs[jobId];
    if (video == null) {
      return VideoGenerationResult.failure('Job not found');
    }

    return VideoGenerationResult.success(video: video, jobId: jobId);
  }

  @override
  Future<VideoGenerationResult> animateImage({
    required String imageUrl,
    required int durationSeconds,
    VideoSize? size,
    String? motionPrompt,
  }) async {
    await Future.delayed(Duration(milliseconds: _baseDelay));

    return VideoGenerationResult.success(
      video: GeneratedVideo(
        id: 'animated_${DateTime.now().millisecondsSinceEpoch}',
        url: 'animated_$imageUrl.mp4',
        thumbnailUrl: imageUrl,
        size: size ?? VideoSize.square,
        durationSeconds: durationSeconds,
        prompt: motionPrompt ?? 'Animated image',
        status: VideoGenerationStatus.completed,
        progress: 1.0,
        createdAt: DateTime.now(),
      ),
      creditsUsed: durationSeconds * 5,
    );
  }

  @override
  Future<VideoGenerationResult> enhanceVideo({
    required String videoUrl,
    bool? upscale,
    bool? stabilize,
    bool? enhanceColors,
  }) async {
    await Future.delayed(const Duration(milliseconds: 2000));

    return VideoGenerationResult.success(
      video: GeneratedVideo(
        id: 'enhanced_${DateTime.now().millisecondsSinceEpoch}',
        url: 'enhanced_$videoUrl',
        size: VideoSize.square,
        durationSeconds: 5,
        prompt: 'Enhanced video',
        status: VideoGenerationStatus.completed,
        progress: 1.0,
        createdAt: DateTime.now(),
      ),
      creditsUsed: 10,
    );
  }

  @override
  Future<VideoGenerationResult> createSlideshow({
    required List<String> imageUrls,
    required int secondsPerImage,
    String? transitionStyle,
    String? backgroundMusicId,
  }) async {
    await Future.delayed(Duration(milliseconds: 1000 * imageUrls.length));

    return VideoGenerationResult.success(
      video: GeneratedVideo(
        id: 'slideshow_${DateTime.now().millisecondsSinceEpoch}',
        url: 'slideshow_${imageUrls.length}images.mp4',
        size: VideoSize.landscape,
        durationSeconds: imageUrls.length * secondsPerImage,
        prompt: 'Slideshow with ${imageUrls.length} images',
        status: VideoGenerationStatus.completed,
        progress: 1.0,
        createdAt: DateTime.now(),
      ),
      creditsUsed: imageUrls.length * 3,
    );
  }
}

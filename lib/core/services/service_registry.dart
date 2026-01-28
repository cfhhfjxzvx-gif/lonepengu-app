/// Service Registry - Centralized service provider
/// BRD Section 5: API Integrations
///
/// Provides singleton access to all services
/// Easy to swap between mock and real implementations

import 'social_auth_service.dart';
import 'ai_text_service.dart';
import 'ai_image_service.dart';
import 'ai_video_service.dart';

/// Service registry for dependency injection
/// In production, consider using GetIt or Riverpod
class ServiceRegistry {
  static ServiceRegistry? _instance;

  // Service instances
  late final SocialAuthService socialAuth;
  late final AITextService aiText;
  late final AIImageService aiImage;
  late final AIVideoService aiVideo;

  // Private constructor
  ServiceRegistry._({
    required this.socialAuth,
    required this.aiText,
    required this.aiImage,
    required this.aiVideo,
  });

  /// Initialize with mock services (for MVP)
  static void initMock() {
    _instance = ServiceRegistry._(
      socialAuth: MockSocialAuthService(),
      aiText: MockAITextService(),
      aiImage: MockAIImageService(),
      aiVideo: MockAIVideoService(),
    );
  }

  /// Initialize with custom services (for production)
  static void init({
    required SocialAuthService socialAuth,
    required AITextService aiText,
    required AIImageService aiImage,
    required AIVideoService aiVideo,
  }) {
    _instance = ServiceRegistry._(
      socialAuth: socialAuth,
      aiText: aiText,
      aiImage: aiImage,
      aiVideo: aiVideo,
    );
  }

  /// Get the singleton instance
  static ServiceRegistry get instance {
    if (_instance == null) {
      initMock(); // Default to mock for MVP
    }
    return _instance!;
  }

  /// Check if initialized
  static bool get isInitialized => _instance != null;

  /// Reset (for testing)
  static void reset() {
    _instance = null;
  }
}

/// Convenience getters for services
SocialAuthService get socialAuthService => ServiceRegistry.instance.socialAuth;
AITextService get aiTextService => ServiceRegistry.instance.aiText;
AIImageService get aiImageService => ServiceRegistry.instance.aiImage;
AIVideoService get aiVideoService => ServiceRegistry.instance.aiVideo;

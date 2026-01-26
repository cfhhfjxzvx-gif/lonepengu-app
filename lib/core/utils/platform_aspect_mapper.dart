import '../../features/content_studio/data/content_models.dart';
import '../../features/editor/data/editor_models.dart';

class PlatformAspectMapper {
  /// Maps platform and content mode to a specific EditorAspectRatio
  static EditorAspectRatio mapToAspectRatio(
    SocialPlatform platform,
    ContentMode mode,
  ) {
    switch (platform) {
      case SocialPlatform.instagram:
        if (mode == ContentMode.video) {
          return EditorAspectRatio.igReel;
        }
        return EditorAspectRatio.igPost;

      case SocialPlatform.facebook:
        return EditorAspectRatio.fbPost;

      case SocialPlatform.linkedin:
        return EditorAspectRatio.linkedIn;

      case SocialPlatform.x:
        return EditorAspectRatio.xPost;
    }
  }

  /// Prioritizes a single platform from a list
  static SocialPlatform getPriorityPlatform(List<SocialPlatform> platforms) {
    if (platforms.isEmpty) return SocialPlatform.instagram;

    // Priority: Instagram > Facebook > LinkedIn > X
    if (platforms.contains(SocialPlatform.instagram))
      return SocialPlatform.instagram;
    if (platforms.contains(SocialPlatform.facebook))
      return SocialPlatform.facebook;
    if (platforms.contains(SocialPlatform.linkedin))
      return SocialPlatform.linkedin;
    if (platforms.contains(SocialPlatform.x)) return SocialPlatform.x;

    return platforms.first;
  }
}

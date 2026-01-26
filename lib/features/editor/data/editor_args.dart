import 'dart:typed_data';
import '../../content_studio/data/generated_asset.dart';
import '../../content_studio/data/content_models.dart';

class EditorArgs {
  final GeneratedAsset? asset;
  final ContentDraft? draft;
  final String? aspectPreset; // Must match EditorAspectRatio values
  final String? sourcePlatform;
  final String? promptText;
  final Uint8List? imageBytes;

  EditorArgs({
    this.asset,
    this.draft,
    this.aspectPreset,
    this.sourcePlatform,
    this.promptText,
    this.imageBytes,
  });
}

import 'dart:typed_data';

enum AssetType { image, carousel, video }

class GeneratedAsset {
  final String id;
  final AssetType type;
  final Uint8List? bytes;
  final String? filePath;
  final String? tempUrl;
  final DateTime createdAt;
  final String promptText;

  GeneratedAsset({
    required this.id,
    required this.type,
    this.bytes,
    this.filePath,
    this.tempUrl,
    required this.createdAt,
    required this.promptText,
  });
}

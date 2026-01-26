import 'package:flutter/material.dart';

enum LayerType { text, image, shape }

enum ShapeType { rectangle, circle }

enum EditorAspectRatio {
  igPost('Instagram Post', 1.0),
  igReel('Instagram Reel/Story', 9 / 16),
  fbPost('Facebook Post', 4 / 5),
  linkedIn('LinkedIn', 1.91 / 1),
  xPost('X/Twitter', 16 / 9);

  final String displayName;
  final double ratio;
  const EditorAspectRatio(this.displayName, this.ratio);
}

class EditorLayer {
  final String id;
  final LayerType type;

  // Transformation
  Offset position;
  double scale;
  double rotation;
  double opacity;
  bool isLocked;

  // Content
  String? text;
  ShapeType? shapeType;
  Color color;

  // Styling
  double? fontSize;
  FontWeight? fontWeight;
  TextAlign? textAlign;

  // Image handling
  String? imagePath; // Mobile
  dynamic imageBytes; // Web/Memory
  String? imageUrl; // Remote URL

  EditorLayer({
    required this.id,
    required this.type,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
    this.isLocked = false,
    this.text,
    this.shapeType,
    this.color = Colors.blue,
    this.fontSize = 24.0,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.center,
    this.imagePath,
    this.imageBytes,
    this.imageUrl,
  });

  EditorLayer copyWith({
    String? id,
    LayerType? type,
    Offset? position,
    double? scale,
    double? rotation,
    double? opacity,
    bool? isLocked,
    String? text,
    ShapeType? shapeType,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    String? imagePath,
    dynamic imageBytes,
    String? imageUrl,
  }) {
    return EditorLayer(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      isLocked: isLocked ?? this.isLocked,
      text: text ?? this.text,
      shapeType: shapeType ?? this.shapeType,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      textAlign: textAlign ?? this.textAlign,
      imagePath: imagePath ?? this.imagePath,
      imageBytes: imageBytes ?? this.imageBytes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'x': position.dx,
      'y': position.dy,
      'scale': scale,
      'rotation': rotation,
      'opacity': opacity,
      'isLocked': isLocked,
      'text': text,
      'shapeType': shapeType?.index,
      'color': color.value,
      'fontSize': fontSize,
      'fontWeight': fontWeight?.index,
      'textAlign': textAlign?.index,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
    };
  }

  factory EditorLayer.fromJson(Map<String, dynamic> json) {
    return EditorLayer(
      id: json['id'] as String,
      type: LayerType.values[json['type'] as int],
      position: Offset(json['x'] as double, json['y'] as double),
      scale: (json['scale'] as num).toDouble(),
      rotation: (json['rotation'] as num).toDouble(),
      opacity: (json['opacity'] as num).toDouble(),
      isLocked: json['isLocked'] as bool? ?? false,
      text: json['text'] as String?,
      shapeType: json['shapeType'] != null
          ? ShapeType.values[json['shapeType'] as int]
          : null,
      color: Color(json['color'] as int),
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      fontWeight: json['fontWeight'] != null
          ? FontWeight.values[json['fontWeight'] as int]
          : null,
      textAlign: json['textAlign'] != null
          ? TextAlign.values[json['textAlign'] as int]
          : null,
      imagePath: json['imagePath'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class EditorTemplate {
  final String id;
  final String name;
  final List<EditorLayer> layers;
  final EditorAspectRatio aspectRatio;
  final String? previewImage;

  const EditorTemplate({
    required this.id,
    required this.name,
    required this.layers,
    this.aspectRatio = EditorAspectRatio.igPost,
    this.previewImage,
  });
}

class EditorProjectState {
  final List<EditorLayer> layers;
  final EditorAspectRatio aspectRatio;

  EditorProjectState({
    required this.layers,
    this.aspectRatio = EditorAspectRatio.igPost,
  });

  Map<String, dynamic> toJson() => {
    'layers': layers.map((e) => e.toJson()).toList(),
    'aspectRatio': aspectRatio.index,
  };

  factory EditorProjectState.fromJson(Map<String, dynamic> json) {
    return EditorProjectState(
      layers: (json['layers'] as List)
          .map((e) => EditorLayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      aspectRatio: EditorAspectRatio.values[json['aspectRatio'] as int],
    );
  }
}

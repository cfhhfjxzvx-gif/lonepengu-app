import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/editor_models.dart';

class LayerWidget extends StatelessWidget {
  final EditorLayer layer;
  final bool isSelected;
  final Function(Offset delta) onDrag;
  final VoidCallback onTap;

  const LayerWidget({
    super.key,
    required this.layer,
    required this.isSelected,
    required this.onDrag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: layer.position.dx,
      top: layer.position.dy,
      child: GestureDetector(
        onTap: onTap,
        onPanUpdate: layer.isLocked ? null : (details) => onDrag(details.delta),
        child: Transform.rotate(
          angle: layer.rotation,
          child: Transform.scale(
            scale: layer.scale,
            child: Opacity(
              opacity: layer.opacity,
              child: Container(
                decoration: BoxDecoration(
                  border: isSelected
                      ? Border.all(color: Colors.blueAccent, width: 2)
                      : null,
                ),
                padding: const EdgeInsets.all(4),
                child: _buildLayerContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayerContent() {
    switch (layer.type) {
      case LayerType.text:
        return Text(
          layer.text ?? 'Double tap to edit',
          textAlign: layer.textAlign,
          style: TextStyle(
            fontSize: layer.fontSize,
            fontWeight: layer.fontWeight,
            color: layer.color,
          ),
        );
      case LayerType.shape:
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: layer.color,
            shape: layer.shapeType == ShapeType.circle
                ? BoxShape.circle
                : BoxShape.rectangle,
          ),
        );
      case LayerType.image:
        return SizedBox(width: 150, height: 150, child: _buildImageContent());
    }
  }

  Widget _buildImageContent() {
    Widget image;

    if (layer.imageBytes != null) {
      image = Image.memory(layer.imageBytes!, fit: BoxFit.cover);
    } else if (layer.imagePath != null && !kIsWeb) {
      image = Image.file(File(layer.imagePath!), fit: BoxFit.cover);
    } else if (layer.imageUrl != null) {
      image = Image.network(
        layer.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (_, __, ___) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.red),
              Text('Image not available', style: TextStyle(fontSize: 8)),
            ],
          ),
        ),
      );
    } else {
      image = const Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey),
      );
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: 1.0,
      child: image,
    );
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/design/lp_design.dart';
import '../../data/editor_models.dart';

class LayerWidget extends StatefulWidget {
  final EditorLayer layer;
  final bool isSelected;
  final Function(Offset delta) onDrag;
  final Function(double scale, double rotation) onScaleRotate;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  const LayerWidget({
    super.key,
    required this.layer,
    required this.isSelected,
    required this.onDrag,
    required this.onScaleRotate,
    required this.onTap,
    required this.onDoubleTap,
  });

  @override
  State<LayerWidget> createState() => _LayerWidgetState();
}

class _LayerWidgetState extends State<LayerWidget> {
  double _baseScale = 1.0;
  double _baseRotation = 0.0;

  @override
  Widget build(BuildContext context) {
    // If locked, just show content without interaction
    if (widget.layer.isLocked) {
      return Positioned(
        left: widget.layer.position.dx,
        top: widget.layer.position.dy,
        child: Transform.rotate(
          angle: widget.layer.rotation,
          child: Transform.scale(
            scale: widget.layer.scale,
            child: Opacity(
              opacity: widget.layer.opacity,
              child: _buildLayerContent(),
            ),
          ),
        ),
      );
    }

    return Positioned(
      left: widget.layer.position.dx,
      top: widget.layer.position.dy,
      child: GestureDetector(
        onTap: () {
          if (widget.isSelected) {
            widget.onDoubleTap();
          } else {
            widget.onTap();
          }
        },
        onDoubleTap: widget.onDoubleTap,
        onScaleStart: (details) {
          _baseScale = widget.layer.scale;
          _baseRotation = widget.layer.rotation;
          if (!widget.isSelected) {
            widget.onTap(); // Select on start interaction if not selected
          }
        },
        onScaleUpdate: (details) {
          // 1. Handle Dragging (Translation)
          widget.onDrag(details.focalPointDelta);

          // 2. Handle Scaling & Rotation (if multi-touch or dedicated mode)
          // details.scale is 1.0 if only 1 finger.
          if (details.scale != 1.0 || details.rotation != 0.0) {
            widget.onScaleRotate(
              _baseScale * details.scale,
              _baseRotation + details.rotation,
            );
          }
        },
        child: Transform.rotate(
          angle: widget.layer.rotation,
          child: Transform.scale(
            scale: widget.layer.scale,
            child: Opacity(
              opacity: widget.layer.opacity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // CONTENT
                  Container(
                    decoration: BoxDecoration(
                      border: widget.isSelected
                          ? Border.all(color: LPColors.secondary, width: 2)
                          : Border.all(
                              color: Colors.transparent,
                              width: 2,
                            ), // Invisible border to keep size
                    ),
                    padding: const EdgeInsets.all(8), // Touch target padding
                    child: _buildLayerContent(),
                  ),

                  // HANDLES (Visual only for now, can be functional later)
                  if (widget.isSelected) ...[
                    _buildHandle(Alignment.topLeft),
                    _buildHandle(Alignment.topRight),
                    _buildHandle(Alignment.bottomLeft),
                    _buildHandle(Alignment.bottomRight),
                    // Rotation Handle
                    Positioned(
                      top: -24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: LPColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandle(Alignment alignment) {
    // Position handles relative to the content container
    // This is a simplified visual representation
    return Positioned(
      left: alignment.x == -1 ? -4 : null,
      right: alignment.x == 1 ? -4 : null,
      top: alignment.y == -1 ? -4 : null,
      bottom: alignment.y == 1 ? -4 : null,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: LPColors.secondary),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildLayerContent() {
    switch (widget.layer.type) {
      case LayerType.text:
        return Text(
          widget.layer.text ?? 'Double tap to edit',
          textAlign: widget.layer.textAlign,
          style: TextStyle(
            fontFamily: widget.layer.fontFamily,
            fontSize: widget.layer.fontSize,
            fontWeight: widget.layer.fontWeight,
            color: widget.layer.color,
          ),
        );
      case LayerType.shape:
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: widget.layer.color,
            shape: widget.layer.shapeType == ShapeType.circle
                ? BoxShape.circle
                : BoxShape.rectangle,
            borderRadius: widget.layer.shapeType == ShapeType.rectangle
                ? BorderRadius.circular(8)
                : null,
          ),
        );
      case LayerType.image:
        return SizedBox(
          width: 200, // Base size
          child: AspectRatio(
            aspectRatio: 1, // Start square, but content fits
            child: _buildImageContent(),
          ),
        );
    }
  }

  Widget _buildImageContent() {
    Widget image;

    if (widget.layer.imageBytes != null) {
      image = Image.memory(widget.layer.imageBytes!, fit: BoxFit.contain);
    } else if (widget.layer.imagePath != null && !kIsWeb) {
      image = Image.file(File(widget.layer.imagePath!), fit: BoxFit.contain);
    } else if (widget.layer.imageUrl != null) {
      image = Image.network(
        widget.layer.imageUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image, color: Colors.red)),
      );
    } else {
      image = const Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey),
      );
    }

    return image;
  }
}

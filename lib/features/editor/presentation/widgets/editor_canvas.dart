import 'package:flutter/material.dart';
import '../../../../core/design/lp_design.dart';
import '../../data/editor_models.dart';
import 'layer_widget.dart';

/// Editor canvas widget
/// NOTE: The canvas background is intentionally WHITE in both modes
/// because it represents the actual post content that will be exported
/// The white background is the "paper" - it's correct to be white
class EditorCanvas extends StatelessWidget {
  final List<EditorLayer> layers;
  final EditorAspectRatio aspectRatio;
  final String? selectedLayerId;
  final Function(String layerId) onLayerSelected;
  final Function(String layerId, Offset delta) onLayerDragged;

  const EditorCanvas({
    super.key,
    required this.layers,
    required this.aspectRatio,
    required this.selectedLayerId,
    required this.onLayerSelected,
    required this.onLayerDragged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the maximum possible size for the canvas based on constraints
        double maxWidth = constraints.maxWidth;
        double maxHeight = constraints.maxHeight;

        double canvasWidth, canvasHeight;

        if (maxWidth / maxHeight > aspectRatio.ratio) {
          // Limited by height
          canvasHeight = maxHeight;
          canvasWidth = maxHeight * aspectRatio.ratio;
        } else {
          // Limited by width
          canvasWidth = maxWidth;
          canvasHeight = maxWidth / aspectRatio.ratio;
        }

        return Center(
          child: Container(
            width: canvasWidth,
            height: canvasHeight,
            decoration: BoxDecoration(
              // Canvas is WHITE because it's the actual content being created
              // This is intentional - it's the "paper" for the post
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              // Border to show canvas boundaries in dark mode
              border: isDark
                  ? Border.all(color: LPColors.borderDark, width: 1)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: layers.map((layer) {
                return LayerWidget(
                  layer: layer,
                  isSelected: layer.id == selectedLayerId,
                  onDrag: (delta) => onLayerDragged(layer.id, delta),
                  onTap: () => onLayerSelected(layer.id),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

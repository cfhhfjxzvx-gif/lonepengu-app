import 'package:flutter/material.dart';
import '../../data/editor_models.dart';

class StylePanel extends StatelessWidget {
  final EditorLayer? selectedLayer;
  final Function(EditorLayer updatedLayer) onUpdateLayer;

  const StylePanel({
    super.key,
    required this.selectedLayer,
    required this.onUpdateLayer,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedLayer == null) {
      return const Center(
        child: Text(
          'Select a layer to edit its style',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Style: ${selectedLayer!.type.name.toUpperCase()}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(height: 24),

          // Shared Properties
          _buildSlider(
            label: 'Opacity',
            value: selectedLayer!.opacity,
            onChanged: (v) =>
                onUpdateLayer(selectedLayer!.copyWith(opacity: v)),
          ),

          _buildSlider(
            label: 'Rotation',
            value: selectedLayer!.rotation,
            min: -3.14,
            max: 3.14,
            onChanged: (v) =>
                onUpdateLayer(selectedLayer!.copyWith(rotation: v)),
          ),

          _buildSlider(
            label: 'Scale',
            value: selectedLayer!.scale,
            min: 0.1,
            max: 5.0,
            onChanged: (v) => onUpdateLayer(selectedLayer!.copyWith(scale: v)),
          ),

          if (selectedLayer!.type == LayerType.text)
            ..._buildTextStyles(context),
          if (selectedLayer!.type == LayerType.shape)
            ..._buildShapeStyles(context),
        ],
      ),
    );
  }

  List<Widget> _buildTextStyles(BuildContext context) {
    return [
      const SizedBox(height: 16),
      const Text('Font Size', style: TextStyle(fontWeight: FontWeight.w600)),
      Slider(
        value: selectedLayer!.fontSize ?? 24.0,
        min: 12,
        max: 120,
        onChanged: (v) => onUpdateLayer(selectedLayer!.copyWith(fontSize: v)),
      ),
      const SizedBox(height: 16),
      const Text('Align', style: TextStyle(fontWeight: FontWeight.w600)),
      Row(
        children: [
          _buildIconButton(Icons.format_align_left, TextAlign.left),
          _buildIconButton(Icons.format_align_center, TextAlign.center),
          _buildIconButton(Icons.format_align_right, TextAlign.right),
        ],
      ),
      const SizedBox(height: 16),
      const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
      _buildColorPalette(),
    ];
  }

  List<Widget> _buildShapeStyles(BuildContext context) {
    return [
      const SizedBox(height: 16),
      const Text('Fill Color', style: TextStyle(fontWeight: FontWeight.w600)),
      _buildColorPalette(),
    ];
  }

  Widget _buildIconButton(IconData icon, TextAlign align) {
    final isSelected = selectedLayer!.textAlign == align;
    return IconButton(
      icon: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
      onPressed: () => onUpdateLayer(selectedLayer!.copyWith(textAlign: align)),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    double min = 0.0,
    double max = 1.0,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  Widget _buildColorPalette() {
    final colors = [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final isSelected = selectedLayer!.color.value == color.value;
        return GestureDetector(
          onTap: () => onUpdateLayer(selectedLayer!.copyWith(color: color)),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

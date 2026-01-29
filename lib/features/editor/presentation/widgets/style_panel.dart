import 'package:flutter/material.dart';
import '../../data/editor_models.dart';
import '../../../brand_kit/domain/brand_kit_model.dart';

class StylePanel extends StatelessWidget {
  final EditorLayer? selectedLayer;
  final Function(EditorLayer updatedLayer) onUpdateLayer;
  final BrandKit? brandKit;

  const StylePanel({
    super.key,
    required this.selectedLayer,
    required this.onUpdateLayer,
    this.brandKit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (selectedLayer == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.layers_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a layer to edit its style',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getLayerIcon(selectedLayer!.type),
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Style: ${selectedLayer!.type.name.toUpperCase()}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 24),

          // Shared Properties
          _buildSlider(
            context,
            label: 'Opacity',
            value: selectedLayer!.opacity,
            onChanged: (v) =>
                onUpdateLayer(selectedLayer!.copyWith(opacity: v)),
          ),
          const SizedBox(height: 16),

          _buildSlider(
            context,
            label: 'Rotation',
            value: selectedLayer!.rotation,
            min: -3.14,
            max: 3.14,
            onChanged: (v) =>
                onUpdateLayer(selectedLayer!.copyWith(rotation: v)),
          ),
          const SizedBox(height: 16),

          _buildSlider(
            context,
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

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  IconData _getLayerIcon(LayerType type) {
    switch (type) {
      case LayerType.text:
        return Icons.title_rounded;
      case LayerType.image:
        return Icons.image_outlined;
      case LayerType.shape:
        return Icons.category_outlined;
    }
  }

  List<Widget> _buildTextStyles(BuildContext context) {
    final theme = Theme.of(context);
    return [
      const SizedBox(height: 24),
      const SizedBox(height: 24),
      Text(
        'Typography',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),

      // Font Family Selector
      _buildFontFamilySelector(context),
      const SizedBox(height: 16),

      Text(
        'Font Size',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      Slider(
        value: selectedLayer!.fontSize ?? 24.0,
        min: 12,
        max: 120,
        activeColor: theme.colorScheme.primary,
        inactiveColor: theme.colorScheme.surfaceContainerHighest,
        onChanged: (v) => onUpdateLayer(selectedLayer!.copyWith(fontSize: v)),
      ),
      const SizedBox(height: 24),
      Text(
        'Text Alignment',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          _buildAlignmentButton(
            context,
            Icons.format_align_left_rounded,
            TextAlign.left,
          ),
          const SizedBox(width: 8),
          _buildAlignmentButton(
            context,
            Icons.format_align_center_rounded,
            TextAlign.center,
          ),
          const SizedBox(width: 8),
          _buildAlignmentButton(
            context,
            Icons.format_align_right_rounded,
            TextAlign.right,
          ),
        ],
      ),
      const SizedBox(height: 24),
      Text(
        'Text Color',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      _buildColorPalette(context),
    ];
  }

  List<Widget> _buildShapeStyles(BuildContext context) {
    final theme = Theme.of(context);
    return [
      const SizedBox(height: 24),
      Text(
        'Fill Color',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      _buildColorPalette(context),
    ];
  }

  Widget _buildAlignmentButton(
    BuildContext context,
    IconData icon,
    TextAlign align,
  ) {
    final theme = Theme.of(context);
    final isSelected = selectedLayer!.textAlign == align;

    return InkWell(
      onTap: () => onUpdateLayer(selectedLayer!.copyWith(textAlign: align)),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context, {
    required String label,
    required double value,
    double min = 0.0,
    double max = 1.0,
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value.toStringAsFixed(2),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.surfaceContainerHighest,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildColorPalette(BuildContext context) {
    final theme = Theme.of(context);
    final presetColors = [
      Colors.black,
      Colors.white,
      Colors.redAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.tealAccent,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (brandKit != null) ...[
          Text(
            'Brand Colors',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildColorCircle(context, brandKit!.colors.primary, 'Primary'),
              _buildColorCircle(
                context,
                brandKit!.colors.secondary,
                'Secondary',
              ),
              _buildColorCircle(context, brandKit!.colors.accent, 'Accent'),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Presets',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: presetColors
              .map((color) => _buildColorCircle(context, color, ''))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildColorCircle(BuildContext context, Color color, String label) {
    final theme = Theme.of(context);
    final isSelected = selectedLayer!.color.toARGB32() == color.toARGB32();

    return GestureDetector(
      onTap: () => onUpdateLayer(selectedLayer!.copyWith(color: color)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 20,
                      color: _getContrastColor(color),
                    ),
                  )
                : null,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFontFamilySelector(BuildContext context) {
    final theme = Theme.of(context);
    final currentFont = selectedLayer!.fontFamily;

    // Available fonts
    final Map<String, String> fonts = {
      'App Default': '',
      'Serif': 'serif',
      'Monospace': 'monospace',
      'Cursive': 'cursive',
    };

    // Add Brand Kit fonts if available
    if (brandKit != null) {
      if (brandKit!.headingFont.isNotEmpty) {
        fonts['Brand Heading (${brandKit!.headingFont})'] =
            brandKit!.headingFont;
      }
      if (brandKit!.bodyFont.isNotEmpty) {
        fonts['Brand Body (${brandKit!.bodyFont})'] = brandKit!.bodyFont;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: fonts.containsValue(currentFont) ? currentFont : '',
          isExpanded: true,
          hint: const Text('Select Font'),
          items: fonts.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.value,
              child: Text(
                entry.key,
                style: TextStyle(
                  fontFamily: entry.value.isEmpty ? null : entry.value,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            onUpdateLayer(selectedLayer!.copyWith(fontFamily: value));
          },
        ),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

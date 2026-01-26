import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/brand_kit_model.dart';

/// Color swatch picker widget
class ColorSwatchPicker extends StatelessWidget {
  final String label;
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  const ColorSwatchPicker({
    super.key,
    required this.label,
    required this.selectedColor,
    required this.onColorChanged,
  });

  static const List<Color> presetColors = [
    Color(0xFF1E3A5F), // Arctic Blue
    Color(0xFF1A1A2E), // Penguin Black
    Color(0xFF14B8A6), // Aurora Teal
    Color(0xFF8B5CF6), // Frost Purple
    Color(0xFFF43F5E), // Sunset Coral
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF6366F1), // Indigo
    Color(0xFF84CC16), // Lime
    Color(0xFF06B6D4), // Cyan
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showColorPicker(context),
      child: AnimatedContainer(
        duration: AppConstants.shortDuration,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.iceWhite,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            // Color preview
            AnimatedContainer(
              duration: AppConstants.shortDuration,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selectedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.grey300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Label and hex value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.penguinBlack,
                    ),
                  ),
                  Text(
                    selectedColor.toHex(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey500,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, size: 18, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final hexController = TextEditingController(text: selectedColor.toHex());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.iceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              'Choose $label',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            // Preset colors grid
            Text(
              'Preset Colors',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.grey600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: presetColors.map((color) {
                final isSelected = color.toARGB32() == selectedColor.toARGB32();
                return GestureDetector(
                  onTap: () {
                    onColorChanged(color);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: AppConstants.shortDuration,
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.penguinBlack
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: isSelected ? 12 : 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Hex input
            Text(
              'Custom Color (Hex)',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.grey600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hexController,
                    decoration: InputDecoration(
                      hintText: '#1E3A5F',
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 7,
                    buildCounter:
                        (
                          _, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) => null,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final hex = hexController.text;
                    if (hex.startsWith('#') && hex.length == 7) {
                      try {
                        final color = HexColor.fromHex(hex);
                        onColorChanged(color);
                        Navigator.pop(context);
                      } catch (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid hex color')),
                        );
                      }
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

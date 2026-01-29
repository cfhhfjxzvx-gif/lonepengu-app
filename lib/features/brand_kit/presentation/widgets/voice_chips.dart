import 'package:flutter/material.dart';
import '../../domain/brand_kit_model.dart';

/// Voice tone selection chips
class VoiceChips extends StatelessWidget {
  final String selectedTone;
  final ValueChanged<String> onToneChanged;

  const VoiceChips({
    super.key,
    required this.selectedTone,
    required this.onToneChanged,
  });

  IconData _getIconForTone(String tone) {
    switch (tone) {
      case 'Professional':
        return Icons.business_center_outlined;
      case 'Friendly':
        return Icons.emoji_emotions_outlined;
      case 'Bold':
        return Icons.flash_on_outlined;
      case 'Minimal':
        return Icons.space_bar_rounded;
      case 'Funny':
        return Icons.sentiment_very_satisfied_outlined;
      case 'Luxury':
        return Icons.diamond_outlined;
      default:
        return Icons.chat_outlined;
    }
  }

  Color _getColorForTone(BuildContext context, String tone) {
    final theme = Theme.of(context);
    switch (tone) {
      case 'Professional':
        return theme.colorScheme.primary;
      case 'Friendly':
        return theme.colorScheme.tertiary;
      case 'Bold':
        return theme.colorScheme.error;
      case 'Minimal':
        return theme.colorScheme.onSurfaceVariant;
      case 'Funny':
        return const Color(0xFFF59E0B);
      case 'Luxury':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: VoiceTones.all.map((tone) {
        final isSelected = tone == selectedTone;
        final color = _getColorForTone(context, tone);

        return GestureDetector(
          onTap: () => onToneChanged(tone),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color
                  : (isDark
                        ? theme.colorScheme.surfaceContainerLow
                        : theme.colorScheme.surface),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : theme.colorScheme.outlineVariant,
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconForTone(tone),
                  size: 20,
                  color: isSelected ? Colors.white : color,
                ),
                const SizedBox(width: 8),
                Text(
                  tone,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Formality slider widget
class FormalitySlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const FormalitySlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Formal',
              style: theme.textTheme.labelSmall?.copyWith(
                color: value < 0.5
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: value < 0.5 ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            Text(
              'Casual',
              style: theme.textTheme.labelSmall?.copyWith(
                color: value > 0.5
                    ? theme.colorScheme.tertiary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: value > 0.5 ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            valueIndicatorShape: const RectangularSliderValueIndicatorShape(),
            valueIndicatorColor: theme.colorScheme.primary,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Slider(value: value, onChanged: onChanged, min: 0, max: 1),
        ),
      ],
    );
  }
}

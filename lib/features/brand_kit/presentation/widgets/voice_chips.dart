import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
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
        return Icons.space_bar;
      case 'Funny':
        return Icons.sentiment_very_satisfied_outlined;
      case 'Luxury':
        return Icons.diamond_outlined;
      default:
        return Icons.chat_outlined;
    }
  }

  Color _getColorForTone(String tone) {
    switch (tone) {
      case 'Professional':
        return AppColors.arcticBlue;
      case 'Friendly':
        return AppColors.auroraTeal;
      case 'Bold':
        return AppColors.sunsetCoral;
      case 'Minimal':
        return AppColors.grey600;
      case 'Funny':
        return const Color(0xFFF59E0B);
      case 'Luxury':
        return AppColors.frostPurple;
      default:
        return AppColors.arcticBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: VoiceTones.all.map((tone) {
        final isSelected = tone == selectedTone;
        final color = _getColorForTone(tone);

        return GestureDetector(
          onTap: () => onToneChanged(tone),
          child: AnimatedContainer(
            duration: AppConstants.shortDuration,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color : AppColors.iceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : AppColors.grey300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconForTone(tone),
                  size: 18,
                  color: isSelected ? AppColors.iceWhite : color,
                ),
                const SizedBox(width: 6),
                Text(
                  tone,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.iceWhite : AppColors.grey700,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Formal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: value < 0.5 ? AppColors.arcticBlue : AppColors.grey500,
                fontWeight: value < 0.5 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            Text(
              'Casual',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: value > 0.5 ? AppColors.auroraTeal : AppColors.grey500,
                fontWeight: value > 0.5 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.arcticBlue,
            inactiveTrackColor: AppColors.grey200,
            thumbColor: AppColors.arcticBlue,
            overlayColor: AppColors.arcticBlue.withValues(alpha: 0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(value: value, onChanged: onChanged, min: 0, max: 1),
        ),
      ],
    );
  }
}

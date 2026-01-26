import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/content_models.dart';

/// Platform selection chips (multi-select)
class PlatformChips extends StatelessWidget {
  final List<SocialPlatform> selected;
  final ValueChanged<List<SocialPlatform>> onChanged;

  const PlatformChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SocialPlatform.values.map((platform) {
        final isSelected = selected.contains(platform);
        return GestureDetector(
          onTap: () {
            final newSelected = List<SocialPlatform>.from(selected);
            if (isSelected) {
              newSelected.remove(platform);
            } else {
              newSelected.add(platform);
            }
            onChanged(newSelected);
          },
          child: AnimatedContainer(
            duration: AppConstants.shortDuration,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? _getPlatformColor(platform)
                  : AppColors.iceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? _getPlatformColor(platform)
                    : AppColors.grey300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _getPlatformColor(
                          platform,
                        ).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(platform.icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  platform.displayName,
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

  Color _getPlatformColor(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.instagram:
        return const Color(0xFFE1306C);
      case SocialPlatform.facebook:
        return const Color(0xFF1877F2);
      case SocialPlatform.linkedin:
        return const Color(0xFF0A66C2);
      case SocialPlatform.x:
        return AppColors.penguinBlack;
    }
  }
}

/// Tone selection chips (single select)
class ToneChips extends StatelessWidget {
  final ContentTone selected;
  final ValueChanged<ContentTone> onChanged;

  const ToneChips({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ContentTone.values.map((tone) {
        final isSelected = tone == selected;
        return GestureDetector(
          onTap: () => onChanged(tone),
          child: AnimatedContainer(
            duration: AppConstants.shortDuration,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.arcticBlue : AppColors.iceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.arcticBlue : AppColors.grey300,
              ),
            ),
            child: Text(
              tone.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.iceWhite : AppColors.grey700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Length selection chips
class LengthChips extends StatelessWidget {
  final ContentLength selected;
  final ValueChanged<ContentLength> onChanged;

  const LengthChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ContentLength.values.map((length) {
        final isSelected = length == selected;
        return GestureDetector(
          onTap: () => onChanged(length),
          child: AnimatedContainer(
            duration: AppConstants.shortDuration,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.auroraTeal : AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              length.displayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.iceWhite : AppColors.grey600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Image style chips
class ImageStyleChips extends StatelessWidget {
  final ImageStyle selected;
  final ValueChanged<ImageStyle> onChanged;

  const ImageStyleChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ImageStyle.values.map((style) {
        final isSelected = style == selected;
        return GestureDetector(
          onTap: () => onChanged(style),
          child: AnimatedContainer(
            duration: AppConstants.shortDuration,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.frostPurple : AppColors.iceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.frostPurple : AppColors.grey300,
              ),
            ),
            child: Text(
              style.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.iceWhite : AppColors.grey700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Aspect ratio chips
class AspectRatioChips extends StatelessWidget {
  final AppAspectRatio selected;
  final ValueChanged<AppAspectRatio> onChanged;

  const AspectRatioChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppAspectRatio.values.map((ratio) {
        final isSelected = ratio == selected;
        return GestureDetector(
          onTap: () => onChanged(ratio),
          child: AnimatedContainer(
            duration: AppConstants.shortDuration,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.arcticBlue : AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.arcticBlue : AppColors.grey300,
              ),
            ),
            child: Text(
              ratio.displayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.iceWhite : AppColors.grey600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Carousel style chips
class CarouselStyleChips extends StatelessWidget {
  final CarouselStyle selected;
  final ValueChanged<CarouselStyle> onChanged;

  const CarouselStyleChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: CarouselStyle.values.map((style) {
        final isSelected = style == selected;
        return GestureDetector(
          onTap: () => onChanged(style),
          child: AnimatedContainer(
            duration: AppConstants.shortDuration,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.sunsetCoral : AppColors.iceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.sunsetCoral : AppColors.grey300,
              ),
            ),
            child: Text(
              style.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.iceWhite : AppColors.grey700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Video duration chips
class VideoDurationChips extends StatelessWidget {
  final VideoDuration selected;
  final ValueChanged<VideoDuration> onChanged;

  const VideoDurationChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: VideoDuration.values.map((duration) {
        final isSelected = duration == selected;
        return GestureDetector(
          onTap: () => onChanged(duration),
          child: AnimatedContainer(
            duration: AppConstants.shortDuration,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.arcticBlue : AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              duration.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.iceWhite : AppColors.grey600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Video style chips
class VideoStyleChips extends StatelessWidget {
  final VideoStyle selected;
  final ValueChanged<VideoStyle> onChanged;

  const VideoStyleChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: VideoStyle.values.map((style) {
        final isSelected = style == selected;
        return GestureDetector(
          onTap: () => onChanged(style),
          child: AnimatedContainer(
            duration: AppConstants.shortDuration,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.frostPurple : AppColors.iceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.frostPurple : AppColors.grey300,
              ),
            ),
            child: Text(
              style.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.iceWhite : AppColors.grey700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

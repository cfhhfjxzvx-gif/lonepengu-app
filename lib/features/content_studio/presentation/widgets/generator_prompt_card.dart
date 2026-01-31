import 'package:lone_pengu/core/design/lp_design.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/content_models.dart';
import '../../data/intent_detector.dart';
import 'selection_chips.dart';

/// Generator prompt card with all input options
/// Theme-aware: adapts to light/dark mode
class GeneratorPromptCard extends StatelessWidget {
  final ContentMode mode;
  final TextEditingController promptController;
  final String? selectedIndustry;
  final ContentGoal selectedGoal;
  final List<SocialPlatform> selectedPlatforms;
  final ContentTone selectedTone;
  final ContentLength selectedLength;
  final CtaType selectedCta;

  // Image mode
  final ImageStyle selectedImageStyle;
  final AppAspectRatio selectedAspectRatio;

  // Carousel mode
  final int slideCount;
  final CarouselStyle selectedCarouselStyle;

  // Video mode
  final VideoDuration selectedDuration;
  final VideoStyle selectedVideoStyle;

  // Auto mode
  final IntentDetectionResult? detectedIntent;

  // Callbacks
  final ValueChanged<String?> onIndustryChanged;
  final ValueChanged<ContentGoal> onGoalChanged;
  final ValueChanged<List<SocialPlatform>> onPlatformsChanged;
  final ValueChanged<ContentTone> onToneChanged;
  final ValueChanged<ContentLength> onLengthChanged;
  final ValueChanged<CtaType> onCtaChanged;
  final ValueChanged<ImageStyle> onImageStyleChanged;
  final ValueChanged<AppAspectRatio> onAspectRatioChanged;
  final ValueChanged<int> onSlideCountChanged;
  final ValueChanged<CarouselStyle> onCarouselStyleChanged;
  final ValueChanged<VideoDuration> onDurationChanged;
  final ValueChanged<VideoStyle> onVideoStyleChanged;
  final VoidCallback onGenerate;
  final VoidCallback onSurprise;
  final ValueChanged<ContentMode>? onIntentChanged;
  final bool isGenerating;

  const GeneratorPromptCard({
    super.key,
    required this.mode,
    required this.promptController,
    required this.selectedIndustry,
    required this.selectedGoal,
    required this.selectedPlatforms,
    required this.selectedTone,
    required this.selectedLength,
    required this.selectedCta,
    required this.selectedImageStyle,
    required this.selectedAspectRatio,
    required this.slideCount,
    required this.selectedCarouselStyle,
    required this.selectedDuration,
    required this.selectedVideoStyle,
    required this.onIndustryChanged,
    required this.onGoalChanged,
    required this.onPlatformsChanged,
    required this.onToneChanged,
    required this.onLengthChanged,
    required this.onCtaChanged,
    required this.onImageStyleChanged,
    required this.onAspectRatioChanged,
    required this.onSlideCountChanged,
    required this.onCarouselStyleChanged,
    required this.onDurationChanged,
    required this.onVideoStyleChanged,
    required this.onGenerate,
    required this.onSurprise,
    this.detectedIntent,
    this.onIntentChanged,
    this.isGenerating = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Theme-aware colors
    final cardBgColor = isDark ? LPColors.cardDark : LPColors.surface;
    final inputFillColor = isDark ? LPColors.surfaceDark : LPColors.grey100;
    final borderColor = isDark ? LPColors.borderDark : LPColors.grey200;
    final textColor = colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: LPColors.textPrimary.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prompt input
          _buildSectionTitle(context, 'What are you posting about?'),
          const SizedBox(height: 8),
          TextField(
            controller: promptController,
            maxLines: 3,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Describe your post idea...',
              hintStyle: TextStyle(
                color: isDark
                    ? LPColors.textSecondaryDark
                    : LPColors.textSecondary,
              ),
              filled: true,
              fillColor: inputFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Row with Industry and Goal dropdowns
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 400;
              final children = [
                Expanded(
                  flex: isNarrow ? 0 : 1,
                  child: _buildDropdown<String?>(
                    context,
                    'Industry',
                    selectedIndustry,
                    [null, ...Industries.all],
                    (v) => v ?? 'Select...',
                    onIndustryChanged,
                  ),
                ),
                SizedBox(width: isNarrow ? 0 : 12, height: isNarrow ? 12 : 0),
                Expanded(
                  flex: isNarrow ? 0 : 1,
                  child: _buildDropdown<ContentGoal>(
                    context,
                    'Goal',
                    selectedGoal,
                    ContentGoal.values,
                    (v) => v.displayName,
                    onGoalChanged,
                  ),
                ),
              ];

              return isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    )
                  : Row(children: children);
            },
          ),
          const SizedBox(height: 16),

          // Platforms
          _buildSectionTitle(context, 'Platforms'),
          const SizedBox(height: 8),
          PlatformChips(
            selected: selectedPlatforms,
            onChanged: onPlatformsChanged,
          ),
          const SizedBox(height: 16),

          // Tone
          _buildSectionTitle(context, 'Tone'),
          const SizedBox(height: 8),
          ToneChips(selected: selectedTone, onChanged: onToneChanged),
          const SizedBox(height: 16),

          // Length and CTA row
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 400;
              final children = [
                Expanded(
                  flex: isNarrow ? 0 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Length'),
                      const SizedBox(height: 8),
                      LengthChips(
                        selected: selectedLength,
                        onChanged: onLengthChanged,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isNarrow ? 0 : 12, height: isNarrow ? 12 : 0),
                Expanded(
                  flex: isNarrow ? 0 : 1,
                  child: _buildDropdown<CtaType>(
                    context,
                    'Call to Action',
                    selectedCta,
                    CtaType.values,
                    (v) => v.displayName,
                    onCtaChanged,
                  ),
                ),
              ];

              return isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    );
            },
          ),
          const SizedBox(height: 16),

          // Mode-specific options
          _buildModeSpecificOptions(context),
          const SizedBox(height: 20),

          // Generate buttons
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isGenerating ? null : onGenerate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LPColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 18),
                            SizedBox(width: 8),
                            Text('Generate'),
                          ],
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: isGenerating ? null : onSurprise,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: LPColors.accent),
                    foregroundColor: LPColors.accent,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.casino, size: 18),
                      SizedBox(width: 4),
                      Text('Surprise'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeSpecificOptions(BuildContext context) {
    switch (mode) {
      case ContentMode.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Image Style'),
            const SizedBox(height: 8),
            ImageStyleChips(
              selected: selectedImageStyle,
              onChanged: onImageStyleChanged,
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Aspect Ratio'),
            const SizedBox(height: 8),
            AspectRatioChips(
              selected: selectedAspectRatio,
              onChanged: onAspectRatioChanged,
            ),
          ],
        );
      case ContentMode.carousel:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Carousel Style'),
            const SizedBox(height: 8),
            CarouselStyleChips(
              selected: selectedCarouselStyle,
              onChanged: onCarouselStyleChanged,
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Number of Slides: $slideCount'),
            const SizedBox(height: 8),
            Slider(
              value: slideCount.toDouble(),
              min: 2,
              max: 10,
              divisions: 8,
              label: '$slideCount',
              activeColor: LPColors.error,
              onChanged: (v) => onSlideCountChanged(v.toInt()),
            ),
          ],
        );
      case ContentMode.video:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Duration'),
            const SizedBox(height: 8),
            VideoDurationChips(
              selected: selectedDuration,
              onChanged: onDurationChanged,
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Video Style'),
            const SizedBox(height: 8),
            VideoStyleChips(
              selected: selectedVideoStyle,
              onChanged: onVideoStyleChanged,
            ),
          ],
        );
      case ContentMode.caption:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: isDark ? LPColors.textSecondaryDark : LPColors.grey600,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDropdown<T>(
    BuildContext context,
    String label,
    T value,
    List<T> items,
    String Function(T) displayName,
    ValueChanged<T> onChanged,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dropdownBgColor = isDark ? LPColors.surfaceDark : LPColors.grey100;
    final textColor = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: dropdownBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: isDark ? LPColors.cardDark : LPColors.surface,
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: isDark
                    ? LPColors.textSecondaryDark
                    : LPColors.textSecondary,
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    displayName(item),
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

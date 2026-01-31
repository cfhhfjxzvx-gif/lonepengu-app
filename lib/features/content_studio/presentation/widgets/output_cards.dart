import 'package:lone_pengu/core/design/lp_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/content_models.dart';

/// Caption output card with copy functionality
/// Theme-aware: adapts to light/dark mode
class CaptionOutputCard extends StatefulWidget {
  final CaptionVariant variant;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const CaptionOutputCard({
    super.key,
    required this.variant,
    this.isExpanded = false,
    this.onToggle,
  });

  @override
  State<CaptionOutputCard> createState() => _CaptionOutputCardState();
}

class _CaptionOutputCardState extends State<CaptionOutputCard> {
  void _copyCaption() {
    Clipboard.setData(ClipboardData(text: widget.variant.caption));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Caption copied!'),
          ],
        ),
        backgroundColor: LPColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyHashtags() {
    final hashtagsText = widget.variant.hashtags.map((h) => '#$h').join(' ');
    Clipboard.setData(ClipboardData(text: hashtagsText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Hashtags copied!'),
          ],
        ),
        backgroundColor: LPColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme-aware colors
    final cardBgColor = isDark ? LPColors.cardDark : LPColors.surface;
    final borderColor = isDark ? LPColors.borderDark : LPColors.grey200;
    final inputBgColor = isDark ? LPColors.surfaceDark : LPColors.grey100;
    final textSecondary = isDark
        ? LPColors.textSecondaryDark
        : LPColors.grey500;
    final textTertiary = isDark ? LPColors.textTertiaryDark : LPColors.grey600;

    return AnimatedContainer(
      duration: AppConstants.shortDuration,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: widget.isExpanded ? LPColors.primary : borderColor,
          width: widget.isExpanded ? 2 : 1,
        ),
        boxShadow: widget.isExpanded
            ? [
                BoxShadow(
                  color: LPColors.primary.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: widget.onToggle,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: LPColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.variant.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LPColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.variant.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: textSecondary),
                  ),
                  const Spacer(),
                  Icon(
                    widget.isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isDark
                        ? LPColors.textSecondaryDark
                        : LPColors.grey400,
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          if (widget.isExpanded) ...[
            Divider(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: inputBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      widget.variant.caption,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Copy caption button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _copyCaption,
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Caption'),
                      style: TextButton.styleFrom(
                        foregroundColor: LPColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Hashtags
                  Text(
                    'Hashtags',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: textTertiary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.variant.hashtags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: LPColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 12,
                            color: LPColors.accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _copyHashtags,
                      icon: const Icon(Icons.tag, size: 16),
                      label: const Text('Copy Hashtags'),
                      style: TextButton.styleFrom(
                        foregroundColor: LPColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Image output card
/// Theme-aware: adapts to light/dark mode
class ImageOutputCard extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onDownload;
  final VoidCallback? onOpenEditor;

  const ImageOutputCard({
    super.key,
    this.imageUrl,
    this.onDownload,
    this.onOpenEditor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = isDark ? LPColors.cardDark : LPColors.surface;
    final borderColor = isDark ? LPColors.borderDark : LPColors.grey200;
    final placeholderBgColor = isDark ? LPColors.surfaceDark : LPColors.grey100;

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Image preview
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1,
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: placeholderBgColor,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                    )
                  : _buildPlaceholder(context),
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDownload,
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Download'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onOpenEditor,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Open in Editor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LPColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? LPColors.surfaceDark : LPColors.grey100,
      child: Center(
        child: Icon(
          Icons.image,
          size: 64,
          color: isDark ? LPColors.textTertiaryDark : LPColors.grey300,
        ),
      ),
    );
  }
}

/// Carousel slide card
/// Theme-aware: adapts to light/dark mode
class CarouselSlideCard extends StatelessWidget {
  final CarouselSlide slide;

  const CarouselSlideCard({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = isDark ? LPColors.cardDark : LPColors.surface;
    final borderColor = isDark ? LPColors.borderDark : LPColors.grey200;
    final inputBgColor = isDark ? LPColors.surfaceDark : LPColors.grey100;
    final textTertiary = isDark ? LPColors.textTertiaryDark : LPColors.grey600;
    final textSecondary = isDark
        ? LPColors.textSecondaryDark
        : LPColors.grey500;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slide number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: LPColors.error,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${slide.slideNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  slide.body,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: textTertiary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: inputBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 14,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          slide.visualSuggestion,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Video output card with actual video player
class VideoOutputCard extends StatefulWidget {
  final double progress;
  final bool isComplete;
  final String? videoUrl;
  final VoidCallback? onDownload;
  final VoidCallback? onUseInScheduler;

  const VideoOutputCard({
    super.key,
    required this.progress,
    this.isComplete = false,
    this.videoUrl,
    this.onDownload,
    this.onUseInScheduler,
  });

  @override
  State<VideoOutputCard> createState() => _VideoOutputCardState();
}

class _VideoOutputCardState extends State<VideoOutputCard> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.isComplete && widget.videoUrl != null) {
      _initPlayer();
    }
  }

  @override
  void didUpdateWidget(VideoOutputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isComplete && !oldWidget.isComplete && widget.videoUrl != null) {
      _initPlayer();
    }
  }

  Future<void> _initPlayer() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }

    setState(() {
      _isInitialized = false;
      _error = null;
    });

    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl!),
      );
      await _controller!.initialize();
      await _controller!.setLooping(true);
      if (mounted) {
        setState(() => _isInitialized = true);
        _controller!.play();
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = 'Motion Generation failed. Using static fallback.',
        );
      }
      debugPrint('Video init failed: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = isDark ? LPColors.cardDark : LPColors.surface;
    final borderColor = isDark ? LPColors.borderDark : LPColors.grey200;
    final videoBgColor = isDark
        ? LPColors.backgroundDark
        : LPColors.textPrimary;
    final textSecondary = isDark
        ? LPColors.textSecondaryDark
        : LPColors.grey500;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Video Player area
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: videoBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.isComplete
                  ? (_error != null
                        ? _buildErrorState(theme)
                        : (_isInitialized
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    VideoPlayer(_controller!),
                                    _buildVideoControls(),
                                    _buildVideoBadge(),
                                  ],
                                )
                              : const Center(
                                  child: CircularProgressIndicator(),
                                )))
                  : _buildLoadingOverlay(textSecondary, isDark),
            ),
          ),
          if (widget.isComplete && _error == null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onDownload,
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Download'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onUseInScheduler,
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: const Text('Schedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LPColors.accent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_collection_outlined,
            color: theme.colorScheme.error,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _initPlayer,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry Motion Generation'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller!.value.isPlaying
              ? _controller!.pause()
              : _controller!.play();
        });
      },
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: AnimatedOpacity(
            opacity: _controller!.value.isPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoBadge() {
    return Positioned(
      bottom: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: LPColors.accent.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'AI Motion',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(Color textSecondary, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.video_camera_back_outlined, size: 40, color: textSecondary),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: LinearProgressIndicator(
            value: widget.progress,
            backgroundColor: isDark ? LPColors.borderDark : LPColors.grey700,
            valueColor: const AlwaysStoppedAnimation(LPColors.accent),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Generating video... ${(widget.progress * 100).toInt()}%',
          style: TextStyle(color: textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

/// Generation progress shimmer
/// Theme-aware: adapts to light/dark mode
class GenerationShimmer extends StatefulWidget {
  final String message;

  const GenerationShimmer({super.key, this.message = 'Generating...'});

  @override
  State<GenerationShimmer> createState() => _GenerationShimmerState();
}

class _GenerationShimmerState extends State<GenerationShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = isDark ? LPColors.cardDark : LPColors.surface;
    final borderColor = isDark ? LPColors.borderDark : LPColors.grey200;
    final shimmerBase = isDark ? LPColors.surfaceDark : LPColors.grey200;
    final shimmerHighlight = isDark
        ? LPColors.cardElevatedDark
        : LPColors.grey100;
    final textSecondary = isDark
        ? LPColors.textSecondaryDark
        : LPColors.grey500;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Shimmer lines
          ...List.generate(4, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    height: index == 0 ? 24 : 16,
                    width: index == 3 ? 200 : double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [shimmerBase, shimmerHighlight, shimmerBase],
                        stops: [
                          _animation.value - 0.3,
                          _animation.value,
                          _animation.value + 0.3,
                        ].map((s) => s.clamp(0.0, 1.0)).toList(),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(LPColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.message,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Empty state widget
/// Theme-aware: adapts to light/dark mode
class EmptyOutputState extends StatelessWidget {
  const EmptyOutputState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = isDark ? LPColors.cardDark : LPColors.surface;
    final borderColor = isDark ? LPColors.borderDark : LPColors.grey200;
    final iconBgColor = isDark ? LPColors.surfaceDark : LPColors.grey100;
    final iconColor = isDark ? LPColors.textTertiaryDark : LPColors.grey400;
    final textSecondary = isDark
        ? LPColors.textSecondaryDark
        : LPColors.grey500;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXl),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, size: 40, color: iconColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Ready to create?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate your first post idea using your Brand Kit context.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: textSecondary),
          ),
        ],
      ),
    );
  }
}

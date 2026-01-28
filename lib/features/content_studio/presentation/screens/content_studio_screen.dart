import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/lp_design.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../brand_kit/data/brand_kit_storage.dart';
import '../../../brand_kit/domain/brand_kit_model.dart';
import '../../data/content_models.dart';
import '../../data/ai_content_service.dart';
import '../../data/draft_storage.dart';
import '../../data/intent_detector.dart';
import '../../data/generated_asset.dart';
import '../../../editor/data/editor_args.dart';
import '../../../../core/utils/platform_aspect_mapper.dart';
import '../widgets/generator_prompt_card.dart';
import '../widgets/output_cards.dart';

class ContentStudioScreen extends StatefulWidget {
  const ContentStudioScreen({super.key});

  @override
  State<ContentStudioScreen> createState() => _ContentStudioScreenState();
}

class _ContentStudioScreenState extends State<ContentStudioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _promptController = TextEditingController();

  // Brand Kit
  BrandKit? _brandKit;

  // Generation state
  ContentMode _currentMode = ContentMode.auto;
  bool _isGenerating = false;
  double _progress = 0;
  GeneratedContent? _generatedContent;
  String? _errorMessage;
  IntentDetectionResult? _detectedIntent;

  // Input state
  String? _selectedIndustry;
  ContentGoal _selectedGoal = ContentGoal.engagement;
  List<SocialPlatform> _selectedPlatforms = [SocialPlatform.instagram];
  ContentTone _selectedTone = ContentTone.professional;
  ContentLength _selectedLength = ContentLength.medium;
  CtaType _selectedCta = CtaType.learnMore;

  // Image options
  ImageStyle _selectedImageStyle = ImageStyle.minimal;
  AppAspectRatio _selectedAspectRatio = AppAspectRatio.square;

  // Carousel options
  int _slideCount = 5;
  CarouselStyle _selectedCarouselStyle = CarouselStyle.tips;

  // Video options
  VideoDuration _selectedDuration = VideoDuration.thirtySec;
  VideoStyle _selectedVideoStyle = VideoStyle.modern;

  // Caption variant expansion
  int _expandedVariantIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _promptController.addListener(_onPromptChanged);
    _loadBrandKit();
  }

  Future<void> _loadBrandKit() async {
    final kit = await BrandKitStorage.loadBrandKit();
    if (mounted && kit != null) {
      setState(() {
        _brandKit = kit;
        final brandTone = kit.voiceTone.toLowerCase();
        for (final tone in ContentTone.values) {
          if (tone.displayName.toLowerCase() == brandTone) {
            _selectedTone = tone;
            break;
          }
        }
      });
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentMode = ContentMode.values[_tabController.index];
        _generatedContent = null;
        _errorMessage = null;
      });
    }
  }

  void _onPromptChanged() {
    if (_currentMode == ContentMode.auto) {
      final result = IntentDetector.detectIntent(_promptController.text);
      setState(() {
        _detectedIntent = result;
      });
    } else {
      setState(() {
        _detectedIntent = null;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a description/prompt first'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_selectedPlatforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one platform'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _progress = 0;
      _generatedContent = null;
      _errorMessage = null;
    });

    try {
      ContentMode generationMode = _currentMode;
      int? slideCountOverride;
      VideoDuration? durationOverride;

      if (_currentMode == ContentMode.auto) {
        if (_detectedIntent == null || _detectedIntent!.confidence < 0.45) {
          final userIntent = await _showIntentConfirmationDialog();
          if (userIntent == null) {
            setState(() => _isGenerating = false);
            return;
          }
          generationMode = userIntent;
        } else {
          generationMode = _detectedIntent!.intent;
          slideCountOverride = _detectedIntent!.metadata['slideCount'] as int?;
          durationOverride =
              _detectedIntent!.metadata['duration'] as VideoDuration?;
        }
      }

      final request = GenerationRequest(
        mode: generationMode,
        promptText: _promptController.text,
        industry: _selectedIndustry,
        goal: _selectedGoal,
        platforms: _selectedPlatforms,
        tone: _selectedTone,
        length: _selectedLength,
        cta: _selectedCta,
        imageStyle: _selectedImageStyle,
        aspectRatio: _selectedAspectRatio,
        slideCount: slideCountOverride ?? _slideCount,
        carouselStyle: _selectedCarouselStyle,
        duration: durationOverride ?? _selectedDuration,
        videoStyle: _selectedVideoStyle,
      );

      final result = await AiContentService.generateFromPrompt(
        request,
        onProgress: (p) => setState(() => _progress = p),
      );

      if (mounted) {
        setState(() {
          _generatedContent = result;
          _isGenerating = false;
          _expandedVariantIndex = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to generate content. Please try again.';
          _isGenerating = false;
        });
      }
    }
  }

  Future<ContentMode?> _showIntentConfirmationDialog() async {
    return showDialog<ContentMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('What do you want to generate?'),
        content: const Text(
          "I'm not quite sure about your intent. Please select a mode:",
        ),
        actions: [
          ...[
            ContentMode.caption,
            ContentMode.image,
            ContentMode.carousel,
            ContentMode.video,
          ].map((m) {
            return TextButton(
              onPressed: () => Navigator.pop(context, m),
              child: Text(m.displayName),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _surprise() async {
    setState(() {
      _isGenerating = true;
      _generatedContent = null;
      _errorMessage = null;
    });

    try {
      final request = GenerationRequest(
        mode: _currentMode,
        promptText: _promptController.text,
        goal: _selectedGoal,
        platforms: _selectedPlatforms.isEmpty
            ? [SocialPlatform.instagram]
            : _selectedPlatforms,
        tone: _selectedTone,
        length: _selectedLength,
        cta: _selectedCta,
      );

      final result = await AiContentService.generateSurprise(request);

      if (mounted) {
        setState(() {
          _generatedContent = result;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to generate content.';
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _saveToDrafts() async {
    if (_generatedContent == null) return;

    final draft = ContentDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      mode: _generatedContent!.mode,
      platforms: _selectedPlatforms,
      promptText: _promptController.text,
      caption: _generatedContent!.captionVariants.isNotEmpty
          ? _generatedContent!.captionVariants.first.caption
          : null,
      hashtags: _generatedContent!.hashtags,
      imageUrl: _generatedContent!.imageUrl,
      carouselSlides: _generatedContent!.carouselSlides,
      videoUrl: _generatedContent!.videoUrl,
    );

    final success = await DraftStorage.saveDraft(draft);

    if (mounted) {
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: theme.colorScheme.onInverseSurface,
                size: 18,
              ),
              Gap(width: LPSpacing.xs),
              Text(success ? 'Saved to drafts!' : 'Failed to save'),
            ],
          ),
          backgroundColor: success
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.errorContainer,
          // Use onContainer colors for text if possible, but SnackBar defaults might handle it or we need to be explicit.
          // Actually standard SnackBar uses inverse surface usually.
          // Let's stick to standard or use explicit colors.
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      useSafeArea: true,
      appBar: AppBar(
        titleSpacing: 0,
        leading: AppIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => context.pop(),
        ),
        title: Row(
          children: [
            Text(
              'Content Studio',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Gap(width: LPSpacing.sm),
            if (_brandKit != null)
              AppPill(
                label: _brandKit!.businessName,
                icon: Icons.palette,
                backgroundColor: theme.colorScheme.secondaryContainer,
                textColor: theme.colorScheme.onSecondaryContainer,
                isSmall: true,
                onTap: () => context.push(AppRoutes.brandKit),
              ),
          ],
        ),
        actions: [
          AppIconButton(
            icon: Icons.folder_outlined,
            onTap: () => context.push(AppRoutes.drafts),
          ),
          const Gap(width: LPSpacing.xs),
          AppIconButton(
            icon: Icons.tune,
            onTap: () => context.push(AppRoutes.brandKit),
          ),
          const Gap(width: LPSpacing.sm),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          tabs: ContentMode.values.map((mode) {
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(mode.icon),
                  const Gap(width: LPSpacing.xxs),
                  Text(mode.displayName),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: ResponsiveBuilder(
        builder: (context, deviceType) {
          final isWide = deviceType != DeviceType.mobile;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    padding: LPSpacing.page,
                    child: _buildPromptCard(),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    padding: LPSpacing.page,
                    child: _buildOutputArea(),
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            padding: LPSpacing.page,
            child: Column(
              children: [
                _buildPromptCard(),
                const Gap(height: LPSpacing.md),
                _buildOutputArea(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromptCard() {
    return GeneratorPromptCard(
      mode: _currentMode,
      promptController: _promptController,
      selectedIndustry: _selectedIndustry,
      selectedGoal: _selectedGoal,
      selectedPlatforms: _selectedPlatforms,
      selectedTone: _selectedTone,
      selectedLength: _selectedLength,
      selectedCta: _selectedCta,
      selectedImageStyle: _selectedImageStyle,
      selectedAspectRatio: _selectedAspectRatio,
      slideCount: _slideCount,
      selectedCarouselStyle: _selectedCarouselStyle,
      selectedDuration: _selectedDuration,
      selectedVideoStyle: _selectedVideoStyle,
      detectedIntent: _detectedIntent,
      onIndustryChanged: (v) => setState(() => _selectedIndustry = v),
      onGoalChanged: (v) => setState(() => _selectedGoal = v),
      onPlatformsChanged: (v) => setState(() => _selectedPlatforms = v),
      onToneChanged: (v) => setState(() => _selectedTone = v),
      onLengthChanged: (v) => setState(() => _selectedLength = v),
      onCtaChanged: (v) => setState(() => _selectedCta = v),
      onImageStyleChanged: (v) => setState(() => _selectedImageStyle = v),
      onAspectRatioChanged: (v) => setState(() => _selectedAspectRatio = v),
      onSlideCountChanged: (v) => setState(() => _slideCount = v),
      onCarouselStyleChanged: (v) => setState(() => _selectedCarouselStyle = v),
      onDurationChanged: (v) => setState(() => _selectedDuration = v),
      onVideoStyleChanged: (v) => setState(() => _selectedVideoStyle = v),
      onGenerate: _generate,
      onSurprise: _surprise,
      onIntentChanged: (intent) {
        setState(() {
          _detectedIntent = IntentDetectionResult(
            intent: intent,
            confidence: 1.0,
          );
        });
      },
      isGenerating: _isGenerating,
    );
  }

  Widget _buildOutputArea() {
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_isGenerating) {
      return _buildLoadingState();
    }

    if (_generatedContent == null) {
      return const EmptyOutputState();
    }

    return _buildResultState();
  }

  Widget _buildLoadingState() {
    String message;
    switch (_currentMode) {
      case ContentMode.auto:
        message = 'AI analyzing your intent...';
        break;
      case ContentMode.caption:
        message = 'Crafting your caption...';
        break;
      case ContentMode.image:
        message = 'Generating image... ${(_progress * 100).toInt()}%';
        break;
      case ContentMode.carousel:
        message = 'Creating carousel slides...';
        break;
      case ContentMode.video:
        message = 'Rendering video... ${(_progress * 100).toInt()}%';
        break;
    }

    if (_currentMode == ContentMode.video) {
      return VideoOutputCard(progress: _progress, isComplete: false);
    }

    return GenerationShimmer(message: message);
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    return AppCard.outlined(
      borderColor: theme.colorScheme.error.withOpacity(0.3),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          Gap(height: LPSpacing.sm),
          Text(
            _errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Gap(height: LPSpacing.md),
          AppButton.custom(
            label: 'Try Again',
            icon: Icons.refresh,
            onTap: _generate,
            size: ButtonSize.sm,
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildResultState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Generated Content',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                AppIconButton(icon: Icons.refresh, onTap: _generate, size: 32),
                const Gap(width: LPSpacing.xs),
                AppButton.teal(
                  label: 'Save Draft',
                  icon: Icons.save_alt,
                  onTap: _saveToDrafts,
                  size: ButtonSize.sm,
                ),
              ],
            ),
          ],
        ),
        const Gap(height: LPSpacing.md),
        _buildModeOutput(),
      ],
    );
  }

  Widget _buildModeOutput() {
    switch (_generatedContent!.mode) {
      case ContentMode.auto:
      case ContentMode.caption:
        return Column(
          children: _generatedContent!.captionVariants.asMap().entries.map((
            entry,
          ) {
            return CaptionOutputCard(
              variant: entry.value,
              isExpanded: entry.key == _expandedVariantIndex,
              onToggle: () => setState(() {
                _expandedVariantIndex = _expandedVariantIndex == entry.key
                    ? -1
                    : entry.key;
              }),
            );
          }).toList(),
        );

      case ContentMode.image:
        return Column(
          children: [
            ImageOutputCard(
              imageUrl: _generatedContent!.imageUrl,
              onDownload: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Download feature coming soon!'),
                    backgroundColor: LPColors.accent,
                  ),
                );
              },
              onOpenEditor: () {
                if (_generatedContent?.imageBytes == null &&
                    _generatedContent?.imageUrl == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No image available to edit')),
                  );
                  return;
                }

                HapticFeedback.mediumImpact();

                final priorityPlatform =
                    PlatformAspectMapper.getPriorityPlatform(
                      _selectedPlatforms,
                    );
                final aspect = PlatformAspectMapper.mapToAspectRatio(
                  priorityPlatform,
                  _generatedContent!.mode,
                );

                final asset = GeneratedAsset(
                  id: 'gen_${DateTime.now().millisecondsSinceEpoch}',
                  type: AssetType.image,
                  bytes: _generatedContent?.imageBytes,
                  tempUrl: _generatedContent?.imageUrl,
                  createdAt: DateTime.now(),
                  promptText: _promptController.text,
                );

                context.push(
                  AppRoutes.editor,
                  extra: EditorArgs(
                    asset: asset,
                    imageBytes: _generatedContent?.imageBytes,
                    aspectPreset: aspect.displayName,
                    sourcePlatform: priorityPlatform.displayName,
                    promptText: _promptController.text,
                  ),
                );
              },
            ),
            const Gap(height: LPSpacing.md),
            if (_generatedContent!.captionVariants.isNotEmpty)
              CaptionOutputCard(
                variant: _generatedContent!.captionVariants.first,
                isExpanded: true,
              ),
          ],
        );

      case ContentMode.carousel:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_generatedContent!.carouselSlides != null)
              ..._generatedContent!.carouselSlides!.map((slide) {
                return CarouselSlideCard(slide: slide);
              }),
            const Gap(height: LPSpacing.sm),
            AppButton.danger(
              label: 'Convert to Editor Slides',
              icon: Icons.edit,
              onTap: () => context.push(AppRoutes.editor),
              fullWidth: true,
            ),
            const Gap(height: LPSpacing.md),
            if (_generatedContent!.captionVariants.isNotEmpty)
              CaptionOutputCard(
                variant: _generatedContent!.captionVariants.first,
                isExpanded: true,
              ),
          ],
        );

      case ContentMode.video:
        return Column(
          children: [
            VideoOutputCard(
              progress: 1.0,
              isComplete: true,
              videoUrl: _generatedContent!.videoUrl,
              onDownload: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Download feature coming soon!'),
                    backgroundColor: LPColors.accent,
                  ),
                );
              },
              onUseInScheduler: () => context.push(AppRoutes.scheduler),
            ),
            const Gap(height: LPSpacing.md),
            if (_generatedContent!.captionVariants.isNotEmpty)
              CaptionOutputCard(
                variant: _generatedContent!.captionVariants.first,
                isExpanded: true,
              ),
          ],
        );
    }
  }
}

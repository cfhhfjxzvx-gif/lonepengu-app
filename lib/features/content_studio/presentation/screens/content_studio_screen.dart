import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../../core/widgets/app_background.dart';
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
        // Apply brand voice as default tone
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
        const SnackBar(
          content: Text('Please enter a description/prompt first'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedPlatforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one platform'),
          backgroundColor: AppColors.sunsetCoral,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: AppColors.iceWhite,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(success ? 'Saved to drafts!' : 'Failed to save'),
            ],
          ),
          backgroundColor: success
              ? AppColors.auroraTeal
              : AppColors.sunsetCoral,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.iceWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.penguinBlack,
        ),
        title: Row(
          children: [
            Text(
              'Content Studio',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            if (_brandKit != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.auroraTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.palette,
                      size: 14,
                      color: AppColors.auroraTeal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _brandKit!.businessName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.auroraTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.drafts),
            icon: const Icon(Icons.folder_outlined),
            color: AppColors.grey600,
            tooltip: 'Drafts',
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.brandKit),
            icon: const Icon(Icons.tune),
            color: AppColors.grey600,
            tooltip: 'Brand Kit',
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.arcticBlue,
          unselectedLabelColor: AppColors.grey500,
          indicatorColor: AppColors.arcticBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: ContentMode.values.map((mode) {
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(mode.icon),
                  const SizedBox(width: 4),
                  Text(mode.displayName),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: AppBackground(
        useSafeArea: false, // Handled by TabBar/AppBar layout
        child: ResponsiveBuilder(
          builder: (context, deviceType) {
            final isWide = deviceType != DeviceType.mobile;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Prompt card
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      child: _buildPromptCard(),
                    ),
                  ),
                  // Right: Output area
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      child: _buildOutputArea(),
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                children: [
                  _buildPromptCard(),
                  const SizedBox(height: 16),
                  _buildOutputArea(),
                ],
              ),
            );
          },
        ),
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
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.iceWhite,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.sunsetCoral.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.sunsetCoral,
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.grey600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sunsetCoral,
              foregroundColor: AppColors.iceWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Generated Content',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _generate,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Regenerate'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.grey600,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _saveToDrafts,
                  icon: const Icon(Icons.save_alt, size: 16),
                  label: const Text('Save Draft'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.auroraTeal,
                    foregroundColor: AppColors.iceWhite,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Mode-specific output
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
                  const SnackBar(
                    content: Text('Download feature coming soon!'),
                    backgroundColor: AppColors.frostPurple,
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

                // Premium UX: Haptic feedback
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
            const SizedBox(height: 16),
            // Also show caption variants
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
            // Carousel slides
            if (_generatedContent!.carouselSlides != null)
              ..._generatedContent!.carouselSlides!.map((slide) {
                return CarouselSlideCard(slide: slide);
              }),
            const SizedBox(height: 12),
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.editor),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Convert to Editor Slides'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sunsetCoral,
                  foregroundColor: AppColors.iceWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Caption suggestion
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
                  const SnackBar(
                    content: Text('Download feature coming soon!'),
                    backgroundColor: AppColors.frostPurple,
                  ),
                );
              },
              onUseInScheduler: () => context.push(AppRoutes.scheduler),
            ),
            const SizedBox(height: 16),
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

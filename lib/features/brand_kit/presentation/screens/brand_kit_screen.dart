import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../domain/brand_kit_model.dart';
import '../../data/brand_kit_storage.dart';
import '../widgets/brand_kit_stepper.dart';
import '../widgets/brand_preview_card.dart';
import '../widgets/color_swatch_picker.dart';
import '../widgets/voice_chips.dart';
import '../widgets/hashtag_group_card.dart';

import '../../../../core/widgets/app_background.dart';

class BrandKitScreen extends StatefulWidget {
  const BrandKitScreen({super.key});

  @override
  State<BrandKitScreen> createState() => _BrandKitScreenState();
}

class _BrandKitScreenState extends State<BrandKitScreen> {
  int _currentStep = 0;
  late BrandKit _brandKit;
  bool _isLoading = false;
  bool _isSaving = false;

  final _businessNameController = TextEditingController();
  final _stepLabels = ['Logo', 'Colors', 'Fonts', 'Voice'];
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _brandKit = BrandKit.empty;
    _loadExistingBrandKit();
  }

  Future<void> _loadExistingBrandKit() async {
    setState(() => _isLoading = true);
    final existing = await BrandKitStorage.loadBrandKit();
    if (existing != null && mounted) {
      setState(() {
        _brandKit = existing;
        _businessNameController.text = existing.businessName;
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step >= 0 && step < _stepLabels.length) {
      setState(() => _currentStep = step);
      _pageController.animateToPage(
        step,
        duration: AppConstants.mediumDuration,
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _nextStep() {
    if (_currentStep < _stepLabels.length - 1) {
      _goToStep(_currentStep + 1);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  /// Pick logo - works on both Web and Mobile
  Future<void> _pickLogo() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return; // User cancelled

      if (kIsWeb) {
        // For Web: Read as bytes
        final bytes = await image.readAsBytes();
        if (mounted) {
          setState(() {
            _brandKit = _brandKit.copyWith(
              logoBytes: bytes,
              logoPath: image.name, // Store name for reference
            );
          });
        }
      } else {
        // For Mobile/Desktop: Use file path
        if (mounted) {
          setState(() {
            _brandKit = _brandKit.copyWith(logoPath: image.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick image: $e'),
            backgroundColor: AppColors.sunsetCoral,
          ),
        );
      }
    }
  }

  Future<void> _saveBrandKit() async {
    // Validate
    if (_brandKit.businessName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your business name'),
          backgroundColor: AppColors.sunsetCoral,
        ),
      );
      _goToStep(0);
      return;
    }

    setState(() => _isSaving = true);
    final success = await BrandKitStorage.saveBrandKit(_brandKit);
    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.iceWhite),
                SizedBox(width: 8),
                Text('Brand Kit saved successfully!'),
              ],
            ),
            backgroundColor: AppColors.auroraTeal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        context.go(AppRoutes.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save. Please try again.'),
            backgroundColor: AppColors.sunsetCoral,
          ),
        );
      }
    }
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.iceWhite,
          elevation: 0,
          leading: IconButton(
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.penguinBlack,
          ),
          title: Text(
            'Brand Kit',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : AppBackground(
                child: ResponsiveBuilder(
                  builder: (context, deviceType) {
                    return Column(
                      children: [
                        // Stepper
                        Container(
                          color: AppColors.iceWhite,
                          padding: const EdgeInsets.only(bottom: 16),
                          child: BrandKitStepper(
                            currentStep: _currentStep,
                            steps: _stepLabels,
                            onStepTap: _goToStep,
                          ),
                        ),
                        // Preview Card
                        BrandPreviewCard(brandKit: _brandKit),
                        const SizedBox(height: 16),
                        // Step Content
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            onPageChanged: (index) =>
                                setState(() => _currentStep = index),
                            children: [
                              _buildStep1Logo(),
                              _buildStep2Colors(),
                              _buildStep3Fonts(),
                              _buildStep4VoiceHashtags(),
                            ],
                          ),
                        ),
                        // Bottom Navigation
                        _buildBottomNav(),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildStep1Logo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Business Logo',
            child: Column(
              children: [
                // Logo preview - Platform aware
                GestureDetector(
                  onTap: _pickLogo,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.grey300,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: ClipOval(child: _buildLogoPreview()),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickLogo,
                  icon: const Icon(Icons.upload_rounded, size: 18),
                  label: Text(
                    _brandKit.hasLogo ? 'Change Logo' : 'Upload Logo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Business Name',
            child: TextField(
              controller: _businessNameController,
              decoration: const InputDecoration(
                hintText: 'Enter your business name',
                prefixIcon: Icon(Icons.business_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                setState(() {
                  _brandKit = _brandKit.copyWith(businessName: value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build logo preview - handles Web vs Mobile
  Widget _buildLogoPreview() {
    // Check if we have logo bytes (Web) or path (Mobile)
    if (_brandKit.logoBytes != null && _brandKit.logoBytes!.isNotEmpty) {
      // Web: Use Image.memory
      return Image.memory(
        _brandKit.logoBytes!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (_, __, ___) => _buildLogoPlaceholder(),
      );
    } else if (!kIsWeb &&
        _brandKit.logoPath != null &&
        _brandKit.logoPath!.isNotEmpty) {
      // Mobile/Desktop: Use Image.file
      return Image.file(
        File(_brandKit.logoPath!),
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (_, __, ___) => _buildLogoPlaceholder(),
      );
    }

    // No logo - show placeholder
    return _buildLogoPlaceholder();
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      width: 120,
      height: 120,
      color: AppColors.grey100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 32,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 4),
          Text(
            'Add Logo',
            style: TextStyle(fontSize: 12, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Colors() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Brand Colors',
            child: Column(
              children: [
                ColorSwatchPicker(
                  label: 'Primary Color',
                  selectedColor: _brandKit.colors.primary,
                  onColorChanged: (color) {
                    setState(() {
                      _brandKit = _brandKit.copyWith(
                        colors: _brandKit.colors.copyWith(primary: color),
                      );
                    });
                  },
                ),
                const SizedBox(height: 12),
                ColorSwatchPicker(
                  label: 'Secondary Color',
                  selectedColor: _brandKit.colors.secondary,
                  onColorChanged: (color) {
                    setState(() {
                      _brandKit = _brandKit.copyWith(
                        colors: _brandKit.colors.copyWith(secondary: color),
                      );
                    });
                  },
                ),
                const SizedBox(height: 12),
                ColorSwatchPicker(
                  label: 'Accent Color',
                  selectedColor: _brandKit.colors.accent,
                  onColorChanged: (color) {
                    setState(() {
                      _brandKit = _brandKit.copyWith(
                        colors: _brandKit.colors.copyWith(accent: color),
                      );
                    });
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Auto-palette from logo coming soon! 🎨'),
                        backgroundColor: AppColors.frostPurple,
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_fix_high, size: 18),
                  label: const Text('Apply from Logo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Fonts() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Typography',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heading font dropdown
                _buildFontDropdown(
                  label: 'Heading Font',
                  value: _brandKit.headingFont,
                  options: FontOptions.headingFonts,
                  onChanged: (font) {
                    setState(() {
                      _brandKit = _brandKit.copyWith(headingFont: font);
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Body font dropdown
                _buildFontDropdown(
                  label: 'Body Font',
                  value: _brandKit.bodyFont,
                  options: FontOptions.bodyFonts,
                  onChanged: (font) {
                    setState(() {
                      _brandKit = _brandKit.copyWith(bodyFont: font);
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Typography preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Typography Preview',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Heading Example',
                        style: _getSafeFont(
                          _brandKit.headingFont,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.penguinBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Body text example for your posts. This is how your content will look across social platforms.',
                        style: _getSafeFont(
                          _brandKit.bodyFont,
                          fontSize: 14,
                          color: AppColors.grey700,
                          height: 1.5,
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

  Widget _buildFontDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: AppColors.grey600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.iceWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: options.map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(font, style: _getSafeFont(font, fontSize: 14)),
                );
              }).toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep4VoiceHashtags() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Voice section
          _buildSectionCard(
            title: 'Brand Voice',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select your brand tone:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                VoiceChips(
                  selectedTone: _brandKit.voiceTone,
                  onToneChanged: (tone) {
                    setState(() {
                      _brandKit = _brandKit.copyWith(voiceTone: tone);
                    });
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Brand Style:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                FormalitySlider(
                  value: _brandKit.formalityValue,
                  onChanged: (value) {
                    setState(() {
                      _brandKit = _brandKit.copyWith(formalityValue: value);
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Hashtags section
          _buildSectionCard(
            title: 'Hashtag Groups',
            child: Column(
              children: [
                if (_brandKit.hashtagGroups.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.tag, size: 40, color: AppColors.grey300),
                        const SizedBox(height: 8),
                        Text(
                          'No hashtag groups yet',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.grey500),
                        ),
                      ],
                    ),
                  )
                else
                  ...List.generate(_brandKit.hashtagGroups.length, (index) {
                    final group = _brandKit.hashtagGroups[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HashtagGroupCard(
                        group: group,
                        onEdit: () => _showHashtagBottomSheet(
                          existingGroup: group,
                          index: index,
                        ),
                        onDelete: () => _deleteHashtagGroup(index),
                      ),
                    );
                  }),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _showHashtagBottomSheet(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Hashtag Group'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.frostPurple,
                    side: const BorderSide(color: AppColors.frostPurple),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHashtagBottomSheet({HashtagGroup? existingGroup, int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HashtagGroupBottomSheet(
        existingGroup: existingGroup,
        onSave: (group) {
          setState(() {
            final groups = List<HashtagGroup>.from(_brandKit.hashtagGroups);
            if (index != null) {
              groups[index] = group;
            } else {
              groups.add(group);
            }
            _brandKit = _brandKit.copyWith(hashtagGroups: groups);
          });
        },
      ),
    );
  }

  void _deleteHashtagGroup(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hashtag Group?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final groups = List<HashtagGroup>.from(_brandKit.hashtagGroups);
                groups.removeAt(index);
                _brandKit = _brandKit.copyWith(hashtagGroups: groups);
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.sunsetCoral),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.iceWhite,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.iceWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.penguinBlack.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : _currentStep == _stepLabels.length - 1
                    ? _saveBrandKit
                    : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.arcticBlue,
                  foregroundColor: AppColors.iceWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.iceWhite,
                        ),
                      )
                    : Text(
                        _currentStep == _stepLabels.length - 1
                            ? 'Save Brand Kit'
                            : 'Next',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Safe font getter with fallback to Inter
  TextStyle _getSafeFont(
    String fontFamily, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    try {
      return GoogleFonts.getFont(
        fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );
    } catch (_) {
      // Fallback to Inter if font not found
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );
    }
  }
}

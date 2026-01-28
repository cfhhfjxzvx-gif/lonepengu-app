import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/design/lp_design.dart';
import '../../../../core/constants/app_constants.dart';

import '../../domain/brand_kit_model.dart';
import '../../data/brand_kit_storage.dart';
import '../widgets/brand_kit_stepper.dart';
import '../widgets/brand_preview_card.dart';
import '../widgets/color_swatch_picker.dart';
import '../widgets/voice_chips.dart';
import '../widgets/hashtag_group_card.dart';

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
        duration: const Duration(milliseconds: 300),
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

  Future<void> _pickLogo() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        if (mounted) {
          setState(() {
            _brandKit = _brandKit.copyWith(
              logoBytes: bytes,
              logoPath: image.name,
            );
          });
        }
      } else {
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
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _saveBrandKit() async {
    final theme = Theme.of(context);
    if (_brandKit.businessName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your business name'),
          backgroundColor: theme.colorScheme.error,
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
            content: Row(
              children: [
                Icon(Icons.check_circle, color: theme.colorScheme.onSecondary),
                const Gap(width: 8),
                const Expanded(child: Text('Brand Kit saved successfully!')),
              ],
            ),
            backgroundColor: const Color(0xFF10B981), // Success green
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.go(AppRoutes.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save. Please try again.'),
            backgroundColor: theme.colorScheme.error,
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
    final theme = Theme.of(context);

    return AppScaffold(
      useSafeArea: true,
      appBar: AppBar(
        title: const Text('Brand Kit'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: AppIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: _handleBack,
        ),
      ),
      body: _isLoading
          ? const AppLoading()
          : Column(
              children: [
                // Stepper
                Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.only(bottom: 16),
                  child: BrandKitStepper(
                    currentStep: _currentStep,
                    steps: _stepLabels,
                    onStepTap: _goToStep,
                  ),
                ),
                // Main content
                Expanded(
                  child: AppPage(
                    scroll: false,
                    padding: EdgeInsets.zero,
                    child: AppMaxWidth(
                      maxWidth: 600,
                      child: Column(
                        children: [
                          // Preview Card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: BrandPreviewCard(brandKit: _brandKit),
                          ),
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
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom Navigation
                _buildBottomNav(),
              ],
            ),
    );
  }

  Widget _buildStep1Logo() {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        AppSection(
          title: 'Business Logo',
          child: AppCard(
            width: double.infinity,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickLogo,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(child: _buildLogoPreview()),
                  ),
                ),
                const SizedBox(height: 16),
                AppButton.secondary(
                  label: _brandKit.hasLogo ? 'Change Logo' : 'Upload Logo',
                  icon: Icons.upload_rounded,
                  onTap: _pickLogo,
                  size: ButtonSize.sm,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        AppSection(
          title: 'Business Name',
          child: AppCard(
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
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildLogoPreview() {
    if (_brandKit.logoBytes != null && _brandKit.logoBytes!.isNotEmpty) {
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
      return Image.file(
        File(_brandKit.logoPath!),
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (_, __, ___) => _buildLogoPlaceholder(),
      );
    }
    return _buildLogoPlaceholder();
  }

  Widget _buildLogoPlaceholder() {
    final theme = Theme.of(context);
    return Container(
      width: 120,
      height: 120,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 4),
          Text(
            'Add Logo',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Colors() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        AppSection(
          title: 'Brand Colors',
          child: AppCard(
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
                AppButton.soft(
                  label: 'Apply from Logo',
                  icon: Icons.auto_fix_high,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Auto-palette from logo coming soon! 🎨',
                        ),
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                      ),
                    );
                  },
                  size: ButtonSize.sm,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildStep3Fonts() {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        AppSection(
          title: 'Typography',
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TYPOGRAPHY PREVIEW',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Heading Example',
                        style: _getSafeFont(
                          _brandKit.headingFont,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Body text example for your posts. This is how your content will look across social platforms.',
                        style: _getSafeFont(
                          _brandKit.bodyFont,
                          fontSize: 15,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildFontDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: theme.colorScheme.surface,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: theme.colorScheme.primary,
              ),
              items: options.map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(
                    font,
                    style: _getSafeFont(
                      font,
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
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
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        AppSection(
          title: 'Brand Voice',
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select your brand tone:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                const SizedBox(height: 24),
                Text(
                  'Brand Style:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
        ),
        const SizedBox(height: 24),
        AppSection(
          title: 'Hashtag Groups',
          child: AppCard(
            child: Column(
              children: [
                if (_brandKit.hashtagGroups.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.tag,
                          size: 48,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No hashtag groups yet',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
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
                const SizedBox(height: 12),
                AppButton.secondary(
                  label: 'New Hashtag Group',
                  icon: Icons.add,
                  onTap: () => _showHashtagBottomSheet(),
                  size: ButtonSize.sm,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 48),
      ],
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
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: AppButton.secondary(label: 'Back', onTap: _previousStep),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton.primary(
                label: _currentStep == _stepLabels.length - 1
                    ? 'Save Brand Kit'
                    : 'Next',
                isLoading: _isSaving,
                onTap: _currentStep == _stepLabels.length - 1
                    ? _saveBrandKit
                    : _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
    } catch (e) {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );
    }
  }
}

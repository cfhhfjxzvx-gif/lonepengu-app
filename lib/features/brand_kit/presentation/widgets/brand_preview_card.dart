import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/brand_kit_model.dart';

/// Live preview card showing how posts will look with current brand settings
class BrandPreviewCard extends StatelessWidget {
  final BrandKit brandKit;

  const BrandPreviewCard({super.key, required this.brandKit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.iceWhite,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.penguinBlack.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and brand name
          Row(
            children: [
              // Logo/Avatar
              _buildAvatar(),
              const SizedBox(width: 12),
              // Brand name and handle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brandKit.businessName.isEmpty
                          ? 'Your Brand'
                          : brandKit.businessName,
                      style: _getHeadingStyle(context, 14),
                    ),
                    Text(
                      '@${_getHandle()}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
              // Preview badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: brandKit.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Preview',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: brandKit.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Post caption
          Text(_getExampleCaption(), style: _getBodyStyle(context, 13)),
          const SizedBox(height: 8),
          // Hashtags
          Wrap(
            spacing: 6,
            children: _getPreviewHashtags()
                .map(
                  (tag) => Text(
                    '#$tag',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: brandKit.colors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          // Color swatches
          Row(
            children: [
              _buildColorDot(brandKit.colors.primary, 'Primary'),
              const SizedBox(width: 8),
              _buildColorDot(brandKit.colors.secondary, 'Secondary'),
              const SizedBox(width: 8),
              _buildColorDot(brandKit.colors.accent, 'Accent'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    // Check if we have logo bytes (Web) or path (Mobile)
    if (brandKit.logoBytes != null && brandKit.logoBytes!.isNotEmpty) {
      // Web: Use Image.memory
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.memory(
          brandKit.logoBytes!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
        ),
      );
    } else if (!kIsWeb &&
        brandKit.logoPath != null &&
        brandKit.logoPath!.isNotEmpty) {
      // Mobile/Desktop: Use Image.file
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          File(brandKit.logoPath!),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
        ),
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [brandKit.colors.primary, brandKit.colors.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          brandKit.businessName.isEmpty
              ? 'B'
              : brandKit.businessName[0].toUpperCase(),
          style: const TextStyle(
            color: AppColors.iceWhite,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.grey200, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.grey500),
        ),
      ],
    );
  }

  String _getHandle() {
    if (brandKit.businessName.isEmpty) return 'yourbrand';
    return brandKit.businessName.toLowerCase().replaceAll(' ', '');
  }

  String _getExampleCaption() {
    switch (brandKit.voiceTone) {
      case 'Professional':
        return 'Delivering excellence through innovation. Our commitment to quality drives everything we do. ✨';
      case 'Friendly':
        return 'Hey there! 👋 We\'re so excited to share this with you. Let\'s create something amazing together! 💫';
      case 'Bold':
        return 'BREAKING THE MOLD. 🔥 We don\'t follow trends — we CREATE them. Join the revolution.';
      case 'Minimal':
        return 'Less is more. Quality over quantity. Simplicity at its finest.';
      case 'Funny':
        return 'When your coffee is stronger than your Monday motivation 😅☕ Who else feels this? Tag a friend!';
      case 'Luxury':
        return 'Experience unparalleled elegance. Where sophistication meets timeless design. Exclusively crafted for the discerning.';
      default:
        return 'Share your story with the world. Create content that matters. ✨';
    }
  }

  List<String> _getPreviewHashtags() {
    if (brandKit.hashtagGroups.isNotEmpty &&
        brandKit.hashtagGroups.first.tags.isNotEmpty) {
      return brandKit.hashtagGroups.first.tags.take(3).toList();
    }
    return [_getHandle(), 'socialmedia', 'branding'];
  }

  TextStyle _getHeadingStyle(BuildContext context, double size) {
    try {
      return GoogleFonts.getFont(
        brandKit.headingFont,
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: AppColors.penguinBlack,
      );
    } catch (_) {
      // Fallback to Inter if font not found
      return GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: AppColors.penguinBlack,
      );
    }
  }

  TextStyle _getBodyStyle(BuildContext context, double size) {
    try {
      return GoogleFonts.getFont(
        brandKit.bodyFont,
        fontSize: size,
        fontWeight: FontWeight.normal,
        color: AppColors.grey700,
        height: 1.4,
      );
    } catch (_) {
      // Fallback to Inter if font not found
      return GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.normal,
        color: AppColors.grey700,
        height: 1.4,
      );
    }
  }
}

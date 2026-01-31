import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/brand_kit_model.dart';

/// Live preview card showing how posts will look with current brand settings
class BrandPreviewCard extends StatelessWidget {
  final BrandKit brandKit;

  const BrandPreviewCard({super.key, required this.brandKit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLow
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
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
              _buildAvatar(theme),
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
                      style: _getHeadingStyle(context, 15),
                    ),
                    Text(
                      '@${_getHandle()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Preview badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: brandKit.colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: brandKit.colors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  'Live Preview',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: brandKit.colors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Post caption
          Text(_getExampleCaption(), style: _getBodyStyle(context, 14)),
          const SizedBox(height: 10),
          // Hashtags
          Wrap(
            spacing: 8,
            children: _getPreviewHashtags()
                .map(
                  (tag) => Text(
                    '#$tag',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: brandKit.colors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 12),
          // Color swatches
          Row(
            children: [
              _buildColorDot(theme, brandKit.colors.primary, 'Primary'),
              const SizedBox(width: 12),
              _buildColorDot(theme, brandKit.colors.secondary, 'Secondary'),
              const SizedBox(width: 12),
              _buildColorDot(theme, brandKit.colors.accent, 'Accent'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    if (brandKit.logoBytes != null && brandKit.logoBytes!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.memory(
          brandKit.logoBytes!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultAvatar(theme),
        ),
      );
    } else if (!kIsWeb &&
        brandKit.logoPath != null &&
        brandKit.logoPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          File(brandKit.logoPath!),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultAvatar(theme),
        ),
      );
    }

    return _buildDefaultAvatar(theme);
  }

  Widget _buildDefaultAvatar(ThemeData theme) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: brandKit.colors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: brandKit.colors.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          brandKit.businessName.isEmpty
              ? Icons.auto_awesome_rounded
              : Icons.business_center_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildColorDot(ThemeData theme, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 11,
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
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
    final theme = Theme.of(context);
    try {
      return GoogleFonts.getFont(
        brandKit.headingFont,
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      );
    } catch (_) {
      return theme.textTheme.titleMedium!.copyWith(
        fontSize: size,
        fontWeight: FontWeight.bold,
      );
    }
  }

  TextStyle _getBodyStyle(BuildContext context, double size) {
    final theme = Theme.of(context);
    try {
      return GoogleFonts.getFont(
        brandKit.bodyFont,
        fontSize: size,
        fontWeight: FontWeight.normal,
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.5,
      );
    } catch (_) {
      return theme.textTheme.bodyMedium!.copyWith(
        fontSize: size,
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.5,
      );
    }
  }
}

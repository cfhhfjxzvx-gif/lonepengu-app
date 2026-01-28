import 'package:flutter/material.dart';
import '../design/lp_design.dart';
import '../constants/app_constants.dart';

/// Reusable App logo widget
/// Uses the actual logo asset with customizable size and alignment
class AppLogo extends StatelessWidget {
  /// Size of the logo (width and height)
  final double size;

  /// Alignment of the logo within its container
  final Alignment alignment;

  /// Whether to show the app name text next to the logo
  final bool showText;

  /// Whether to apply a shadow effect
  final bool withShadow;

  /// Border radius for the logo container
  final double borderRadius;

  const AppLogo({
    super.key,
    this.size = 48,
    this.alignment = Alignment.center,
    this.showText = false,
    this.withShadow = false,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidget = Container(
      width: size,
      height: size,
      decoration: withShadow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: LPShadows.lg,
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/images/lonepengu_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to placeholder if image not found
            return _buildFallbackLogo(context);
          },
        ),
      ),
    );

    if (!showText) {
      return Align(alignment: alignment, child: logoWidget);
    }

    return Align(
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          logoWidget,
          Gap(width: LPSpacing.md),
          Text(
            AppConstants.appName,
            style: LPText.hMD.copyWith(
              fontWeight: FontWeight.bold,
              color: LPColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackLogo(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [LPColors.primary, LPColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Text('🐧', style: TextStyle(fontSize: size * 0.5)),
      ),
    );
  }
}

/// Small logo widget for AppBar usage
class AppBarLogo extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const AppBarLogo({super.key, this.size = 32, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/lonepengu_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [LPColors.primary, LPColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('🐧', style: TextStyle(fontSize: size * 0.5)),
              ),
            );
          },
        ),
      ),
    );
  }
}

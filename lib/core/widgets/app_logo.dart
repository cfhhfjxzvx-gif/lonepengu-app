import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
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
              boxShadow: [
                BoxShadow(
                  color: AppColors.arcticBlue.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: AppColors.penguinBlack.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
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
          SizedBox(width: AppConstants.spacingMd),
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.penguinBlack,
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
        gradient: AppColors.accentGradient,
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
                gradient: AppColors.accentGradient,
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

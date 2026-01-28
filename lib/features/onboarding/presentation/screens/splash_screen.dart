import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/responsive_builder.dart';

/// Premium animated splash screen for LonePengu
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _shimmerController;

  // Logo Animations
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _logoTranslate;

  // Text Selection
  final String _brandName = 'LonePengu';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
  }

  void _setupAnimations() {
    // 1. Logo Animation (Fade + Scale + Slide)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _logoScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _logoTranslate = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // 2. Text Reveal Animation (Swipe)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // 3. Shimmer Sweep Animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  Future<void> _startAnimationSequence() async {
    // Initial delay
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    // Start Logo
    _logoController.forward();

    // Wait for logo (650ms) -> total 800ms
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    // Start Text Reveal
    _textController.forward();

    // Wait for reveal (450ms) -> total 1250ms
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    // Start Shimmer
    _shimmerController.forward();

    // Total duration 2.2s (2200ms)
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    _navigateToLanding();
  }

  void _navigateToLanding() {
    if (mounted) {
      context.go(AppRoutes.landing);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Premium Background with Radial Gradient
          _buildBackground(theme),

          SafeArea(
            child: ResponsiveBuilder(
              builder: (context, deviceType) {
                final isTablet = deviceType == DeviceType.tablet;
                final logoSize = isTablet ? 190.0 : 150.0;
                final textSize = isTablet ? 34.0 : 28.0;

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo with Glow
                      _buildAnimatedLogo(theme, logoSize),

                      const SizedBox(height: 18),

                      // Animated Brand Text
                      _buildAnimatedText(theme, textSize),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            isDark ? theme.colorScheme.surface : theme.colorScheme.surface,
            isDark
                ? theme.colorScheme.primaryContainer.withOpacity(0.15)
                : theme.colorScheme.primaryContainer.withOpacity(0.05),
          ],
          stops: const [0.2, 1.0],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo(ThemeData theme, double size) {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Opacity(
          opacity: _logoOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _logoTranslate.value),
            child: Transform.scale(
              scale: _logoScale.value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.15),
        child: Image.asset(
          'assets/images/lonepengu_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              _buildLogoPlaceholder(theme, size),
        ),
      ),
    );
  }

  Widget _buildLogoPlaceholder(ThemeData theme, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size * 0.15),
      ),
      child: Center(
        child: Text('🐧', style: TextStyle(fontSize: size * 0.5)),
      ),
    );
  }

  Widget _buildAnimatedText(ThemeData theme, double size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_textController, _shimmerController]),
      builder: (context, child) {
        return SwipeRevealText(
          text: _brandName,
          fontSize: size,
          theme: theme,
          revealProgress: _textController.value,
          shimmerProgress: _shimmerController.value,
        );
      },
    );
  }
}

/// Helper widget for the swipe reveal and shimmer effect
class SwipeRevealText extends StatelessWidget {
  final String text;
  final double fontSize;
  final ThemeData theme;
  final double revealProgress;
  final double shimmerProgress;

  const SwipeRevealText({
    super.key,
    required this.text,
    required this.theme,
    required this.fontSize,
    required this.revealProgress,
    required this.shimmerProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Reveal with ClipRect
        ClipRect(
          clipper: _HorizontalRevealClipper(revealProgress),
          child: _buildStrokedText(context),
        ),

        // Shimmer sweep (only visible after reveal and during shimmer phase)
        if (revealProgress >= 1.0 && shimmerProgress > 0)
          ClipRect(
            clipper: _HorizontalRevealClipper(revealProgress),
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    theme.colorScheme.onSurface.withOpacity(0.0),
                    theme.colorScheme.onSurface.withOpacity(0.25),
                    theme.colorScheme.onSurface,
                    theme.colorScheme.onSurface.withOpacity(0.25),
                    theme.colorScheme.onSurface.withOpacity(0.0),
                  ],
                  stops: [
                    (shimmerProgress * 1.5) - 0.5,
                    (shimmerProgress * 1.5) - 0.25,
                    (shimmerProgress * 1.5),
                    (shimmerProgress * 1.5) + 0.25,
                    (shimmerProgress * 1.5) + 0.5,
                  ],
                ).createShader(bounds);
              },
              child: _buildStrokedText(context),
            ),
          ),
      ],
    );
  }

  Widget _buildStrokedText(BuildContext context) {
    final baseStyle = theme.textTheme.displayMedium?.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.5,
    );

    return Stack(
      children: [
        // Stroke
        Text(
          text,
          style: baseStyle?.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0
              ..color = theme.colorScheme.primary.withOpacity(0.3),
          ),
        ),
        // Fill
        Text(
          text,
          style: baseStyle?.copyWith(color: theme.colorScheme.onSurface),
        ),
      ],
    );
  }
}

class _HorizontalRevealClipper extends CustomClipper<Rect> {
  final double progress;

  _HorizontalRevealClipper(this.progress);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * progress, size.height);
  }

  @override
  bool shouldReclip(_HorizontalRevealClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

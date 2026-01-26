import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/responsive_builder.dart';

import '../../../../core/widgets/app_background.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: ResponsiveBuilder(
          builder: (context, deviceType) {
            final isDesktop = deviceType == DeviceType.desktop;
            final isTablet = deviceType == DeviceType.tablet;
            final isMobile = deviceType == DeviceType.mobile;

            // Logo size based on device type
            final logoSize = isMobile ? 120.0 : (isTablet ? 160.0 : 180.0);

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop
                        ? 1200
                        : (isTablet ? 800 : AppConstants.maxContentWidth),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.responsive(
                        mobile: AppConstants.spacingMd,
                        tablet: AppConstants.spacingXl,
                        desktop: AppConstants.spacingXxl,
                      ),
                      vertical: AppConstants.spacingXl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo with shadow
                        AppLogo(
                          size: logoSize,
                          withShadow: true,
                          borderRadius: 16,
                        ),
                        const SizedBox(
                          height: 24,
                        ), // Fixed 24px spacing below logo
                        // Hero Section
                        _buildHeroSection(context, isDesktop),

                        SizedBox(height: AppConstants.spacingXxl),

                        // Feature Cards
                        _buildFeatureCards(context, deviceType),

                        SizedBox(height: AppConstants.spacingXxl),

                        // CTA Buttons
                        _buildCTASection(context),

                        SizedBox(height: AppConstants.spacingXl),

                        // Footer
                        _buildFooter(context),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        // Main Headline
        Text(
          AppConstants.appTagline,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: isDesktop ? 48 : 32,
            height: 1.2,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppConstants.spacingMd),
        // Social Platforms
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: AppConstants.spacingSm,
          ),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          ),
          child: Text(
            AppConstants.socialPlatforms,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.grey500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCards(BuildContext context, DeviceType deviceType) {
    final features = [
      _FeatureData(
        icon: Icons.auto_awesome,
        title: 'AI Content Generation',
        description:
            'Create engaging posts with AI that understands your brand voice',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.frostPurple, Color(0xFF6D28D9)],
        ),
      ),
      _FeatureData(
        icon: Icons.calendar_month_rounded,
        title: 'Scheduling & Publishing',
        description:
            'Plan and publish content across all platforms from one place',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.auroraTeal, Color(0xFF059669)],
        ),
      ),
      _FeatureData(
        icon: Icons.analytics_rounded,
        title: 'Analytics Dashboard',
        description:
            'Track performance and grow your audience with smart insights',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sunsetCoral, Color(0xFFDC2626)],
        ),
      ),
    ];

    if (deviceType == DeviceType.mobile) {
      return Column(
        children: features
            .map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
                child: _FeatureCard(feature: feature),
              ),
            )
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map(
            (feature) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingSm,
                ),
                child: _FeatureCard(feature: feature),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppConstants.maxCardWidth),
      child: Column(
        children: [
          PrimaryButton(
            text: 'Get Started',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => context.push(AppRoutes.signUp),
          ),
          SizedBox(height: AppConstants.spacingMd),
          SecondaryButton(
            text: 'Sign In',
            onPressed: () => context.push(AppRoutes.signIn),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacingMd),
      child: Text(
        'By continuing, you agree to Terms & Privacy',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.grey400),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final LinearGradient gradient;

  _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}

class _FeatureCard extends StatefulWidget {
  final _FeatureData feature;

  const _FeatureCard({required this.feature});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppConstants.shortDuration,
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0.0, _isHovered ? -4.0 : 0.0, 0.0),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          decoration: BoxDecoration(
            color: AppColors.iceWhite,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: _isHovered ? AppColors.grey300 : AppColors.grey200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.penguinBlack.withValues(
                  alpha: _isHovered ? 0.1 : 0.05,
                ),
                blurRadius: _isHovered ? 20 : 12,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with gradient background
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: widget.feature.gradient,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Icon(
                  widget.feature.icon,
                  color: AppColors.iceWhite,
                  size: 24,
                ),
              ),
              SizedBox(height: AppConstants.spacingMd),
              // Title
              Text(
                widget.feature.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: AppConstants.spacingSm),
              // Description
              Text(
                widget.feature.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

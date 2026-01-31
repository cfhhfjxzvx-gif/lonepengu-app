import 'package:flutter/material.dart';
import '../../../../core/design/lp_design.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/responsive_builder.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: ResponsiveBuilder(
        builder: (context, deviceType) {
          final isDesktop = deviceType == DeviceType.desktop;
          final isTablet = deviceType == DeviceType.tablet;
          final isMobile = deviceType == DeviceType.mobile;

          final logoSize = isMobile ? 120.0 : (isTablet ? 160.0 : 180.0);

          return AppPage(
            child: AppMaxWidth(
              maxWidth: isDesktop
                  ? 1200
                  : (isTablet ? 800 : AppConstants.maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Gap.xl,
                  AppLogo(
                    size: logoSize,
                    withShadow: true,
                    borderRadius: LPRadius.xl,
                  ),
                  const Gap(height: 32),
                  _buildHeroSection(context, isDesktop),
                  const Gap(height: LPSpacing.xxl),
                  _buildFeatureCards(context, deviceType),
                  const Gap(height: LPSpacing.xxl),
                  _buildCTASection(context),
                  const Gap(height: LPSpacing.xl),
                  _buildFooter(context),
                  Gap.xl,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        Text(
          AppConstants.appTagline,
          style: isDesktop ? LPText.displayMD : LPText.hLG,
          textAlign: TextAlign.center,
        ),
        Gap(height: LPSpacing.md),
        AppPill(
          label: AppConstants.socialPlatforms,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          textColor: Theme.of(context).colorScheme.onSurfaceVariant,
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
        color: LPColors.accent,
      ),
      _FeatureData(
        icon: Icons.calendar_month_rounded,
        title: 'Scheduling & Publishing',
        description:
            'Plan and publish content across all platforms from one place',
        color: LPColors.secondary,
      ),
      _FeatureData(
        icon: Icons.analytics_rounded,
        title: 'Analytics Dashboard',
        description:
            'Track performance and grow your audience with smart insights',
        color: LPColors.coral,
      ),
    ];

    if (deviceType == DeviceType.mobile) {
      return Column(
        children: features
            .map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: LPSpacing.md),
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
                padding: const EdgeInsets.symmetric(horizontal: LPSpacing.xs),
                child: _FeatureCard(feature: feature),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return AppMaxWidth(
      maxWidth: AppConstants.maxCardWidth,
      child: Column(
        children: [
          AppButton.primary(
            label: 'Get Started',
            icon: Icons.arrow_forward_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              );
            },
            fullWidth: true,
          ),
          const Gap(height: LPSpacing.md),
          AppButton.secondary(
            label: 'Sign In',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignInScreen()),
              );
            },
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Text(
      'By continuing, you agree to Terms & Privacy',
      style: LPText.caption,
      textAlign: TextAlign.center,
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      padding: const EdgeInsets.all(LPSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBox(
            icon: feature.icon,
            iconColor: LPColors.textOnPrimary,
            backgroundColor: feature.color,
            size: 48,
          ),
          const Gap(height: LPSpacing.md),
          Text(feature.title, style: LPText.hSM),
          const Gap(height: LPSpacing.xs),
          Text(feature.description, style: LPText.bodyMD),
        ],
      ),
    );
  }
}

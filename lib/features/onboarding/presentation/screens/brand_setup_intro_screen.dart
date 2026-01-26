import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/responsive_builder.dart';

import '../../../../core/widgets/app_background.dart';

class BrandSetupIntroScreen extends StatelessWidget {
  const BrandSetupIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: ResponsiveBuilder(
          builder: (context, deviceType) {
            return Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.maxContentWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo at top - 70px
                        const Center(
                          child: AppLogo(size: 70, borderRadius: 12),
                        ),

                        SizedBox(height: AppConstants.spacingXl),

                        // Title
                        Text(
                          'Brand Kit Setup',
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: AppConstants.spacingMd),

                        Text(
                          "Let's set up your brand identity to create consistent, on-brand content.",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: AppConstants.spacingXxl),

                        // Setup steps
                        _buildSetupStep(
                          context,
                          number: 1,
                          icon: Icons.image_outlined,
                          title: 'Upload logo',
                          description:
                              'Add your brand logo for watermarks and posts',
                          color: AppColors.frostPurple,
                        ),

                        SizedBox(height: AppConstants.spacingMd),

                        _buildSetupStep(
                          context,
                          number: 2,
                          icon: Icons.palette_outlined,
                          title: 'Choose colors & fonts',
                          description: 'Define your brand\'s visual identity',
                          color: AppColors.auroraTeal,
                        ),

                        SizedBox(height: AppConstants.spacingMd),

                        _buildSetupStep(
                          context,
                          number: 3,
                          icon: Icons.record_voice_over_outlined,
                          title: 'Set brand voice',
                          description: 'Tell us how your brand communicates',
                          color: AppColors.sunsetCoral,
                        ),

                        SizedBox(height: AppConstants.spacingXxl),

                        // Start Setup Button
                        PrimaryButton(
                          text: 'Start Setup',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () => context.push(AppRoutes.brandKit),
                        ),

                        SizedBox(height: AppConstants.spacingMd),

                        Center(
                          child: TextButton(
                            onPressed: () => context.push(AppRoutes.home),
                            child: Text(
                              'Skip for now',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.grey500),
                            ),
                          ),
                        ),
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

  Widget _buildSetupStep(
    BuildContext context, {
    required int number,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.iceWhite,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.penguinBlack.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Step number with icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Stack(
              children: [
                Center(child: Icon(icon, color: color, size: 28)),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$number',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.iceWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: AppConstants.spacingMd),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: AppConstants.spacingXs),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Arrow indicator
          Icon(Icons.chevron_right_rounded, color: AppColors.grey400),
        ],
      ),
    );
  }
}

import 'package:lone_pengu/core/design/lp_design.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/responsive_builder.dart';

class BrandKitScreen extends StatelessWidget {
  const BrandKitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, deviceType) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.maxContentWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LPColors.accentGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.palette_rounded,
                          size: 56,
                          color: LPColors.surface,
                        ),
                      ),
                      SizedBox(height: AppConstants.spacingXl),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingMd,
                          vertical: AppConstants.spacingSm,
                        ),
                        decoration: BoxDecoration(
                          color: LPColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusXl,
                          ),
                        ),
                        child: Text(
                          'Coming Soon',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: LPColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      SizedBox(height: AppConstants.spacingMd),
                      Text(
                        'Brand Kit',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppConstants.spacingMd),
                      Text(
                        'We\'re building an amazing brand kit experience for you.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppConstants.spacingXxl),
                      PrimaryButton(
                        text: 'Go to Home',
                        icon: Icons.home_rounded,
                        onPressed: () => context.go(AppRoutes.home),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

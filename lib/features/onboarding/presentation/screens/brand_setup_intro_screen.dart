import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/lp_design.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../routes/root_router.dart';
import '../../../../features/brand_kit/presentation/screens/brand_kit_screen.dart';

class BrandSetupIntroScreen extends StatelessWidget {
  const BrandSetupIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      body: ResponsiveBuilder(
        builder: (context, deviceType) {
          return Center(
            child: SingleChildScrollView(
              padding: LPSpacing.page,
              child: AppMaxWidth(
                maxWidth: 600,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppLogo(size: 70, borderRadius: 12)),
                    Gap.xl,
                    Text(
                      'Brand Kit Setup',
                      style: LPText.hLG,
                      textAlign: TextAlign.center,
                    ),
                    Gap.sm,
                    Text(
                      "Let's set up your brand identity to create consistent, on-brand content.",
                      style: LPText.bodyLG,
                      textAlign: TextAlign.center,
                    ),
                    Gap.xxl,
                    _buildSetupStep(
                      context,
                      number: 1,
                      icon: Icons.image_outlined,
                      title: 'Upload logo',
                      description:
                          'Add your brand logo for watermarks and posts',
                      color: LPColors.secondary,
                    ),
                    Gap.md,
                    _buildSetupStep(
                      context,
                      number: 2,
                      icon: Icons.palette_outlined,
                      title: 'Choose colors & fonts',
                      description: 'Define your brand\'s visual identity',
                      color: LPColors.primary,
                    ),
                    Gap.md,
                    _buildSetupStep(
                      context,
                      number: 3,
                      icon: Icons.record_voice_over_outlined,
                      title: 'Set brand voice',
                      description: 'Tell us how your brand communicates',
                      color: LPColors.coral,
                    ),
                    Gap.xxl,
                    AppButton.primary(
                      label: 'Start Setup',
                      icon: Icons.arrow_forward_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BrandKitScreen(),
                          ),
                        );
                      },
                      fullWidth: true,
                    ),
                    Gap.md,
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          // Skip marks onboarding as completed
                          final auth = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          await auth.completeOnboarding();

                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => RootRouter()),
                              (route) => false,
                            );
                          }
                        },
                        child: Text(
                          'Skip for now',
                          style: LPText.labelMD.copyWith(
                            color: LPColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
    return AppCard(
      padding: LPSpacing.card,
      child: Row(
        children: [
          AppIconBox(
            icon: icon,
            iconColor: color,
            backgroundColor: color.withValues(alpha: 0.1),
            size: 56,
            borderRadius: LPRadius.smBorder,
          ),
          Gap.md,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: LPText.hSM),
                Gap(height: LPSpacing.xxs),
                Text(description, style: LPText.bodySM),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: LPColors.divider),
        ],
      ),
    );
  }
}

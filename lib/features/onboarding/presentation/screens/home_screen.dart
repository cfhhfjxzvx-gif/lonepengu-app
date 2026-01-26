import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../brand_kit/data/brand_kit_storage.dart';
import '../../../brand_kit/domain/brand_kit_model.dart';
import '../../../content_studio/data/draft_storage.dart';
import '../widgets/home_top_header.dart';
import '../widgets/quick_action_chips.dart';
import '../../../../core/widgets/premium_feature_card.dart';

import '../../../../core/widgets/app_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BrandKit? _brandKit;
  bool _isLoading = true;
  int _draftCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final kit = await BrandKitStorage.loadBrandKit();
    final drafts = await DraftStorage.loadAllDrafts();
    if (mounted) {
      setState(() {
        _brandKit = kit;
        _draftCount = drafts.length;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBrandKitValid = _brandKit != null && _brandKit!.isValid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AppBackground(
              child: ResponsiveBuilder(
                builder: (context, deviceType) {
                  return SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Premium Header
                            HomeTopHeader(
                              brandKit: _brandKit,
                              draftCount: _draftCount,
                              onDraftsTap: () => context
                                  .push(AppRoutes.drafts)
                                  .then((_) => _loadData()),
                            ),

                            const SizedBox(height: 8),

                            // 2. Quick Actions
                            QuickActionChipsRow(
                              onNewCaption: () =>
                                  _navigateToModule(AppRoutes.contentStudio),
                              onNewCarousel: () =>
                                  _navigateToModule(AppRoutes.contentStudio),
                              onSchedule: () =>
                                  _navigateToModule(AppRoutes.scheduler),
                            ),

                            const SizedBox(height: 24),

                            // 3. Setup Section
                            _buildSectionTitle('Setup'),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spacingLg,
                              ),
                              child: PremiumFeatureCard(
                                title: 'Brand Kit',
                                subtitle: isBrandKitValid
                                    ? 'Everything looks set!'
                                    : 'Complete your setup to unlock AI features',
                                icon: isBrandKitValid
                                    ? Icons.verified_rounded
                                    : Icons.palette_outlined,
                                accentColor: AppColors.auroraTeal,
                                badgeText: isBrandKitValid
                                    ? 'Completed ✅'
                                    : 'Setup Required',
                                badgeType: isBrandKitValid
                                    ? PremiumBadgeType.completed
                                    : PremiumBadgeType.comingSoon,
                                onTap: () => context
                                    .push(AppRoutes.brandKit)
                                    .then((_) => _loadData()),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 4. Powered Tools Section
                            _buildSectionTitle('Powered Tools'),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spacingLg,
                              ),
                              child: Column(
                                children: [
                                  // Content Studio (Hero)
                                  PremiumFeatureCard(
                                    title: 'Content Studio',
                                    subtitle:
                                        'AI captions, 4K images & smart carousels',
                                    icon: Icons.auto_awesome_rounded,
                                    accentColor: AppColors.arcticBlue,
                                    badgeText: 'AI Powered',
                                    badgeType: PremiumBadgeType.ai,
                                    onTap: () => _navigateToModule(
                                      AppRoutes.contentStudio,
                                    ),
                                  ),

                                  // Other tools
                                  PremiumFeatureCard(
                                    title: 'Post Editor',
                                    subtitle: 'Visual adjustments and branding',
                                    icon: Icons.edit_rounded,
                                    accentColor: AppColors.frostPurple,
                                    onTap: () =>
                                        _navigateToModule(AppRoutes.editor),
                                  ),
                                  PremiumFeatureCard(
                                    title: 'Scheduling',
                                    subtitle:
                                        'Automate your multi-channel presence',
                                    icon: Icons.calendar_month_rounded,
                                    accentColor: AppColors.sunsetCoral,
                                    badgeText: 'Coming Soon',
                                    badgeType: PremiumBadgeType.comingSoon,
                                    onTap: () =>
                                        context.push(AppRoutes.scheduler),
                                  ),
                                  PremiumFeatureCard(
                                    title: 'Analytics',
                                    subtitle: 'Deep insights into your growth',
                                    icon: Icons.insights_rounded,
                                    accentColor: AppColors.grey400,
                                    badgeText: 'Coming Soon',
                                    badgeType: PremiumBadgeType.comingSoon,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 48),
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

  void _navigateToModule(String route) {
    context.push(route).then((_) => _loadData());
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppConstants.spacingLg, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.grey400,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

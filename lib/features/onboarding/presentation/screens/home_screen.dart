import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/lp_design.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../brand_kit/data/brand_kit_storage.dart';
import '../../../brand_kit/domain/brand_kit_model.dart';
import '../../../content_studio/data/draft_storage.dart';
import '../widgets/home_top_header.dart';
import '../widgets/quick_action_chips.dart';
import '../../../../core/widgets/premium_feature_card.dart';

/// HomeScreen - Fully migrated to LP Design System
///
/// Uses:
/// - LPColors for all colors
/// - LPSpacing / Gap for spacing
/// - LPText for typography
/// - AppBackground for layout
/// - AppCard for cards
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

    return AppScaffold(
      body: _isLoading
          ? const AppLoading(message: 'Loading your workspace...')
          : AppPage(
              padding: EdgeInsets.zero,
              child: ResponsiveBuilder(
                builder: (context, deviceType) {
                  return AppMaxWidth(
                    maxWidth: 520,
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

                        Gap.xs,

                        // 2. Quick Actions
                        QuickActionChipsRow(
                          onNewCaption: () =>
                              _navigateToModule(AppRoutes.contentStudio),
                          onNewCarousel: () =>
                              _navigateToModule(AppRoutes.contentStudio),
                          onSchedule: () =>
                              _navigateToModule(AppRoutes.scheduler),
                        ),

                        Gap.lg,

                        // 3. Setup Section
                        _buildSectionHeader('Setup'),
                        Padding(
                          padding: LPSpacing.pageH,
                          child: _BrandKitCard(
                            isValid: isBrandKitValid,
                            onTap: () => context
                                .push(AppRoutes.brandKit)
                                .then((_) => _loadData()),
                          ),
                        ),

                        Gap.md,

                        // 4. Powered Tools Section
                        _buildSectionHeader('Powered Tools'),
                        Padding(
                          padding: LPSpacing.pageH,
                          child: Column(
                            children: [
                              // Content Studio (Hero)
                              PremiumFeatureCard(
                                title: 'Content Studio',
                                subtitle:
                                    'AI captions, 4K images & smart carousels',
                                icon: Icons.auto_awesome_rounded,
                                accentColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                badgeText: 'AI Powered',
                                badgeType: PremiumBadgeType.ai,
                                onTap: () =>
                                    _navigateToModule(AppRoutes.contentStudio),
                              ),

                              Gap.sm,

                              // Other tools
                              PremiumFeatureCard(
                                title: 'Post Editor',
                                subtitle: 'Visual adjustments and branding',
                                icon: Icons.edit_rounded,
                                accentColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                onTap: () =>
                                    _navigateToModule(AppRoutes.editor),
                              ),

                              Gap.sm,

                              PremiumFeatureCard(
                                title: 'Scheduling',
                                subtitle:
                                    'Automate your multi-channel presence',
                                icon: Icons.calendar_month_rounded,
                                accentColor: Theme.of(
                                  context,
                                ).colorScheme.tertiary,
                                onTap: () => context.push(AppRoutes.scheduler),
                              ),

                              Gap.sm,

                              PremiumFeatureCard(
                                title: 'Analytics',
                                subtitle: 'Deep insights into your growth',
                                icon: Icons.insights_rounded,
                                accentColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                onTap: () => context.push(AppRoutes.analytics),
                              ),
                            ],
                          ),
                        ),

                        Gap.xxl,
                      ],
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: LPSpacing.md, bottom: LPSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// INTERNAL WIDGETS (using LP Design System)
// ═══════════════════════════════════════════

/// Brand Kit status card
class _BrandKitCard extends StatelessWidget {
  final bool isValid;
  final VoidCallback onTap;

  const _BrandKitCard({super.key, required this.isValid, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: LPSpacing.card,
      child: Row(
        children: [
          // Icon
          AppIconBox(
            icon: isValid ? Icons.verified_rounded : Icons.palette_outlined,
            size: 48,
            iconColor: theme.colorScheme.secondary,
            backgroundColor: theme.colorScheme.secondaryContainer,
          ),
          Gap.md,
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Brand Kit',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gap.sm,
                    AppPill(
                      label: isValid ? 'Completed ✅' : 'Setup Required',
                      backgroundColor: isValid
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.errorContainer,
                      textColor: isValid
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.error,
                      isSmall: true,
                    ),
                  ],
                ),
                Gap.xxs,
                Text(
                  isValid
                      ? 'Everything looks set!'
                      : 'Complete your setup to unlock AI features',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Arrow
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// INTERNAL WIDGETS (using LP Design System)
// ═══════════════════════════════════════════

/// Tool feature card

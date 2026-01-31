import 'package:flutter/material.dart';
import '../../../../core/design/lp_design.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../brand_kit/data/brand_kit_storage.dart';
import '../../../brand_kit/domain/brand_kit_model.dart';
import '../../../content_studio/data/draft_storage.dart';
import '../widgets/home_top_header.dart';
import '../widgets/quick_action_chips.dart';
import '../../../../core/widgets/premium_feature_card.dart';
import '../../../brand_kit/presentation/screens/brand_kit_screen.dart';
import '../../../content_studio/presentation/screens/content_studio_screen.dart';
import '../../../content_studio/presentation/screens/drafts_screen.dart';
import '../../../scheduler/presentation/screens/scheduler_screen.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../editor/presentation/screens/editor_screen.dart';
import '../../../editor/data/editor_args.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

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
                          onDraftsTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DraftsScreen(),
                              ),
                            ).then((_) => _loadData());
                          },
                          onSettingsTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            ).then((_) => _loadData());
                          },
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BrandKitScreen(),
                                ),
                              ).then((_) => _loadData());
                            },
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
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SchedulerScreen(),
                                    ),
                                  ).then((_) => _loadData());
                                },
                              ),

                              Gap.sm,

                              PremiumFeatureCard(
                                title: 'Analytics',
                                subtitle: 'Deep insights into your growth',
                                icon: Icons.insights_rounded,
                                accentColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AnalyticsScreen(),
                                    ),
                                  ).then((_) => _loadData());
                                },
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
    Widget? target;
    if (route == AppRoutes.contentStudio) {
      target = const ContentStudioScreen();
    } else if (route == AppRoutes.editor) {
      target = EditorScreen(args: EditorArgs());
    } else if (route == AppRoutes.scheduler) {
      target = const SchedulerScreen();
    }

    if (target != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => target!),
      ).then((_) => _loadData());
    }
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

  const _BrandKitCard({required this.isValid, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;

    // Background color based on validity and theme
    // Light mode: Soft blue tint if valid, white if not
    // Dark mode: Surface container
    final bgColor = isDark
        ? theme.colorScheme.surfaceContainer
        : (isValid
              ? primaryColor.withValues(alpha: 0.05)
              : theme.colorScheme.surface);

    return AppCard.elevated(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      backgroundColor: bgColor,
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isValid ? Icons.business_center_rounded : Icons.palette_outlined,
              size: 28,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Gap.md,

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Brand Kit',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isValid)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Active',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const Gap(height: 4),
                Text(
                  isValid
                      ? 'Your brand assets are ready to use'
                      : 'Setup logo, colors & fonts for AI',
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
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

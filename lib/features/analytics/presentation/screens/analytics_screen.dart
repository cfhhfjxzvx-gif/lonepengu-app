import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/lp_design.dart';
import '../../data/analytics_models.dart';
import '../../data/analytics_service.dart';
import '../widgets/overview_cards.dart';
import '../widgets/engagement_chart.dart';
import '../widgets/platform_breakdown.dart';
import '../widgets/top_posts_list.dart';

/// Main Analytics Dashboard screen
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // Loading states
  bool _isLoadingOverview = true;
  bool _isLoadingTrend = true;
  bool _isLoadingPlatforms = true;
  bool _isLoadingTopPosts = true;

  // Error states
  String? _overviewError;
  String? _trendError;
  String? _platformsError;
  String? _topPostsError;

  // Data
  AnalyticsOverview? _overview;
  List<EngagementPoint> _trendData = [];
  List<PlatformAnalytics> _platforms = [];
  List<TopPost> _topPosts = [];

  // Chart time range
  AnalyticsTimeRange _timeRange = AnalyticsTimeRange.week7;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadOverview(),
      _loadTrendData(),
      _loadPlatforms(),
      _loadTopPosts(),
    ]);
  }

  Future<void> _loadOverview() async {
    setState(() {
      _isLoadingOverview = true;
      _overviewError = null;
    });

    try {
      final overview = await AnalyticsService.getOverview();
      if (mounted) {
        setState(() {
          _overview = overview;
          _isLoadingOverview = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _overviewError = 'Failed to load overview';
          _isLoadingOverview = false;
        });
      }
    }
  }

  Future<void> _loadTrendData() async {
    setState(() {
      _isLoadingTrend = true;
      _trendError = null;
    });

    try {
      final data = await AnalyticsService.getEngagementTrend(_timeRange.days);
      if (mounted) {
        setState(() {
          _trendData = data;
          _isLoadingTrend = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _trendError = 'Failed to load trend data';
          _isLoadingTrend = false;
        });
      }
    }
  }

  Future<void> _loadPlatforms() async {
    setState(() {
      _isLoadingPlatforms = true;
      _platformsError = null;
    });

    try {
      final platforms = await AnalyticsService.getPlatformBreakdown();
      if (mounted) {
        setState(() {
          _platforms = platforms;
          _isLoadingPlatforms = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _platformsError = 'Failed to load platform data';
          _isLoadingPlatforms = false;
        });
      }
    }
  }

  Future<void> _loadTopPosts() async {
    setState(() {
      _isLoadingTopPosts = true;
      _topPostsError = null;
    });

    try {
      final posts = await AnalyticsService.getTopPosts();
      if (mounted) {
        setState(() {
          _topPosts = posts;
          _isLoadingTopPosts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _topPostsError = 'Failed to load top posts';
          _isLoadingTopPosts = false;
        });
      }
    }
  }

  void _onTimeRangeChanged(AnalyticsTimeRange newRange) {
    if (newRange != _timeRange) {
      setState(() {
        _timeRange = newRange;
      });
      _loadTrendData();
    }
  }

  Future<void> _handleExportCSV() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const Gap(width: LPSpacing.sm),
            const Text('Generating export...'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      await AnalyticsService.generateCSVExport();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                Gap(width: LPSpacing.sm),
                Expanded(
                  child: Text(
                    'Analytics export ready (mock)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: LPColors.secondary,
            shape: RoundedRectangleBorder(borderRadius: LPRadius.smBorder),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed. Please try again.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: LPColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: AppBar(
        title: const Text('Analytics'),
        leading: AppIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => context.pop(),
        ),
        actions: [
          AppButton.secondary(
            label: 'Export',
            icon: Icons.download_rounded,
            onTap: _handleExportCSV,
            size: ButtonSize.sm,
          ),
          Gap(width: LPSpacing.sm),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        color: LPColors.primary,
        child: AppPage(
          child: AppMaxWidth(
            maxWidth: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Overview Cards
                _buildSectionWithError(
                  error: _overviewError,
                  onRetry: _loadOverview,
                  child: OverviewCards(
                    overview: _overview,
                    isLoading: _isLoadingOverview,
                  ),
                ),
                Gap.lg,

                // Engagement Chart
                _buildSectionWithError(
                  error: _trendError,
                  onRetry: _loadTrendData,
                  child: EngagementChart(
                    data: _trendData,
                    timeRange: _timeRange,
                    onTimeRangeChanged: _onTimeRangeChanged,
                    isLoading: _isLoadingTrend,
                  ),
                ),
                Gap.lg,

                // Platform Breakdown
                _buildSectionWithError(
                  error: _platformsError,
                  onRetry: _loadPlatforms,
                  child: PlatformBreakdown(
                    platforms: _platforms,
                    isLoading: _isLoadingPlatforms,
                  ),
                ),
                Gap.lg,

                // Top Posts
                _buildSectionWithError(
                  error: _topPostsError,
                  onRetry: _loadTopPosts,
                  child: TopPostsList(
                    posts: _topPosts,
                    isLoading: _isLoadingTopPosts,
                  ),
                ),
                Gap.xxl,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionWithError({
    required String? error,
    required VoidCallback onRetry,
    required Widget child,
  }) {
    if (error != null) {
      return AppCard(
        padding: LPSpacing.page,
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded, size: 40, color: LPColors.error),
            Gap(height: LPSpacing.sm),
            Text(
              error,
              style: LPText.bodyMD.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(height: LPSpacing.md),
            AppButton.secondary(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              onTap: onRetry,
              size: ButtonSize.sm,
            ),
          ],
        ),
      );
    }
    return child;
  }
}

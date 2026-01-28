import 'package:flutter/material.dart';
import 'package:lone_pengu/core/design/lp_design.dart';
import '../../data/analytics_models.dart';

/// Overview cards showing key metrics in a responsive grid
class OverviewCards extends StatelessWidget {
  final AnalyticsOverview? overview;
  final bool isLoading;

  const OverviewCards({super.key, this.overview, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate card width based on available space
        final cardWidth = (constraints.maxWidth - 16) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildMetricCard(
              context: context,
              icon: Icons.article_rounded,
              label: 'Total Posts',
              value: isLoading
                  ? null
                  : (overview?.totalPosts.toString() ?? '--'),
              color: LPColors.primary,
              width: cardWidth,
            ),
            _buildMetricCard(
              context: context,
              icon: Icons.favorite_rounded,
              label: 'Total Engagement',
              value: isLoading ? null : (overview?.formattedEngagement ?? '--'),
              color: LPColors.error,
              width: cardWidth,
            ),
            _buildMetricCard(
              context: context,
              icon: Icons.trending_up_rounded,
              label: 'Avg Rate',
              value: isLoading
                  ? null
                  : (overview?.formattedEngagementRate ?? '--'),
              color: LPColors.accent,
              width: cardWidth,
            ),
            _buildMetricCard(
              context: context,
              icon: Icons.show_chart_rounded,
              label: 'Growth',
              value: isLoading
                  ? null
                  : (overview?.formattedGrowthPercentage ?? '--'),
              color: overview?.isGrowthPositive ?? true
                  ? LPColors.accent
                  : LPColors.error,
              isGrowth: true,
              isPositive: overview?.isGrowthPositive ?? true,
              width: cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String? value,
    required Color color,
    required double width,
    bool isGrowth = false,
    bool isPositive = true,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: width - 6,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(height: 12),
          // Value
          if (value == null)
            // Skeleton loading
            Container(
              height: 24,
              width: 60,
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
              ),
            )
          else
            Row(
              children: [
                if (isGrowth) ...[
                  Icon(
                    isPositive
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 16,
                    color: color,
                  ),
                  SizedBox(width: 2),
                ],
                Flexible(
                  child: Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isGrowth ? color : theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          SizedBox(height: 4),
          // Label
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

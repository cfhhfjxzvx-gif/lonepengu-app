import 'dart:math';
import 'analytics_models.dart';
import '../../content_studio/data/content_models.dart';

/// Mock analytics service for MVP
/// Architecture ready for real API integration later
class AnalyticsService {
  static final Random _random = Random();

  /// Simulates network delay
  static Future<void> _simulateDelay() async {
    await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(300)));
  }

  /// Get analytics overview metrics
  static Future<AnalyticsOverview> getOverview() async {
    await _simulateDelay();

    return AnalyticsOverview(
      totalPosts: 47 + _random.nextInt(20),
      totalEngagement: 12500 + _random.nextInt(5000),
      avgEngagementRate: 3.2 + _random.nextDouble() * 2,
      growthPercentage: -5 + _random.nextDouble() * 25,
    );
  }

  /// Get engagement trend data for specified days
  static Future<List<EngagementPoint>> getEngagementTrend(int days) async {
    await _simulateDelay();

    final now = DateTime.now();
    final points = <EngagementPoint>[];

    // Generate mock data points
    int baseEngagement = 200 + _random.nextInt(100);

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // Add some variance and trend
      final variance = _random.nextInt(100) - 50;
      final trend = ((days - i) * 3).round(); // Slight upward trend
      final value = (baseEngagement + variance + trend).clamp(50, 600);

      points.add(EngagementPoint(date: date, value: value));

      baseEngagement = value;
    }

    return points;
  }

  /// Get platform breakdown analytics
  static Future<List<PlatformAnalytics>> getPlatformBreakdown() async {
    await _simulateDelay();

    return [
      PlatformAnalytics(
        platform: SocialPlatform.instagram,
        postsCount: 18 + _random.nextInt(10),
        engagement: 5200 + _random.nextInt(2000),
        engagementRate: 4.2 + _random.nextDouble() * 2,
      ),
      PlatformAnalytics(
        platform: SocialPlatform.facebook,
        postsCount: 12 + _random.nextInt(8),
        engagement: 3100 + _random.nextInt(1500),
        engagementRate: 2.8 + _random.nextDouble() * 1.5,
      ),
      PlatformAnalytics(
        platform: SocialPlatform.linkedin,
        postsCount: 8 + _random.nextInt(5),
        engagement: 1800 + _random.nextInt(800),
        engagementRate: 3.5 + _random.nextDouble() * 1,
      ),
      PlatformAnalytics(
        platform: SocialPlatform.x,
        postsCount: 9 + _random.nextInt(6),
        engagement: 2400 + _random.nextInt(1000),
        engagementRate: 2.1 + _random.nextDouble() * 1.5,
      ),
    ];
  }

  /// Get top performing posts
  static Future<List<TopPost>> getTopPosts({int limit = 5}) async {
    await _simulateDelay();

    final now = DateTime.now();
    final platforms = SocialPlatform.values;
    final contentTypes = [
      ContentMode.caption,
      ContentMode.image,
      ContentMode.carousel,
    ];
    final captions = [
      'Excited to announce our new product launch! 🚀',
      'Behind the scenes of our latest project',
      '5 tips to boost your productivity today',
      'Thank you for 10K followers! ❤️',
      'New week, new goals. Let\'s make it count!',
      'Check out our latest blog post',
      'Special offer just for you!',
    ];

    final posts = <TopPost>[];

    for (int i = 0; i < limit; i++) {
      final engagement = (5000 - i * 800 + _random.nextInt(500)).clamp(
        500,
        6000,
      );
      posts.add(
        TopPost(
          id: 'post_${i + 1}',
          platform: platforms[_random.nextInt(platforms.length)],
          contentType: contentTypes[_random.nextInt(contentTypes.length)],
          engagement: engagement,
          likes: (engagement * 0.7).round(),
          comments: (engagement * 0.2).round(),
          shares: (engagement * 0.1).round(),
          date: now.subtract(Duration(days: _random.nextInt(14))),
          caption: captions[_random.nextInt(captions.length)],
        ),
      );
    }

    // Sort by engagement descending
    posts.sort((a, b) => b.engagement.compareTo(a.engagement));

    return posts;
  }

  /// Generate mock CSV data for export
  static Future<String> generateCSVExport() async {
    await _simulateDelay();

    final overview = await getOverview();
    final platforms = await getPlatformBreakdown();
    final topPosts = await getTopPosts();

    final buffer = StringBuffer();

    // Header
    buffer.writeln('LonePengu Analytics Export');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('');

    // Overview
    buffer.writeln('OVERVIEW');
    buffer.writeln('Total Posts,${overview.totalPosts}');
    buffer.writeln('Total Engagement,${overview.totalEngagement}');
    buffer.writeln('Avg Engagement Rate,${overview.formattedEngagementRate}');
    buffer.writeln('Growth,${overview.formattedGrowthPercentage}');
    buffer.writeln('');

    // Platform breakdown
    buffer.writeln('PLATFORM BREAKDOWN');
    buffer.writeln('Platform,Posts,Engagement,Engagement Rate');
    for (final p in platforms) {
      buffer.writeln(
        '${p.platform.displayName},${p.postsCount},${p.engagement},${p.engagementRate.toStringAsFixed(1)}%',
      );
    }
    buffer.writeln('');

    // Top posts
    buffer.writeln('TOP POSTS');
    buffer.writeln('Platform,Type,Engagement,Date');
    for (final post in topPosts) {
      buffer.writeln(
        '${post.platform.displayName},${post.contentType.displayName},${post.engagement},${post.formattedDate}',
      );
    }

    return buffer.toString();
  }
}

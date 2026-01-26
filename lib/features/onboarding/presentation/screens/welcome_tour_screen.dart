import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/page_indicator.dart';
import '../../../../core/widgets/responsive_builder.dart';

import '../../../../core/widgets/app_background.dart';

class WelcomeTourScreen extends StatefulWidget {
  const WelcomeTourScreen({super.key});

  @override
  State<WelcomeTourScreen> createState() => _WelcomeTourScreenState();
}

class _WelcomeTourScreenState extends State<WelcomeTourScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_TourPage> _pages = [
    _TourPage(
      icon: Icons.auto_awesome,
      gradientColors: [AppColors.frostPurple, const Color(0xFF6D28D9)],
      title: 'AI that understands your brand',
      description:
          'Our AI learns your unique voice and style to create content that truly represents your brand.',
    ),
    _TourPage(
      icon: Icons.calendar_month_rounded,
      gradientColors: [AppColors.auroraTeal, const Color(0xFF059669)],
      title: 'Plan posts with a smart calendar',
      description:
          'Schedule content weeks in advance with our intuitive calendar. Best times? We\'ll suggest them.',
    ),
    _TourPage(
      icon: Icons.insights_rounded,
      gradientColors: [AppColors.sunsetCoral, const Color(0xFFDC2626)],
      title: 'See what works with analytics',
      description:
          'Track engagement, grow your audience, and understand what content performs best.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.mediumDuration,
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go(AppRoutes.brandSetupIntro);
    }
  }

  void _skipTour() {
    context.go(AppRoutes.brandSetupIntro);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(child: AppBarLogo(size: 32)),
        ),
        title: Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.penguinBlack,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _skipTour,
            child: Text(
              'Skip',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AppBackground(
        child: ResponsiveBuilder(
          builder: (context, deviceType) {
            return Column(
              children: [
                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _TourPageContent(
                        page: _pages[index],
                        deviceType: deviceType,
                      );
                    },
                  ),
                ),

                // Bottom section with indicator and button
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppConstants.maxContentWidth,
                    ),
                    child: Column(
                      children: [
                        // Page indicator
                        PageIndicator(
                          pageCount: _pages.length,
                          currentPage: _currentPage,
                        ),
                        SizedBox(height: AppConstants.spacingXl),

                        // Continue button
                        PrimaryButton(
                          text: _currentPage == _pages.length - 1
                              ? 'Continue to Brand Setup'
                              : 'Next',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: _nextPage,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TourPage {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String description;

  _TourPage({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.description,
  });
}

class _TourPageContent extends StatelessWidget {
  final _TourPage page;
  final DeviceType deviceType;

  const _TourPageContent({required this.page, required this.deviceType});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon container
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: AppConstants.mediumDuration,
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              width: deviceType == DeviceType.mobile ? 160 : 200,
              height: deviceType == DeviceType.mobile ? 160 : 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: page.gradientColors,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: page.gradientColors[0].withValues(alpha: 0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Icon(
                page.icon,
                size: deviceType == DeviceType.mobile ? 72 : 88,
                color: AppColors.iceWhite,
              ),
            ),
          ),

          SizedBox(height: AppConstants.spacingXxl),

          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: deviceType == DeviceType.mobile ? 24 : 32,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppConstants.spacingMd),

          // Description
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              page.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

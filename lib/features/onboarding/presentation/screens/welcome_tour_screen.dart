import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/lp_design.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/page_indicator.dart';
import '../../../../core/widgets/responsive_builder.dart';

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
      gradientColors: [LPColors.primary, LPColors.primaryDark],
      title: 'AI that understands your brand',
      description:
          'Our AI learns your unique voice and style to create content that truly represents your brand.',
    ),
    _TourPage(
      icon: Icons.calendar_month_rounded,
      gradientColors: [LPColors.secondary, LPColors.secondaryDark],
      title: 'Plan posts with a smart calendar',
      description:
          'Schedule content weeks in advance with our intuitive calendar. Best times? We\'ll suggest them.',
    ),
    _TourPage(
      icon: Icons.insights_rounded,
      gradientColors: [LPColors.coral, LPColors.coralDark],
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
        duration: const Duration(milliseconds: 300),
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
    return AppScaffold(
      useSafeArea: true,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8),
          child: AppBarLogo(size: 32),
        ),
        title: Text(AppConstants.appName, style: LPText.hMD),
        actions: [
          TextButton(
            onPressed: _skipTour,
            child: Text(
              'Skip',
              style: LPText.labelMD.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Gap(width: LPSpacing.sm),
        ],
      ),
      body: ResponsiveBuilder(
        builder: (context, deviceType) {
          return Column(
            children: [
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
              Padding(
                padding: LPSpacing.page,
                child: AppMaxWidth(
                  maxWidth: 600,
                  child: Column(
                    children: [
                      PageIndicator(
                        pageCount: _pages.length,
                        currentPage: _currentPage,
                      ),
                      Gap.xxl,
                      AppButton.primary(
                        label: _currentPage == _pages.length - 1
                            ? 'Continue to Brand Setup'
                            : 'Next',
                        icon: Icons.arrow_forward_rounded,
                        onTap: _nextPage,
                        fullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
      padding: LPSpacing.page,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
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
                  color: page.gradientColors[0].withValues(alpha: 0.3),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: deviceType == DeviceType.mobile ? 72 : 88,
              color: Colors.white,
            ),
          ),
          Gap.xxl,
          Text(
            page.title,
            style: deviceType == DeviceType.mobile ? LPText.hLG : LPText.hXL,
            textAlign: TextAlign.center,
          ),
          Gap.md,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              page.description,
              style: LPText.bodyMD,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'LonePengu';
  static const String appTagline =
      'Create, Schedule & Track Social Content — in one place';
  static const String socialPlatforms = 'Instagram • Facebook • LinkedIn • X';

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Max content width
  static const double maxContentWidth = 480.0;
  static const double maxCardWidth = 400.0;

  // Animation durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 350);
  static const Duration longDuration = Duration(milliseconds: 500);
}

/// Route names
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String landing = '/landing';
  static const String signUp = '/sign-up';
  static const String signIn = '/sign-in';
  static const String welcomeTour = '/welcome-tour';
  static const String brandSetupIntro = '/brand-setup-intro';
  static const String brandKit = '/brand-kit';
  static const String home = '/home';
  static const String contentStudio = '/content-studio';
  static const String drafts = '/drafts';
  static const String editor = '/editor';
  static const String scheduler = '/scheduler';
  static const String analytics = '/analytics';
  static const String settings = '/settings';
  static const String accounts = '/accounts';
  static const String notifications = '/notifications';
}

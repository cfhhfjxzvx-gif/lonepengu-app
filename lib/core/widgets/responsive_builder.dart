import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Device type enumeration
enum DeviceType { mobile, tablet, desktop }

/// Responsive builder widget that provides device type based on screen width
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= AppConstants.desktopBreakpoint) {
      return DeviceType.desktop;
    } else if (width >= AppConstants.tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;
  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;
  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = getDeviceType(context);
        return builder(context, deviceType);
      },
    );
  }
}

/// Extension for responsive values based on device type
extension ResponsiveExtension on BuildContext {
  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    final deviceType = ResponsiveBuilder.getDeviceType(this);
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}

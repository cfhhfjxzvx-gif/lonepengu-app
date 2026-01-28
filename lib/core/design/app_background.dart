/// LonePengu Background - Global screen background
///
/// Usage: AppBackground(child: YourScreen())
/// Provides consistent background with SafeArea + scroll safety

import 'package:flutter/material.dart';
import 'colors.dart';
import 'spacing.dart';

/// Global app background with gradient
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;
  final bool useScroll;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool resizeToAvoidBottomInset;

  const AppBackground({
    super.key,
    required this.child,
    this.useSafeArea = true,
    this.useScroll = true,
    this.padding,
    this.backgroundColor,
    this.gradient,
    this.resizeToAvoidBottomInset = true,
  });

  /// Background without scroll (for screens with custom scrolls)
  const AppBackground.noScroll({
    super.key,
    required this.child,
    this.useSafeArea = true,
    this.padding,
    this.backgroundColor,
    this.gradient,
    this.resizeToAvoidBottomInset = true,
  }) : useScroll = false;

  /// Background with plain color (no gradient)
  factory AppBackground.plain({
    Key? key,
    required Widget child,
    bool useSafeArea = true,
    bool useScroll = true,
    EdgeInsets? padding,
    Color? color,
  }) => AppBackground(
    key: key,
    useSafeArea: useSafeArea,
    useScroll: useScroll,
    padding: padding,
    backgroundColor: color ?? LPColors.background,
    gradient: null,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Apply scroll if needed
    if (useScroll) {
      content = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: content,
      );
    }

    // Apply padding if provided
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    // Apply SafeArea if needed
    if (useSafeArea) {
      content = SafeArea(
        bottom: false, // Usually handled by bottom nav
        child: content,
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor ?? LPColors.getBackgroundColor(context),
      child: content,
    );
  }
}

/// Scaffold wrapper with consistent styling
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final bool useSafeArea;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.backgroundGradient,
    this.useSafeArea = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    // Apply SafeArea if needed
    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor ?? LPColors.getBackgroundColor(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: content,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      ),
    );
  }
}

/// Standard page wrapper with scroll safety
class AppPage extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool scroll;

  const AppPage({
    super.key,
    required this.child,
    this.padding,
    this.scroll = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    } else {
      content = Padding(padding: LPSpacing.page, child: content);
    }

    if (scroll) {
      content = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: content,
      );
    }

    return SafeArea(bottom: false, child: content);
  }
}

/// Max width constraint for web (responsive)
class AppMaxWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  const AppMaxWidth({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
    );
  }
}

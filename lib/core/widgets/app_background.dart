import 'package:flutter/material.dart';

/// A premium, subtle gradient background for the LonePengu app.
/// This widget provides a consistent, high-end SaaS feel across all screens.
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;

  const AppBackground({
    super.key,
    required this.child,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC), // Ice White
            Color(0xFFEAF3FF), // Premium Light Blue
            Color(0xFFF8FAFC), // Subtle Return to White
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: useSafeArea ? SafeArea(child: child) : child,
    );
  }
}

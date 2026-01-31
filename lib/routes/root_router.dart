import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../features/onboarding/presentation/screens/home_screen.dart';
import '../features/onboarding/presentation/screens/landing_screen.dart';

/// RootRouter - The single entry point for app navigation tree.
/// It observes AuthProvider and returns exactly ONE widget based on state.
class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    // We use context.select or Consumer to react only to relevant auth state changes.
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // 1. Initial/Loading state
        // Since AppBootstrap handles the initial splash, this case should be minimal.
        // We use a themed Scaffold to avoid "blank" white screens in dark mode.
        if (auth.state == AuthState.initial ||
            auth.state == AuthState.loading) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Authenticated State
        if (auth.state == AuthState.authenticated) {
          // DIRECT TO HOME: As requested, authenticated users land on Home.
          // Setup state is handled via UI cards on the Home screen.
          return const HomeScreen();
        }

        // 3. Unauthenticated State (Landing/Login)
        // Default fallback is LandingScreen
        return const LandingScreen();
      },
    );
  }
}

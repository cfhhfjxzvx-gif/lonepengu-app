import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../features/onboarding/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/landing_screen.dart';
import '../features/onboarding/presentation/screens/sign_up_screen.dart';
import '../features/onboarding/presentation/screens/sign_in_screen.dart';
import '../features/onboarding/presentation/screens/welcome_tour_screen.dart';
import '../features/onboarding/presentation/screens/brand_setup_intro_screen.dart';
import '../features/brand_kit/presentation/screens/brand_kit_screen.dart';
import '../features/onboarding/presentation/screens/home_screen.dart';
import '../features/content_studio/data/content_models.dart';
import '../features/editor/data/editor_args.dart';
import '../features/content_studio/presentation/screens/content_studio_screen.dart';
import '../features/content_studio/presentation/screens/drafts_screen.dart';
import '../features/editor/presentation/screens/editor_screen.dart';
import '../features/content_studio/presentation/screens/scheduler_screen.dart';

/// Application router configuration using GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              child,
        ),
      ),
      // Landing Screen
      GoRoute(
        path: AppRoutes.landing,
        name: 'landing',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LandingScreen(),
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      // Sign Up
      GoRoute(
        path: AppRoutes.signUp,
        name: 'signUp',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignUpScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
      // Sign In
      GoRoute(
        path: AppRoutes.signIn,
        name: 'signIn',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignInScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
      // Welcome Tour
      GoRoute(
        path: AppRoutes.welcomeTour,
        name: 'welcomeTour',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WelcomeTourScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
        ),
      ),
      // Brand Setup Intro
      GoRoute(
        path: AppRoutes.brandSetupIntro,
        name: 'brandSetupIntro',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BrandSetupIntroScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
      // Brand Kit (New full wizard)
      GoRoute(
        path: AppRoutes.brandKit,
        name: 'brandKit',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BrandKitScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
      // Home
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      // Content Studio
      GoRoute(
        path: AppRoutes.contentStudio,
        name: 'contentStudio',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ContentStudioScreen(),
          transitionDuration: const Duration(milliseconds: 240),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
        ),
      ),
      // Drafts
      GoRoute(
        path: AppRoutes.drafts,
        name: 'drafts',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DraftsScreen(),
          transitionDuration: const Duration(milliseconds: 240),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
        ),
      ),
      // Editor Placeholder
      GoRoute(
        path: AppRoutes.editor,
        name: 'editor',
        pageBuilder: (context, state) {
          EditorArgs args;
          if (state.extra is EditorArgs) {
            args = state.extra as EditorArgs;
          } else if (state.extra is ContentDraft) {
            args = EditorArgs(draft: state.extra as ContentDraft);
          } else {
            args = EditorArgs();
          }

          return CustomTransitionPage(
            key: state.pageKey,
            child: EditorScreen(args: args),
            transitionDuration: const Duration(milliseconds: 240),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    ),
                    child: child,
                  );
                },
          );
        },
      ),
      // Scheduler Placeholder
      GoRoute(
        path: AppRoutes.scheduler,
        name: 'scheduler',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SchedulerScreen(),
          transitionDuration: const Duration(milliseconds: 240),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.sunsetCoral,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.landing),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

class AppColors {
  static const Color sunsetCoral = Color(0xFFF43F5E);
}

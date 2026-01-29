import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../core/design/lp_design.dart';
import '../core/providers/auth_provider.dart';
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
import '../features/scheduler/presentation/screens/scheduler_screen.dart';
import '../features/scheduler/data/scheduler_models.dart';
import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/account_management/presentation/screens/account_management_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';

/// Application router configuration using GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: AuthProvider.instance,
    redirect: (context, state) {
      final authProvider = AuthProvider.instance;
      final isAuthenticated = authProvider.isAuthenticated;
      final isInitial = authProvider.state == AuthState.initial;
      final isAuthRoute =
          state.matchedLocation == AppRoutes.landing ||
          state.matchedLocation == AppRoutes.signIn ||
          state.matchedLocation == AppRoutes.signUp;

      // 1. Always stay on Splash ONLY if initializing (cold boot)
      // Do NOT redirect on isLoading (let UI handle spinners)
      if (isInitial) {
        return AppRoutes.splash;
      }

      // 2. If authenticated:
      // - If trying to access Auth pages (Login/SignUp) -> Redirect to Home
      // - If trying to access Landing -> Redirect to Home
      // - SPLASH: Do NOT redirect. Let SplashScreen handling navigation after animation.
      if (isAuthenticated) {
        if (isAuthRoute || state.matchedLocation == AppRoutes.landing) {
          return AppRoutes.home;
        }
        return null;
      }

      // 3. If NOT authenticated:
      // - If trying to access Private pages (Home, Editor, etc.) -> Redirect to Landing
      // - SPLASH: Do NOT redirect. Let SplashScreen handle navigation.
      // - Allow Auth routes and Landing
      if (!isAuthRoute &&
          state.matchedLocation != AppRoutes.splash &&
          state.matchedLocation != AppRoutes.landing) {
        return AppRoutes.landing;
      }

      return null;
    },
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
      // Scheduler
      GoRoute(
        path: AppRoutes.scheduler,
        name: 'scheduler',
        pageBuilder: (context, state) {
          ScheduleArgs? args;
          if (state.extra is ScheduleArgs) {
            args = state.extra as ScheduleArgs;
          }

          return CustomTransitionPage(
            key: state.pageKey,
            child: SchedulerScreen(args: args),
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
      // Analytics
      GoRoute(
        path: AppRoutes.analytics,
        name: 'analytics',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AnalyticsScreen(),
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
      // Settings
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
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
      // Account Management
      GoRoute(
        path: AppRoutes.accounts,
        name: 'accounts',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AccountManagementScreen(),
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
      // Notifications
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationsScreen(),
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
            Icon(Icons.error_outline, size: 64, color: LPColors.error),
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

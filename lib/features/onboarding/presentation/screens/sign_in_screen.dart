import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/lp_design.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/responsive_builder.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    LoggerService.auth('Sign-in requested', {
      'email': _emailController.text.trim(),
    });

    try {
      final success = await AuthProvider.instance.loginWithEmail(
        _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        LoggerService.auth('Sign-in successful, navigating to home');
        context.go(AppRoutes.home);
      } else {
        final error = AuthProvider.instance.errorMessage ?? 'Sign in failed';
        LoggerService.auth('Sign-in failed', {'error': error});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: LPColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      LoggerService.error('Sign-in screen error', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'An unexpected error occurred. Please try again.',
            ),
            backgroundColor: LPColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        LoggerService.auth('Sign-in loader stopped');
      }
    }
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password reset coming soon!'),
        backgroundColor: LPColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: LPRadius.smBorder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => context.pop(),
        ),
      ),
      body: ResponsiveBuilder(
        builder: (context, deviceType) {
          return Center(
            child: SingleChildScrollView(
              padding: LPSpacing.page,
              child: AppMaxWidth(
                maxWidth: 400,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: AppLogo(size: 90, borderRadius: 16)),
                      Gap.xl,
                      Text(
                        'Welcome back',
                        style: LPText.hLG,
                        textAlign: TextAlign.center,
                      ),
                      Gap.xs,
                      Text(
                        'Sign in to continue managing your content',
                        style: LPText.bodyMD,
                        textAlign: TextAlign.center,
                      ),
                      Gap.xxl,
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        validator: _validateEmail,
                      ),
                      Gap.md,
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleSignIn(),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                        ),
                        suffixIcon: AppIconButton(
                          size: 32,
                          onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        validator: _validatePassword,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: Text(
                            'Forgot password?',
                            style: LPText.labelSM.copyWith(
                              color: LPColors.primary,
                            ),
                          ),
                        ),
                      ),
                      Gap.lg,
                      AppButton.primary(
                        label: 'Sign In',
                        isLoading: _isLoading,
                        onTap: _handleSignIn,
                        fullWidth: true,
                      ),
                      Gap.xl,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: LPText.bodySM),
                          TextButton(
                            onPressed: () => context.push(AppRoutes.signUp),
                            child: Text(
                              'Create account',
                              style: LPText.labelSM.copyWith(
                                color: LPColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/lp_design.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/responsive_builder.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    return null;
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
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Navigate to welcome tour
    context.go(AppRoutes.welcomeTour);
  }

  void _handleGoogleSignUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Google Sign-In will be available soon!'),
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
                        'Create your account',
                        style: LPText.hLG,
                        textAlign: TextAlign.center,
                      ),
                      Gap.xs,
                      Text(
                        'Start managing your social media with AI',
                        style: LPText.bodyMD,
                        textAlign: TextAlign.center,
                      ),
                      Gap.xxl,
                      AppTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                        ),
                        validator: _validateName,
                      ),
                      Gap.md,
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
                        hint: 'Create a password (min 6 characters)',
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleSignUp(),
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
                      Gap.xl,
                      AppButton.primary(
                        label: 'Create Account',
                        isLoading: _isLoading,
                        onTap: _handleSignUp,
                        fullWidth: true,
                      ),
                      Gap.lg,
                      // Divider
                      Row(
                        children: [
                          const Expanded(child: AppDivider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: LPSpacing.md,
                            ),
                            child: Text('or', style: LPText.bodySM),
                          ),
                          const Expanded(child: AppDivider()),
                        ],
                      ),
                      Gap.lg,
                      AppButton.secondary(
                        label: 'Continue with Google',
                        onTap: _handleGoogleSignUp,
                        icon: Icons
                            .login_rounded, // Fallback for custom Google icon
                        fullWidth: true,
                      ),
                      Gap.xl,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: LPText.bodySM,
                          ),
                          TextButton(
                            onPressed: () => context.push(AppRoutes.signIn),
                            child: Text(
                              'Sign In',
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

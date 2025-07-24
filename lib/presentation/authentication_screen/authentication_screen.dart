import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/bottom_links_widget.dart';
import './widgets/divider_widget.dart';
import './widgets/email_input_widget.dart';
import './widgets/forgot_password_widget.dart';
import './widgets/google_signin_button_widget.dart';
import './widgets/login_button_widget.dart';
import './widgets/logo_widget.dart';
import './widgets/password_input_widget.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _emailError;
  String? _passwordError;
  bool _isFormValid = false;

  // Mock credentials for testing
  final Map<String, String> _mockCredentials = {
    'admin@taxcalc.com': 'admin123',
    'user@taxcalc.com': 'user123',
    'test@gmail.com': 'test123',
    '9876543210': 'mobile123',
  };

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _emailError = null;
      _passwordError = null;

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Email validation
      if (email.isNotEmpty) {
        if (!_isValidEmailOrPhone(email)) {
          _emailError = 'Please enter a valid email or phone number';
        }
      }

      // Password validation
      if (password.isNotEmpty && password.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      }

      _isFormValid = email.isNotEmpty &&
          password.isNotEmpty &&
          _emailError == null &&
          _passwordError == null;
    });
  }

  bool _isValidEmailOrPhone(String input) {
    // Email regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    // Indian phone number regex
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');

    return emailRegex.hasMatch(input) || phoneRegex.hasMatch(input);
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Check mock credentials
    if (_mockCredentials.containsKey(email) &&
        _mockCredentials[email] == password) {
      // Success - trigger haptic feedback
      HapticFeedback.lightImpact();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main-dashboard');
      }
    } else {
      // Invalid credentials
      setState(() {
        _emailError = 'Invalid email/phone or password';
        _passwordError = 'Please check your credentials';
      });

      HapticFeedback.heavyImpact();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    // Simulate Google Sign-In process
    await Future.delayed(const Duration(seconds: 3));

    // Success - trigger haptic feedback
    HapticFeedback.lightImpact();

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/profile-selection-screen');
    }

    setState(() {
      _isGoogleLoading = false;
    });
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Password',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Password reset functionality will be available soon. Please contact support for assistance.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignUp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Up',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Sign up functionality will be available soon. You can use the demo credentials or skip sign in for now.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSkipSignIn() {
    Navigator.pushReplacementNamed(context, '/main-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 92.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8.h),

                  // Logo Section
                  const LogoWidget(),

                  SizedBox(height: 6.h),

                  // Welcome Text
                  Text(
                    'Welcome Back!',
                    style:
                        AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 1.h),

                  Text(
                    'Sign in to continue your tax calculations',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 6.h),

                  // Email Input
                  EmailInputWidget(
                    controller: _emailController,
                    errorText: _emailError,
                    onChanged: (value) => _validateForm(),
                  ),

                  SizedBox(height: 3.h),

                  // Password Input
                  PasswordInputWidget(
                    controller: _passwordController,
                    errorText: _passwordError,
                    onChanged: (value) => _validateForm(),
                  ),

                  SizedBox(height: 2.h),

                  // Forgot Password Link
                  ForgotPasswordWidget(
                    onTap: _handleForgotPassword,
                  ),

                  SizedBox(height: 4.h),

                  // Login Button
                  LoginButtonWidget(
                    isEnabled: _isFormValid,
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),

                  SizedBox(height: 4.h),

                  // Divider
                  const DividerWidget(),

                  SizedBox(height: 4.h),

                  // Google Sign In Button
                  GoogleSigninButtonWidget(
                    onPressed: _handleGoogleSignIn,
                    isLoading: _isGoogleLoading,
                  ),

                  SizedBox(height: 6.h),

                  // Bottom Links
                  BottomLinksWidget(
                    onSignUpTap: _handleSignUp,
                    onSkipTap: _handleSkipSignIn,
                  ),

                  SizedBox(height: 2.h),

                  // Demo Credentials Info
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme
                          .lightTheme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo Credentials:',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'admin@taxcalc.com / admin123\nuser@taxcalc.com / user123\n9876543210 / mobile123',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.8),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

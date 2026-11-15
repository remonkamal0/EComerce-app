import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/custom_text_field.dart';
import 'package:homeplus/ui/core_widgets/language_toggle_pill.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/core_widgets/telegram_theme_switcher.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'create_account_screen.dart';
import 'forgot_password_flow.dart';
import '../main_navigation_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'ahmed@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthViewModel>();
    final success = await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleSocialSignIn(bool isGoogle) async {
    final auth = context.read<AuthViewModel>();
    final success = isGoogle
        ? await auth.signInWithGoogle()
        : await auth.signInWithApple();

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
              );
            }
          },
        ),
        actions: [
          const TelegramThemeToggleButton(),
          const SizedBox(width: 6),
          const LanguageTogglePill(),
          const SizedBox(width: 4),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
              );
            },
            child: Text(
              context.tr('sign_up'),
              style: TextStyle(
                color: accentPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: ResponsiveConstrainedBox(
            maxWidth: ResponsiveLayout.maxFormWidth,
            child: Form(
              key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  context.tr('welcome_back'),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('sign_in_subtitle'),
                  style: TextStyle(
                    fontSize: 15,
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Email or Phone field
                CustomTextField(
                  controller: _emailController,
                  hintText: context.tr('email_or_phone'),
                  prefixIcon: Icon(Icons.mail_outline, color: context.textSecondaryColor),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return context.l10nRead.tr('enter_email_phone');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                CustomTextField(
                  controller: _passwordController,
                  hintText: context.tr('password'),
                  obscureText: _obscurePassword,
                  prefixIcon: Icon(Icons.lock_outline, color: context.textSecondaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: context.textSecondaryColor,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) {
                      return context.l10nRead.tr('password_min_len');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Remember me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: accentPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              setState(() => _rememberMe = val ?? true);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('remember_me'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ForgotPasswordFlow()),
                        );
                      },
                      child: Text(
                        context.tr('forgot_password'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accentPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Primary Sign In Button
                CustomButton(
                  text: context.tr('sign_in'),
                  isLoading: auth.isLoading,
                  onPressed: _handleSignIn,
                ),
                const SizedBox(height: 24),

                // "or" Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: context.dividerColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        context.tr('or'),
                        style: TextStyle(
                          color: context.textSecondaryColor.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: context.dividerColor)),
                  ],
                ),
                const SizedBox(height: 24),

                // Social Sign In Buttons
                _buildSocialButton(
                  context: context,
                  title: context.tr('continue_google'),
                  icon: Image.asset('assets/google-logo.png', width: 22, height: 22),
                  onTap: () => _handleSocialSignIn(true),
                ),
                const SizedBox(height: 12),
                _buildSocialButton(
                  context: context,
                  title: context.tr('continue_apple'),
                  icon: Icon(Icons.apple, size: 22, color: context.textPrimaryColor),
                  onTap: () => _handleSocialSignIn(false),
                ),
                const SizedBox(height: 32),

                // Bottom link: Don't have an account? Sign Up
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${context.tr('dont_have_account')} ',
                        style: TextStyle(
                          color: context.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
                          );
                        },
                        child: Text(
                          context.tr('sign_up'),
                          style: TextStyle(
                            color: accentPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String title,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: context.surfaceBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



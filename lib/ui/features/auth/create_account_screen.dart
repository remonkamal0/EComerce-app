import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/custom_text_field.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'sign_in_screen.dart';
import '../main_navigation_screen.dart';
import '../legal/legal_content_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreeToTerms = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10nRead.tr('agree_terms_snack')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final auth = context.read<AuthViewModel>();
    final success = await auth.signUp(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
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
                MaterialPageRoute(builder: (_) => const SignInScreen()),
              );
            }
          },
        ),
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
                const SizedBox(height: 8),
                Text(
                  context.tr('create_account'),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('join_homeplus'),
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 28),

                // Full Name
                CustomTextField(
                  controller: _nameController,
                  hintText: context.tr('full_name'),
                  prefixIcon: Icon(Icons.person_outline, color: context.textSecondaryColor),
                  validator: (v) => (v == null || v.trim().isEmpty) ? context.l10nRead.tr('enter_your_name') : null,
                ),
                const SizedBox(height: 14),

                // Phone Number
                CustomTextField(
                  controller: _phoneController,
                  hintText: context.tr('phone_number'),
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(Icons.phone_outlined, color: context.textSecondaryColor),
                  validator: (v) => (v == null || v.trim().isEmpty) ? context.l10nRead.tr('enter_phone') : null,
                ),
                const SizedBox(height: 14),

                // Email Address
                CustomTextField(
                  controller: _emailController,
                  hintText: context.tr('email_address'),
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.mail_outline, color: context.textSecondaryColor),
                  validator: (v) {
                    if (v == null || !v.contains('@')) {
                      return context.l10nRead.tr('enter_valid_email');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Password
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

                // Terms Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        activeColor: accentPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) {
                          setState(() => _agreeToTerms = val ?? true);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        children: [
                          Text(
                            context.tr('i_agree_to'),
                            style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LegalContentScreen(title: context.l10nRead.tr('terms_conditions')),
                                ),
                              );
                            },
                            child: Text(
                              context.tr('terms_of_service'),
                              style: TextStyle(
                                fontSize: 12,
                                color: accentPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            context.tr('and_word'),
                            style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LegalContentScreen(title: context.l10nRead.tr('privacy_policy')),
                                ),
                              );
                            },
                            child: Text(
                              context.tr('privacy_policy'),
                              style: TextStyle(
                                fontSize: 12,
                                color: accentPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sign Up Button
                CustomButton(
                  text: context.tr('sign_up'),
                  isLoading: auth.isLoading,
                  onPressed: _handleSignUp,
                ),
                const SizedBox(height: 22),

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
                const SizedBox(height: 22),

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
                const SizedBox(height: 28),

                // Already have an account? Sign In
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${context.tr('already_have_account')} ',
                        style: TextStyle(
                          color: context.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const SignInScreen()),
                          );
                        },
                        child: Text(
                          context.tr('sign_in'),
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



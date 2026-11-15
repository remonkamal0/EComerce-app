import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/custom_text_field.dart';
import 'package:homeplus/ui/core_widgets/lottie_success_view.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'sign_in_screen.dart';

class ForgotPasswordFlow extends StatefulWidget {
  const ForgotPasswordFlow({super.key});

  @override
  State<ForgotPasswordFlow> createState() => _ForgotPasswordFlowState();
}

class _ForgotPasswordFlowState extends State<ForgotPasswordFlow> {
  int _step = 1; // 1: Email, 2: OTP, 3: New Password, 4: Success
  final _contactController = TextEditingController(text: 'ahmed@example.com');
  final _otpController = TextEditingController(text: '1234');
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  int _resendCountdown = 45;

  @override
  void dispose() {
    _contactController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _resendCountdown = 45);
  }

  Future<void> _handleSendOtp() async {
    if (_contactController.text.trim().isEmpty) return;
    final auth = context.read<AuthViewModel>();
    final ok = await auth.sendResetOtp(_contactController.text.trim());
    if (ok && mounted) {
      setState(() => _step = 2);
      _startTimer();
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.trim().length < 4) return;
    final auth = context.read<AuthViewModel>();
    final ok = await auth.verifyOtp(_contactController.text.trim(), _otpController.text.trim());
    if (ok && mounted) {
      setState(() => _step = 3);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid verification code. Please check and retry.')),
      );
    }
  }

  Future<void> _handleResetPassword() async {
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.')),
      );
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    final auth = context.read<AuthViewModel>();
    final ok = await auth.resetPassword(_contactController.text.trim(), _newPasswordController.text);
    if (ok && mounted) {
      setState(() => _step = 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step > 1 && _step < 4) {
              setState(() => _step--);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          _step == 4 ? 'Success' : 'Reset Password',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ResponsiveConstrainedBox(
            maxWidth: ResponsiveLayout.maxFormWidth,
            child: _buildCurrentStep(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_step) {
      case 1:
        return _buildStep1Email(context);
      case 2:
        return _buildStep2Otp(context);
      case 3:
        return _buildStep3NewPassword(context);
      case 4:
        return _buildStep4Success(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Email(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your registered email address or phone number to receive a 4-digit verification code.',
          style: TextStyle(fontSize: 14, color: context.textSecondaryColor, height: 1.4),
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _contactController,
          hintText: 'Email or Phone Number',
          prefixIcon: Icon(Icons.mail_outline, color: context.textSecondaryColor),
        ),
        const SizedBox(height: 28),
        CustomButton(
          text: 'Send Verification Code',
          onPressed: _handleSendOtp,
        ),
      ],
    );
  }

  Widget _buildStep2Otp(BuildContext context) {
    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Enter 4-Digit Code',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a 4-digit verification code to ${_contactController.text.trim()}. (Demo code: 1234)',
          style: TextStyle(fontSize: 14, color: context.textSecondaryColor, height: 1.4),
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _otpController,
          hintText: 'Enter 4-digit OTP',
          keyboardType: TextInputType.number,
          prefixIcon: Icon(Icons.pin_outlined, color: context.textSecondaryColor),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Resend in ${_resendCountdown}s',
              style: TextStyle(color: context.textSecondaryColor, fontSize: 13),
            ),
            GestureDetector(
              onTap: _startTimer,
              child: Text(
                'Resend Code',
                style: TextStyle(
                  color: accentPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        CustomButton(
          text: 'Verify Code',
          onPressed: _handleVerifyOtp,
        ),
      ],
    );
  }

  Widget _buildStep3NewPassword(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Create New Password',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your new password must be at least 6 characters and different from previous passwords.',
          style: TextStyle(fontSize: 14, color: context.textSecondaryColor, height: 1.4),
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _newPasswordController,
          hintText: 'New Password',
          obscureText: _obscurePassword,
          prefixIcon: Icon(Icons.lock_outline, color: context.textSecondaryColor),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: context.textSecondaryColor,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _confirmPasswordController,
          hintText: 'Confirm New Password',
          obscureText: _obscurePassword,
          prefixIcon: Icon(Icons.lock_outline, color: context.textSecondaryColor),
        ),
        const SizedBox(height: 28),
        CustomButton(
          text: 'Reset Password',
          onPressed: _handleResetPassword,
        ),
      ],
    );
  }

  Widget _buildStep4Success(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const LottieSuccessView(size: 150),
            const SizedBox(height: 16),
            Text(
              'Password Reset Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your password has been securely updated. You can now sign in with your new credentials.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: context.textSecondaryColor, height: 1.4),
            ),
            const SizedBox(height: 36),
            CustomButton(
              text: 'Back to Sign In',
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}



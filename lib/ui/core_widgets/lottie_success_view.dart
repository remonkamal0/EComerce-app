import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_colors.dart';
import 'custom_button.dart';

/// Interactive Lottie Success Animation component for HomePlus
class LottieSuccessView extends StatefulWidget {
  final double size;
  final bool repeat;
  final String assetPath;
  final VoidCallback? onAnimationComplete;

  const LottieSuccessView({
    super.key,
    this.size = 160,
    this.repeat = false,
    this.assetPath = 'assets/animations/success.json',
    this.onAnimationComplete,
  });

  @override
  State<LottieSuccessView> createState() => _LottieSuccessViewState();
}

class _LottieSuccessViewState extends State<LottieSuccessView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Lottie.asset(
        widget.assetPath,
        controller: _animController,
        fit: BoxFit.contain,
        repeat: widget.repeat,
        onLoaded: (composition) {
          _animController.duration = composition.duration;
          if (widget.repeat) {
            _animController.repeat();
          } else {
            _animController.forward().then((_) {
              widget.onAnimationComplete?.call();
            });
          }
        },
        errorBuilder: (context, error, stackTrace) {
          // Graceful fallback: Animated vector pulse checkmark
          return _FallbackSuccessIcon(size: widget.size);
        },
      ),
    );
  }
}

class _FallbackSuccessIcon extends StatefulWidget {
  final double size;

  const _FallbackSuccessIcon({required this.size});

  @override
  State<_FallbackSuccessIcon> createState() => _FallbackSuccessIconState();
}

class _FallbackSuccessIconState extends State<_FallbackSuccessIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: AppColors.mint,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.check,
          size: widget.size * 0.55,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Helper function to show a modern animated success dialog with Lottie
Future<void> showLottieSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonText = 'Continue',
  VoidCallback? onConfirm,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LottieSuccessView(size: 130),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: buttonText,
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm?.call();
            },
          ),
        ],
      ),
    ),
  );
}

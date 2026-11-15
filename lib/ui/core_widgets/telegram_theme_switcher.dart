import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../view_models/app_theme_view_model.dart';

/// Root overlay placed in [MaterialApp.builder] that captures the current UI and
/// reveals the newly-themed app inside a Telegram-style expanding circle originating
/// from whichever theme control the user tapped.
///
/// Keeping [child] (the [Navigator]) fixed at slot 0 of a [Stack] avoids
/// reparenting routes or resetting scroll positions during theme transitions.
class TelegramThemeOverlay extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const TelegramThemeOverlay({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
  });

  static TelegramThemeOverlayState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<TelegramThemeOverlayState>();
  }

  @override
  State<TelegramThemeOverlay> createState() => TelegramThemeOverlayState();
}

class TelegramThemeOverlayState extends State<TelegramThemeOverlay>
    with SingleTickerProviderStateMixin {
  final GlobalKey _repaintKey = GlobalKey();
  late final AnimationController _controller;
  late final Animation<double> _animation;

  ui.Image? _snapshot;
  Offset _origin = Offset.zero;
  bool _showChristmasEffects = false;
  bool _isTransitioning = false;
  Completer<void>? _transitionCompleter;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.addStatusListener(_handleAnimationStatus);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }

    _isTransitioning = false;
    _snapshot?.dispose();
    _snapshot = null;

    if (mounted) {
      setState(() {});
    }

    final completer = _transitionCompleter;
    _transitionCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  @override
  void didUpdateWidget(covariant TelegramThemeOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _snapshot?.dispose();
    _controller.dispose();
    final completer = _transitionCompleter;
    _transitionCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    super.dispose();
  }

  Offset _resolveOrigin(GlobalKey? sourceKey) {
    final overlayBox =
        _repaintKey.currentContext?.findRenderObject() as RenderBox?;
    final size = overlayBox?.hasSize == true
        ? overlayBox!.size
        : MediaQuery.sizeOf(context);
    final sourceBox =
        sourceKey?.currentContext?.findRenderObject() as RenderBox?;

    if (overlayBox != null &&
        overlayBox.hasSize &&
        sourceBox != null &&
        sourceBox.hasSize) {
      final globalCenter = sourceBox.localToGlobal(
        sourceBox.size.center(Offset.zero),
      );
      return overlayBox.globalToLocal(globalCenter);
    }
    return size.center(Offset.zero);
  }

  /// Switches to [targetMode] with a circular reveal expanding from [sourceKey].
  Future<void> switchTheme({
    required AppAppearance targetMode,
    GlobalKey? sourceKey,
  }) async {
    final themeVm = context.read<AppThemeViewModel>();
    final platformDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final wasDark = Theme.of(context).brightness == Brightness.dark;
    final willBeDark = switch (targetMode) {
      AppAppearance.dark => true,
      AppAppearance.light || AppAppearance.christmas => false,
      AppAppearance.system => platformDark,
    };

    if (_isTransitioning) return;
    final enteringChristmas = targetMode == AppAppearance.christmas;
    final christmasChanged =
        enteringChristmas != (themeVm.appearance == AppAppearance.christmas);
    if ((!christmasChanged && wasDark == willBeDark) ||
        MediaQuery.disableAnimationsOf(context)) {
      themeVm.setAppearance(targetMode);
      return;
    }

    _isTransitioning = true;
    final origin = _resolveOrigin(sourceKey);

    ui.Image? snapshot;
    try {
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) return;
      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary != null && boundary.hasSize) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        snapshot = boundary.toImageSync(pixelRatio: dpr);
      }
    } catch (_) {
      snapshot?.dispose();
      snapshot = null;
    }

    if (!mounted) {
      snapshot?.dispose();
      _isTransitioning = false;
      return;
    }

    if (snapshot == null) {
      _isTransitioning = false;
      themeVm.setAppearance(targetMode);
      return;
    }

    _controller.reset();
    setState(() {
      _origin = origin;
      _showChristmasEffects = enteringChristmas;
      _snapshot = snapshot;
    });

    final completer = Completer<void>();
    _transitionCompleter = completer;

    // Paint the frozen UI before applying the new theme underneath it.
    await SchedulerBinding.instance.endOfFrame;
    if (!mounted) return;
    themeVm.setAppearance(targetMode);
    // Lay out and paint the target theme under the still fully covered frame.
    await SchedulerBinding.instance.endOfFrame;
    if (!mounted) return;
    _controller.forward();
    await completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final showSnapshotHole = _snapshot != null;

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          key: _repaintKey,
          child: ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Stack(
              fit: StackFit.expand,
              children: [
                widget.child,
                if (context.isChristmasTheme)
                  const Positioned.fill(child: _ChristmasDecorations()),
              ],
            ),
          ),
        ),
        if (showSnapshotHole)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return ClipPath(
                    clipper: _CircleRevealClipper(
                      center: _origin,
                      progress: _animation.value,
                      inverted: true,
                    ),
                    child: child,
                  );
                },
                child: RawImage(image: _snapshot, fit: BoxFit.fill),
              ),
            ),
          ),
        if (showSnapshotHole && _showChristmasEffects)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ChristmasEffects(_controller)),
            ),
          ),
      ],
    );
  }
}

class _ChristmasDecorations extends StatefulWidget {
  const _ChristmasDecorations();

  @override
  State<_ChristmasDecorations> createState() => _ChristmasDecorationsState();
}

class _ChristmasDecorationsState extends State<_ChristmasDecorations>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snow = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _snow.stop();
    } else if (!_snow.isAnimating) {
      _snow.repeat();
    }
  }

  @override
  void dispose() {
    _snow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: CustomPaint(
            key: const ValueKey('christmas-decorations'),
            painter: _SnowfallPainter(
              _snow,
              animate: !MediaQuery.disableAnimationsOf(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _SnowfallPainter extends CustomPainter {
  _SnowfallPainter(this.snow, {required this.animate}) : super(repaint: snow);

  final Animation<double> snow;
  final bool animate;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    if (animate) {
      final random = Random(51);
      final count = (size.width / 14).round().clamp(14, 42);
      for (var i = 0; i < count; i++) {
        final drift = i.isEven ? 1 : 2;
        final x = random.nextDouble() * size.width;
        final progress = (random.nextDouble() + snow.value * drift) % 1;
        final radius = 1.1 + random.nextDouble() * 1.8;
        final center = Offset(
          x + sin(snow.value * 2 * pi + i) * 10,
          progress * (size.height + 8) - 4,
        );
        paint.color = const Color(0xFF518D77).withValues(alpha: 0.23);
        canvas.drawCircle(center, radius + 0.5, paint);
        paint.color = Colors.white.withValues(alpha: 0.86);
        canvas.drawCircle(center, radius, paint);
      }
    }

    _paintTree(canvas, paint, Offset(7, size.height * 0.28));
    _paintTree(canvas, paint, Offset(size.width - 7, size.height * 0.69));
  }

  void _paintTree(Canvas canvas, Paint paint, Offset top) {
    paint.color = const Color(0xFF865841);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: top.translate(0, 37), width: 5, height: 9),
        const Radius.circular(1),
      ),
      paint,
    );
    for (var tier = 2; tier >= 0; tier--) {
      final y = top.dy + tier * 8;
      final width = 9.0 + tier * 3;
      paint.color = tier.isEven
          ? AppColors.christmasGreen
          : const Color(0xFF239263);
      canvas.drawPath(
        Path()
          ..moveTo(top.dx, y)
          ..lineTo(top.dx + width, y + 20)
          ..lineTo(top.dx - width, y + 20)
          ..close(),
        paint,
      );
    }
    paint.color = AppColors.christmasRed;
    canvas.drawCircle(top.translate(5, 18), 2, paint);
    canvas.drawCircle(top.translate(-6, 29), 2, paint);
    paint.color = const Color(0xFFE4A632);
    canvas.drawCircle(top, 3, paint);
    canvas.drawCircle(top.translate(6, 30), 1.7, paint);
  }

  @override
  bool shouldRepaint(covariant _SnowfallPainter oldDelegate) =>
      oldDelegate.snow != snow || oldDelegate.animate != animate;
}

class _ChristmasEffects extends CustomPainter {
  _ChristmasEffects(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final opacity = sin(pi * t).clamp(0.0, 1.0).toDouble();
    final paint = Paint();
    final random = Random(24);
    for (var i = 0; i < 34; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() - 0.35 + t * 0.8) * size.height;
      final radius = 1.5 + random.nextDouble() * 3;
      final color = switch (i % 5) {
        0 => const Color(0xFFD94356),
        1 => const Color(0xFFFFD27D),
        _ => Colors.white,
      };
      final center = Offset(x + sin(t * 8 + i) * 12, y);
      paint.color = color.withValues(alpha: opacity);
      canvas.drawCircle(center, radius, paint);
      if (i % 5 < 2) {
        paint.color = const Color(0xFFFFE4A8).withValues(alpha: opacity);
        canvas.drawCircle(center.translate(0, -radius), 1, paint);
      }
    }

    final rise = Curves.easeOutCubic.transform(t);
    for (final x in [size.width * 0.16, size.width * 0.84]) {
      final top = size.height + 8 - 112 * rise;
      for (var tier = 0; tier < 3; tier++) {
        final y = top + tier * 18;
        final halfWidth = 16.0 + tier * 7;
        paint.color = const Color(0xFF27815A).withValues(alpha: opacity);
        canvas.drawPath(
          Path()
            ..moveTo(x, y)
            ..lineTo(x + halfWidth, y + 33)
            ..lineTo(x - halfWidth, y + 33)
            ..close(),
          paint,
        );
        paint.color = const Color(0xFFD94356).withValues(alpha: opacity);
        canvas.drawCircle(Offset(x + (tier.isEven ? 8 : -8), y + 23), 3, paint);
      }
      paint.color = const Color(0xFFFFD27D).withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, top + 1), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChristmasEffects oldDelegate) =>
      oldDelegate.animation != animation;
}

class _CircleRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double progress;
  final bool inverted;

  const _CircleRevealClipper({
    required this.center,
    required this.progress,
    required this.inverted,
  });

  @override
  Path getClip(Size size) {
    final dx = max(center.dx, size.width - center.dx);
    final dy = max(center.dy, size.height - center.dy);
    final maxRadius = sqrt(dx * dx + dy * dy) + 2.0;
    final radius = (maxRadius * progress).clamp(0.0, maxRadius);

    final path = Path();
    if (inverted) {
      path
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & size);
      if (radius > 0) {
        path.addOval(Rect.fromCircle(center: center, radius: radius));
      }
    } else {
      path.addOval(Rect.fromCircle(center: center, radius: radius));
    }
    return path;
  }

  @override
  bool shouldReclip(covariant _CircleRevealClipper oldClipper) {
    return oldClipper.progress != progress ||
        oldClipper.center != center ||
        oldClipper.inverted != inverted;
  }
}

/// Captures a stable [GlobalKey] for any custom widget triggering the Telegram
/// circular theme reveal.
class _TelegramRevealTarget extends StatefulWidget {
  final Widget Function(BuildContext context, GlobalKey targetKey) builder;

  const _TelegramRevealTarget({required this.builder});

  @override
  State<_TelegramRevealTarget> createState() => _TelegramRevealTargetState();
}

class _TelegramRevealTargetState extends State<_TelegramRevealTarget> {
  final GlobalKey _wrapperKey = GlobalKey();
  final GlobalKey _childKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _wrapperKey,
      child: Builder(
        builder: (innerContext) => widget.builder(innerContext, _childKey),
      ),
    );
  }
}

/// Morphing Moon/Sun button that triggers Telegram-style circular reveal theme transitions
/// using [TelegramThemeOverlay] when mounted inside [HomePlusApp], and falls back safely
/// in isolated tests without a [TelegramThemeOverlay].
class TelegramThemeToggleButton extends StatelessWidget {
  final Color? iconColor;
  final double size;

  const TelegramThemeToggleButton({super.key, this.iconColor, this.size = 20});

  /// Switches theme with circular reveal animation originating from [sourceKey]
  /// (or the enclosing [TelegramThemeToggleButton.builder] wrapper when omitted)
  /// when inside [TelegramThemeOverlay], or updates [AppThemeViewModel] directly.
  static void applyThemeMode({
    required BuildContext context,
    required AppAppearance mode,
    GlobalKey? sourceKey,
  }) {
    final overlay = TelegramThemeOverlay.maybeOf(context);
    if (overlay != null) {
      final resolvedKey = (sourceKey?.currentContext != null)
          ? sourceKey
          : context
                .findAncestorStateOfType<_TelegramRevealTargetState>()
                ?._wrapperKey;
      overlay.switchTheme(targetMode: mode, sourceKey: resolvedKey);
    } else {
      context.read<AppThemeViewModel>().setAppearance(mode);
    }
  }

  /// Provides a stable [GlobalKey] bound to the built child so taps originate the
  /// circular reveal from that widget's exact screen coordinates.
  static Widget builder({
    required Widget Function(BuildContext context, GlobalKey targetKey) builder,
  }) {
    return _TelegramRevealTarget(builder: builder);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TelegramThemeToggleButton.builder(
      builder: (ctx, targetKey) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            applyThemeMode(
              context: ctx,
              mode: isDark ? AppAppearance.light : AppAppearance.dark,
              sourceKey: targetKey,
            );
          },
          child: Container(
            key: targetKey,
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.mintLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.mintDark,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, anim) {
                return RotationTransition(
                  turns: Tween<double>(begin: 0.75, end: 1.0).animate(anim),
                  child: ScaleTransition(scale: anim, child: child),
                );
              },
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey<bool>(isDark),
                size: size,
                color:
                    iconColor ??
                    (isDark ? const Color(0xFFFBBF24) : AppColors.primary),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../features/cart/cart_screen.dart';
import '../view_models/cart_view_model.dart';
import 'appliance_image.dart';

/// Controller exposed by [AddToCartOverlayScope] to launch a GlobalKey-based
/// fly-to-cart animation from any source product widget to the cart target.
class AddToCartOverlayController {
  final GlobalKey cartTargetKey;
  final ValueListenable<int> landedListenable;
  final void Function({
    required GlobalKey sourceKey,
    String? imageUrl,
  }) _triggerFly;

  const AddToCartOverlayController({
    required this.cartTargetKey,
    required this.landedListenable,
    required void Function({
      required GlobalKey sourceKey,
      String? imageUrl,
    }) triggerFly,
  }) : _triggerFly = triggerFly;

  /// Animates a thumbnail from [sourceKey]'s current screen bounds into [cartTargetKey].
  void flyToCart({
    required GlobalKey sourceKey,
    String? imageUrl,
  }) {
    _triggerFly(sourceKey: sourceKey, imageUrl: imageUrl);
  }
}

class _AddToCartScopeInherited extends InheritedWidget {
  final AddToCartOverlayController controller;

  const _AddToCartScopeInherited({
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(_AddToCartScopeInherited oldWidget) =>
      controller != oldWidget.controller;
}

/// Hosts an overlay fly-to-cart coordinator using a target [GlobalKey] and source [GlobalKey].
class AddToCartOverlayScope extends StatefulWidget {
  final Widget child;
  final GlobalKey? cartTargetKey;

  const AddToCartOverlayScope({
    super.key,
    required this.child,
    this.cartTargetKey,
  });

  /// Returns the nearest [AddToCartOverlayController] without registering a rebuild dependency.
  static AddToCartOverlayController? maybeOf(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<_AddToCartScopeInherited>()
        ?.controller;
  }

  @override
  State<AddToCartOverlayScope> createState() => _AddToCartOverlayScopeState();
}

class _ActiveFlight {
  final AnimationController controller;
  final OverlayEntry entry;

  const _ActiveFlight({
    required this.controller,
    required this.entry,
  });
}

class _AddToCartOverlayScopeState extends State<AddToCartOverlayScope>
    with TickerProviderStateMixin {
  late final GlobalKey _cartTargetKey;
  final ValueNotifier<int> _landedNotifier = ValueNotifier<int>(0);
  final List<_ActiveFlight> _activeFlights = [];
  late final AddToCartOverlayController _controller;

  @override
  void initState() {
    super.initState();
    _cartTargetKey = widget.cartTargetKey ?? GlobalKey();
    _controller = AddToCartOverlayController(
      cartTargetKey: _cartTargetKey,
      landedListenable: _landedNotifier,
      triggerFly: _flyToCart,
    );
  }

  @override
  void dispose() {
    // Clean up all active flights so no tickers outlive this State.
    for (final flight in List<_ActiveFlight>.from(_activeFlights)) {
      flight.controller.stop();
      flight.controller.dispose();
      if (flight.entry.mounted) {
        flight.entry.remove();
      }
    }
    _activeFlights.clear();
    _landedNotifier.dispose();
    super.dispose();
  }

  void _flyToCart({
    required GlobalKey sourceKey,
    String? imageUrl,
  }) {
    final overlay = Overlay.maybeOf(context);
    final overlayObj = overlay?.context.findRenderObject();
    final sourceObj = sourceKey.currentContext?.findRenderObject();
    final targetObj = _cartTargetKey.currentContext?.findRenderObject();

    if (overlay == null ||
        overlayObj is! RenderBox ||
        sourceObj is! RenderBox ||
        targetObj is! RenderBox ||
        !overlayObj.attached ||
        !sourceObj.attached ||
        !targetObj.attached ||
        !sourceObj.hasSize ||
        !targetObj.hasSize) {
      // Fall back to a cart bounce if source or target is offscreen/unmounted.
      _landedNotifier.value++;
      return;
    }

    final overlaySize = overlayObj.size;
    final double maxX = math.max(32.0, overlaySize.width - 32.0);
    final double maxY = math.max(32.0, overlaySize.height - 32.0);
    final startOrigin = sourceObj.localToGlobal(Offset.zero, ancestor: overlayObj);
    final rawStartCenter = startOrigin +
        Offset(sourceObj.size.width / 2, sourceObj.size.height / 2);
    final startCenter = Offset(
      clampDouble(rawStartCenter.dx, 32.0, maxX),
      clampDouble(rawStartCenter.dy, 32.0, maxY),
    );

    final targetOrigin = targetObj.localToGlobal(Offset.zero, ancestor: overlayObj);
    final targetCenter = targetOrigin +
        Offset(targetObj.size.width / 2, targetObj.size.height / 2);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Keep the Bezier arc inside the visible viewport whether flying down to BottomNavBar
    // or sweeping upward to an AppBar Cart button.
    final isFlyingUpward = targetCenter.dy <= startCenter.dy;
    final horizontalMid = (startCenter.dx + targetCenter.dx) / 2;
    final lateralOffset = isFlyingUpward
        ? (startCenter.dx >= targetCenter.dx ? 72.0 : -72.0)
        : 0.0;
    final controlX = clampDouble(horizontalMid + lateralOffset, 32.0, maxX);
    final controlY = isFlyingUpward
        ? clampDouble(
            lerpDouble(targetCenter.dy, startCenter.dy, 0.45)!,
            32.0,
            maxY,
          )
        : math.max(32.0, math.min(startCenter.dy, targetCenter.dy) - 96.0);
    final controlPoint = Offset(controlX, controlY);

    late OverlayEntry entry;
    late _ActiveFlight flight;

    entry = OverlayEntry(
      builder: (_) => _FlyingCartThumbnail(
        animation: controller,
        start: startCenter,
        control: controlPoint,
        end: targetCenter,
        imageUrl: imageUrl,
      ),
    );

    flight = _ActiveFlight(controller: controller, entry: entry);
    _activeFlights.add(flight);
    overlay.insert(entry);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        if (entry.mounted) {
          entry.remove();
        }
        _activeFlights.remove(flight);
        controller.dispose();
        if (mounted && status == AnimationStatus.completed) {
          _landedNotifier.value++;
        }
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return _AddToCartScopeInherited(
      controller: _controller,
      child: widget.child,
    );
  }
}

class _FlyingCartThumbnail extends StatelessWidget {
  final Animation<double> animation;
  final Offset start;
  final Offset control;
  final Offset end;
  final String? imageUrl;

  const _FlyingCartThumbnail({
    required this.animation,
    required this.start,
    required this.control,
    required this.end,
    this.imageUrl,
  });

  Offset _quadraticBezier(double t) {
    final u = 1.0 - t;
    return Offset(
      u * u * start.dx + 2 * u * t * control.dx + t * t * end.dx,
      u * u * start.dy + 2 * u * t * control.dy + t * t * end.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = animation.value;
          final posT = Curves.easeInOutCubic.transform(t);
          final position = _quadraticBezier(posT);

          // Slight pop-up at launch followed by shrinking into the cart icon.
          final size = t < 0.2
              ? lerpDouble(56.0, 64.0, t / 0.2)!
              : lerpDouble(64.0, 22.0, (t - 0.2) / 0.8)!;

          final opacity = t > 0.85
              ? (1.0 - ((t - 0.85) / 0.15)).clamp(0.0, 1.0)
              : 1.0;

          final rotation = math.sin(t * math.pi) * 0.18;
          final radius = lerpDouble(14.0, 24.0, posT)!;

          return Stack(
            children: [
              Positioned(
                left: position.dx - size / 2,
                top: position.dy - size / 2,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.rotate(
                    angle: rotation,
                    child: Container(
                      width: size,
                      height: size,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: imageUrl != null && imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(radius - 4),
                              child: ApplianceImage(
                                imageUrl: imageUrl!,
                                fit: BoxFit.contain,
                                borderRadius: radius - 4,
                              ),
                            )
                          : const Icon(
                              Icons.shopping_bag_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Bounces its [child] whenever [trigger] changes (for example, when a flying product lands).
class CartTargetBounce extends StatefulWidget {
  final ValueListenable<int>? trigger;
  final Widget child;

  const CartTargetBounce({
    super.key,
    required this.trigger,
    required this.child,
  });

  @override
  State<CartTargetBounce> createState() => _CartTargetBounceState();
}

class _CartTargetBounceState extends State<CartTargetBounce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.26), weight: 45),
      TweenSequenceItem(tween: Tween<double>(begin: 1.26, end: 0.92), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.92, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    widget.trigger?.addListener(_onLanded);
  }

  @override
  void didUpdateWidget(covariant CartTargetBounce oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) {
      oldWidget.trigger?.removeListener(_onLanded);
      widget.trigger?.addListener(_onLanded);
    }
  }

  @override
  void dispose() {
    widget.trigger?.removeListener(_onLanded);
    _controller.dispose();
    super.dispose();
  }

  void _onLanded() {
    if (mounted) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: widget.child,
    );
  }
}

/// Reusable AppBar Cart button with live badge + GlobalKey target hook for pushed screens.
class CartAppBarButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CartAppBarButton({super.key, this.onPressed});

  int _readCartCount(BuildContext context) {
    try {
      return context.watch<CartViewModel>().itemCount;
    } on ProviderNotFoundException {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartScope = AddToCartOverlayScope.maybeOf(context);
    final count = _readCartCount(context);

    return CartTargetBounce(
      trigger: cartScope?.landedListenable,
      child: IconButton(
        onPressed: onPressed ??
            () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              key: cartScope?.cartTargetKey,
              color: context.textPrimaryColor,
            ),
            if (count > 0)
              Positioned(
                top: -6,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.scaffoldBg, width: 1.2),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

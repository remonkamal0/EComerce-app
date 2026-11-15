import 'package:flutter/material.dart';

/// Shared responsive breakpoints and layout helpers based on available window width.
class ResponsiveLayout {
  ResponsiveLayout._();

  static const double compactMaxWidth = 600.0;
  static const double navigationRailMinWidth = 720.0;
  static const double expandedMinWidth = 900.0;

  static const double maxFormWidth = 520.0;
  static const double maxReadableWidth = 880.0;
  static const double maxContentWidth = 1200.0;

  static bool isCompact(double width) => width < compactMaxWidth;
  static bool isMedium(double width) =>
      width >= compactMaxWidth && width < expandedMinWidth;
  static bool isExpanded(double width) => width >= expandedMinWidth;
  static bool useNavigationRail(double width) => width >= navigationRailMinWidth;

  /// Number of columns for product grids based on available width.
  static int productGridColumns(double width) {
    if (width >= 1200) return 5;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  /// Aspect ratio for product cards to prevent text/price overflow on narrow screens.
  static double productCardAspectRatio(double width) {
    if (width < 360) return 0.64;
    if (width < 600) return 0.72;
    return 0.76;
  }

  /// Number of columns for category grids based on available width.
  static int categoryGridColumns(double width) {
    if (width >= 1140) return 5;
    if (width >= 840) return 4;
    if (width >= 330) return 3;
    return 2;
  }

  /// Number of columns for horizontal offer/wishlist cards on wide screens.
  static int cardListColumns(double width) {
    if (width >= 1080) return 3;
    if (width >= 680) return 2;
    return 1;
  }

  /// Adaptive horizontal page padding.
  static double horizontalPadding(double width) {
    if (width >= 900) return 28.0;
    if (width >= 600) return 24.0;
    if (width < 360) return 12.0;
    return 16.0;
  }

  /// Adaptive promotional banner height.
  static double bannerHeight(double width) {
    return (width * 0.36).clamp(160.0, 224.0);
  }
}

/// Centers [child] and caps its maximum width so layouts stay crisp on tablets and desktops.
class ResponsiveConstrainedBox extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;

  const ResponsiveConstrainedBox({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveLayout.maxContentWidth,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      heightFactor: 1.0,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

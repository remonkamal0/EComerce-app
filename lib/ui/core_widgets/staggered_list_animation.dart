import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// Coordinates staggered entrance animations so only the initial viewport items stagger.
class StaggeredListLimiter extends StatelessWidget {
  final Widget child;

  const StaggeredListLimiter({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(child: child);
  }
}

/// Applies a staggered slide-and-fade entrance animation to a list item at [index].
class StaggeredListItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration duration;
  final double verticalOffset;
  final double horizontalOffset;

  const StaggeredListItem({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 380),
    this.verticalOffset = 36.0,
    this.horizontalOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index.clamp(0, 8),
      duration: duration,
      child: SlideAnimation(
        verticalOffset: verticalOffset,
        horizontalOffset: horizontalOffset,
        child: FadeInAnimation(child: child),
      ),
    );
  }
}

/// Applies a staggered scale-and-fade entrance animation to a grid cell at [index].
class StaggeredGridItem extends StatelessWidget {
  final int index;
  final int columnCount;
  final Widget child;
  final Duration duration;

  const StaggeredGridItem({
    super.key,
    required this.index,
    required this.child,
    this.columnCount = 2,
    this.duration = const Duration(milliseconds: 380),
  });

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredGrid(
      position: index.clamp(0, 10),
      columnCount: columnCount,
      duration: duration,
      child: ScaleAnimation(
        scale: 0.92,
        child: FadeInAnimation(child: child),
      ),
    );
  }
}

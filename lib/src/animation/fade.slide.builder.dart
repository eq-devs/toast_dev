import 'package:flutter/material.dart';

import 'animation.builder.dart';
import 'slide.builder.dart';

/// Combines a fade and slide animation for a premium entrance effect.
class FadeSlideAnimationBuilder extends BaseAnimationBuilder {
  const FadeSlideAnimationBuilder({
    this.direction = SlideDirection.fromTop,
    this.slideOffset = 0.3,
  });

  /// The direction of the slide.
  final SlideDirection direction;

  /// How far the toast slides (as a fraction). Defaults to `0.3`.
  final double slideOffset;

  Offset get _beginOffset => switch (direction) {
        SlideDirection.fromTop => Offset(0, -slideOffset),
        SlideDirection.fromBottom => Offset(0, slideOffset),
        SlideDirection.fromLeft => Offset(-slideOffset, 0),
        SlideDirection.fromRight => Offset(slideOffset, 0),
      };

  @override
  Widget buildWidget(
    BuildContext context,
    Widget child,
    AnimationController controller,
    double percent,
  ) {
    final curved = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: _beginOffset, end: Offset.zero)
            .animate(curved),
        child: child,
      ),
    );
  }
}

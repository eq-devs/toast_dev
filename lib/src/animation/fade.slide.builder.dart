import 'package:flutter/material.dart';

import 'animation.builder.dart';
import 'slide.builder.dart';

class FadeSlideAnimationBuilder extends BaseAnimationBuilder {
  const FadeSlideAnimationBuilder({
    this.direction = SlideDirection.fromTop,
    this.slideOffset = 0.3,
  });

  final SlideDirection direction;

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

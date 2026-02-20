import 'package:flutter/material.dart';

import 'animation.builder.dart';

/// Direction from which the toast slides in.
enum SlideDirection { fromTop, fromBottom, fromLeft, fromRight }

/// Slides the toast in from a configurable direction.
class SlideAnimationBuilder extends BaseAnimationBuilder {
  const SlideAnimationBuilder({
    this.direction = SlideDirection.fromTop,
  });

  final SlideDirection direction;

  Offset get _beginOffset => switch (direction) {
        SlideDirection.fromTop => const Offset(0, -1),
        SlideDirection.fromBottom => const Offset(0, 1),
        SlideDirection.fromLeft => const Offset(-1, 0),
        SlideDirection.fromRight => const Offset(1, 0),
      };

  @override
  Widget buildWidget(
    BuildContext context,
    Widget child,
    AnimationController controller,
    double percent,
  ) {
    return SlideTransition(
      position: Tween<Offset>(begin: _beginOffset, end: Offset.zero).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      ),
      child: child,
    );
  }
}

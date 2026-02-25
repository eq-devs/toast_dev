import 'package:flutter/material.dart';

import 'animation.builder.dart';

enum SlideDirection { fromTop, fromBottom, fromLeft, fromRight }

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

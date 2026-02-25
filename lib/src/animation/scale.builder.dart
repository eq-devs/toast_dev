import 'package:flutter/material.dart';

import 'animation.builder.dart';

class ScaleAnimationBuilder extends BaseAnimationBuilder {
  const ScaleAnimationBuilder({
    this.beginScale = 0.6,
    this.alignment = Alignment.center,
  });

  final double beginScale;

  final Alignment alignment;

  @override
  Widget buildWidget(
    BuildContext context,
    Widget child,
    AnimationController controller,
    double percent,
  ) {
    return ScaleTransition(
      scale: Tween<double>(begin: beginScale, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
      ),
      alignment: alignment,
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

import 'animation.builder.dart';

/// Scales the toast in from a configurable initial scale.
class ScaleAnimationBuilder extends BaseAnimationBuilder {
  const ScaleAnimationBuilder({
    this.beginScale = 0.6,
    this.alignment = Alignment.center,
  });

  /// The initial scale. Defaults to `0.6`.
  final double beginScale;

  /// The alignment origin for the scale transform.
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

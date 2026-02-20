import 'package:flutter/material.dart';

import 'animation.builder.dart';

/// Fades the toast in/out using opacity.
class FadeAnimationBuilder extends BaseAnimationBuilder {
  const FadeAnimationBuilder();

  @override
  Widget buildWidget(
    BuildContext context,
    Widget child,
    AnimationController controller,
    double percent,
  ) {
    return Opacity(opacity: percent, child: child);
  }
}

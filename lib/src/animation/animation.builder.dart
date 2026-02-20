import 'package:flutter/widgets.dart';

/// Signature for a function that builds toast animation widgets.
typedef ToastAnimationBuilder = Widget Function(
  BuildContext context,
  Widget child,
  AnimationController controller,
  double percent,
);

/// Base class for toast animation builders.
///
/// Extend this to create custom toast animations:
/// ```dart
/// class MyAnimation extends BaseAnimationBuilder {
///   const MyAnimation();
///
///   @override
///   Widget buildWidget(context, child, controller, percent) {
///     return Opacity(opacity: percent, child: child);
///   }
/// }
/// ```
abstract class BaseAnimationBuilder {
  const BaseAnimationBuilder();

  Widget call(
    BuildContext context,
    Widget child,
    AnimationController controller,
    double percent,
  ) {
    return buildWidget(context, child, controller, percent);
  }

  Widget buildWidget(
    BuildContext context,
    Widget child,
    AnimationController controller,
    double percent,
  );
}

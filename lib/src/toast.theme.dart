import 'package:flutter/material.dart';

import 'animation/animation.builder.dart';
import 'toast.length.dart';
import 'toast.position.dart';

/// Provides default toast configuration to descendant widgets.
///
/// Wrap your app with [ToastTheme] (automatically done by `ToastDev`)
/// to set app-wide defaults.
class ToastTheme extends InheritedWidget {
  const ToastTheme({
    super.key,
    required super.child,
    this.position = ToastPosition.top,
    this.backgroundColor,
    this.shadowColor,
    this.iconColor,
    this.messageStyle,
    this.length = ToastLength.short,
    this.isClosable = false,
    this.expandedHeight = 100,
    this.dismissDirection = DismissDirection.up,
    this.positionCurve = Curves.elasticOut,
    this.slideCurve,
    this.animationBuilder,
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  /// Default position of toasts.
  final ToastPosition position;

  /// Default background color.
  final Color? backgroundColor;

  /// Default shadow color.
  final Color? shadowColor;

  /// Default icon color.
  final Color? iconColor;

  /// Default message text style.
  final TextStyle? messageStyle;

  /// Default toast duration.
  final ToastLength length;

  /// Whether toasts show a close button by default.
  final bool isClosable;

  /// Default expanded height when toast is tapped.
  final double expandedHeight;

  /// Default swipe dismiss direction.
  final DismissDirection dismissDirection;

  /// Default position animation curve.
  final Curve positionCurve;

  /// Default slide animation curve.
  final Curve? slideCurve;

  /// Default animation builder. If null, uses the toast widget's
  /// built-in slide animation.
  final ToastAnimationBuilder? animationBuilder;

  /// Duration for enter/exit animations.
  final Duration animationDuration;

  /// Get the nearest [ToastTheme], or `null` if none exists.
  static ToastTheme? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ToastTheme>();
  }

  @override
  bool updateShouldNotify(ToastTheme oldWidget) => true;
}

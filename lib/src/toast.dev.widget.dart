import 'package:flutter/material.dart';

import 'animation/animation.builder.dart';
import 'toast.length.dart';
import 'toast.position.dart';
import 'toast.service.dart';
import 'toast.theme.dart';

/// Wrap your [MaterialApp] (or [CupertinoApp]) with [ToastDev]
/// to enable context-free toast calls.
///
/// ```dart
/// ToastDev(
///   child: MaterialApp(...),
/// )
/// ```
///
/// You can also set app-wide toast defaults:
///
/// ```dart
/// ToastDev(
///   position: ToastPosition.top,
///   length: ToastLength.medium,
///   backgroundColor: Colors.black87,
///   child: MaterialApp(...),
/// )
/// ```
class ToastDev extends StatefulWidget {
  const ToastDev({
    super.key,
    required this.child,
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

  final Widget child;
  final ToastPosition position;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? iconColor;
  final TextStyle? messageStyle;
  final ToastLength length;
  final bool isClosable;
  final double expandedHeight;
  final DismissDirection dismissDirection;
  final Curve positionCurve;
  final Curve? slideCurve;
  final ToastAnimationBuilder? animationBuilder;
  final Duration animationDuration;

  @override
  State<ToastDev> createState() => _ToastDevState();
}

class _ToastDevState extends State<ToastDev> {
  @override
  void dispose() {
    ToastService.unregisterContext(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (BuildContext ctx) {
              ToastService.registerContext(this, ctx);
              return ToastTheme(
                position: widget.position,
                backgroundColor: widget.backgroundColor,
                shadowColor: widget.shadowColor,
                iconColor: widget.iconColor,
                messageStyle: widget.messageStyle,
                length: widget.length,
                isClosable: widget.isClosable,
                expandedHeight: widget.expandedHeight,
                dismissDirection: widget.dismissDirection,
                positionCurve: widget.positionCurve,
                slideCurve: widget.slideCurve,
                animationBuilder: widget.animationBuilder,
                animationDuration: widget.animationDuration,
                child: widget.child,
              );
            },
          ),
        ],
      ),
    );
  }
}

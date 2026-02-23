import 'package:flutter/material.dart';

import 'toast.service.dart';

/// Wrap your [MaterialApp] (or [CupertinoApp]) with [ToastDev]
/// to enable context-free toast calls.
///
/// ```dart
/// ToastDev(
///   child: MaterialApp(...),
/// )
/// ```
///
class ToastDev extends StatefulWidget {
  const ToastDev({
    super.key,
    required this.child,
  });

  final Widget child;

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
              return widget.child;
            },
          ),
        ],
      ),
    );
  }
}

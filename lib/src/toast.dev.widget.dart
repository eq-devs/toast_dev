import 'package:flutter/material.dart';

import 'toast.service.dart';

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
    final directionality = Directionality.maybeOf(context) ?? TextDirection.ltr;

    return Directionality(
      textDirection: directionality,
      child: Material(
        type: MaterialType.transparency,
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
      ),
    );
  }
}

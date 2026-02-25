import 'dart:async';

import 'package:flutter/material.dart';

class ToastFuture {
  ToastFuture._({
    required this.entry,
    required this.controller,
    this.onDismiss,
  });

  final OverlayEntry entry;
  final AnimationController controller;
  final VoidCallback? onDismiss;

  Timer? _timer;
  bool _dismissed = false;

  Future<void> Function()? onDismissedWithAnimation;

  bool get dismissed => _dismissed;

  bool get mounted => !_dismissed;

  void setTimer(Duration duration) {
    _timer = Timer(duration, dismiss);
  }

  void dismiss() async {
    if (_dismissed) return;
    _dismissed = true;
    _timer?.cancel();

    if (onDismissedWithAnimation != null) {
      await onDismissedWithAnimation!();
    } else {
      onDismiss?.call();
    }
  }

  static ToastFuture create({
    required OverlayEntry entry,
    required AnimationController controller,
    VoidCallback? onDismiss,
  }) {
    return ToastFuture._(
      entry: entry,
      controller: controller,
      onDismiss: onDismiss,
    );
  }
}

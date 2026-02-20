import 'dart:async';

import 'package:flutter/material.dart';

/// A handle to a shown toast. Use [dismiss] to remove it early.
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

  /// Whether this toast has been dismissed.
  bool get dismissed => _dismissed;

  /// Whether this toast is currently showing.
  bool get mounted => !_dismissed;

  /// Set an auto-dismiss timer.
  void setTimer(Duration duration) {
    _timer = Timer(duration, dismiss);
  }

  /// Dismiss this toast.
  void dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _timer?.cancel();
    onDismiss?.call();
  }

  /// Factory to create a ToastFuture.
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

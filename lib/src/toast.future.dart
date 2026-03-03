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
  bool _isPaused = false;
  DateTime? _startTime;
  Duration? _remainingTime;

  Future<void> Function()? onDismissedWithAnimation;

  bool get dismissed => _dismissed;

  bool get mounted => !_dismissed;

  bool get isPaused => _isPaused;

  void setTimer(Duration duration) {
    _remainingTime = duration;
    _startTime = DateTime.now();
    _timer = Timer(duration, dismiss);
  }

  void pauseTimer() {
    if (_isPaused ||
        _dismissed ||
        _remainingTime == null ||
        _startTime == null) {
      return;
    }
    _isPaused = true;
    _timer?.cancel();
    final elapsed = DateTime.now().difference(_startTime!);
    _remainingTime = _remainingTime! - elapsed;
    if (_remainingTime!.isNegative) {
      _remainingTime = Duration.zero;
    }
  }

  void resumeTimer() {
    if (!_isPaused || _dismissed || _remainingTime == null) {
      return;
    }
    _isPaused = false;
    _startTime = DateTime.now();
    // If remaining time is zero or negative, dismiss immediately (though Timer with 0 basically does this)
    _timer = Timer(_remainingTime!, dismiss);
  }

  void addDuration(Duration duration) {
    if (_dismissed) return;

    // If we're paused, just add to remaining time.
    if (_isPaused && _remainingTime != null) {
      _remainingTime = _remainingTime! + duration;
      return;
    }

    // If currently running, calculate new remaining time and restart the timer.
    if (!_isPaused && _startTime != null && _remainingTime != null) {
      _timer?.cancel();
      final elapsed = DateTime.now().difference(_startTime!);
      _remainingTime = (_remainingTime! + duration) - elapsed;
      if (_remainingTime!.isNegative) {
        _remainingTime = Duration.zero;
      }
      _startTime = DateTime.now();
      _timer = Timer(_remainingTime!, dismiss);
    }
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

import 'dart:async';

import 'package:flutter/widgets.dart';

class ToastFuture {
  ToastFuture._({
    required this.entry,
    this.onDismiss,
  });

  final OverlayEntry entry;
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
    if (_isPaused || _dismissed || _remainingTime == null || _startTime == null) {
      return;
    }
    _isPaused = true;
    _timer?.cancel();
    final elapsed = DateTime.now().difference(_startTime!);
    _remainingTime = _remainingTime! - elapsed;
    if (_remainingTime!.isNegative) _remainingTime = Duration.zero;
  }

  void resumeTimer() {
    if (!_isPaused || _dismissed || _remainingTime == null) return;
    _isPaused = false;
    _startTime = DateTime.now();
    _timer = Timer(_remainingTime!, dismiss);
  }

  void addDuration(Duration duration) {
    if (_dismissed) return;
    if (_isPaused && _remainingTime != null) {
      _remainingTime = _remainingTime! + duration;
      return;
    }
    if (!_isPaused && _startTime != null && _remainingTime != null) {
      _timer?.cancel();
      final elapsed = DateTime.now().difference(_startTime!);
      _remainingTime = (_remainingTime! + duration) - elapsed;
      if (_remainingTime!.isNegative) _remainingTime = Duration.zero;
      _startTime = DateTime.now();
      _timer = Timer(_remainingTime!, dismiss);
    }
  }

  // Cancels the timer without triggering the dismiss animation (used on swipe dismiss)
  void cancel() {
    if (_dismissed) return;
    _dismissed = true;
    _timer?.cancel();
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
    VoidCallback? onDismiss,
  }) {
    return ToastFuture._(
      entry: entry,
      onDismiss: onDismiss,
    );
  }
}

/// Duration presets for toasts.
enum ToastLength {
  /// 2 seconds
  short(Duration(milliseconds: 2000)),

  /// 3.5 seconds
  medium(Duration(milliseconds: 3500)),

  /// 5 seconds
  long(Duration(milliseconds: 5000)),

  /// 2 minutes
  ages(Duration(minutes: 2)),

  /// Never auto-dismiss
  never(Duration(hours: 24));

  const ToastLength(this.duration);
  final Duration duration;
}

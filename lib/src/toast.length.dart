enum ToastLength {
  ultraShort(Duration(milliseconds: 1200)),

  // 🟢
  short(Duration(milliseconds: 2000)),

  // 🟡
  medium(Duration(milliseconds: 3500)),

  // 🔵
  long(Duration(milliseconds: 5000)),

  // 🟣
  extended(Duration(seconds: 10)),

  // 🟠
  sticky(Duration(minutes: 5)),

  // 🔴
  ages(Duration(minutes: 2)),

  // ♾
  never(Duration(hours: 24));

  const ToastLength(this.duration);
  final Duration duration;
}

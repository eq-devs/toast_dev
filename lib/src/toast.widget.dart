import 'package:flutter/material.dart';

import 'animation/animation.builder.dart';

class ToastWidget extends StatefulWidget {
  const ToastWidget({
    super.key,
    this.isInFront = false,
    this.message,
    this.messageStyle,
    this.child,
    this.isTop = true,
    this.backgroundColor,
    this.shadowColor,
    required this.controller,
    this.slideCurve,
    this.animationBuilder,
  }) : assert((message != null && message != '') || child != null);

  final String? message;
  final TextStyle? messageStyle;
  final Widget? child;
  final Color? backgroundColor;
  final Color? shadowColor;
  final AnimationController controller;
  final bool isInFront;
  final Curve? slideCurve;
  final bool isTop;
  final ToastAnimationBuilder? animationBuilder;

  @override
  State<ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget> {
  late CurvedAnimation _curved;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _buildAnimations();
  }

  @override
  void didUpdateWidget(ToastWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.slideCurve != widget.slideCurve ||
        oldWidget.isTop != widget.isTop) {
      _curved.dispose();
      _buildAnimations();
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    super.dispose();
  }

  void _buildAnimations() {
    final curve = widget.slideCurve ?? Curves.elasticOut;
    _curved = CurvedAnimation(
      parent: widget.controller,
      curve: curve,
      reverseCurve: curve,
    );
    _slide = Tween<Offset>(
      begin: Offset(0.0, widget.isTop ? -1.0 : 1.0),
      end: Offset.zero,
    ).animate(_curved);
  }

  @override
  Widget build(BuildContext context) {
    final content = _BuildContent(toast: widget);

    if (widget.animationBuilder != null) {
      return AnimatedBuilder(
        animation: _curved,
        builder: (context, child) => widget.animationBuilder!(
          context,
          child!,
          widget.controller,
          _curved.value,
        ),
        child: content,
      );
    }

    return FadeTransition(
      opacity: _curved,
      child: SlideTransition(
        position: _slide,
        child: content,
      ),
    );
  }
}

@immutable
class _BuildContent extends StatelessWidget {
  const _BuildContent({required this.toast});
  final ToastWidget toast;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: toast.child != null
            ? null
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: toast.backgroundColor ?? Colors.white,
          boxShadow: !toast.isInFront
              ? null
              : [
                  BoxShadow(
                    blurRadius: 0.5,
                    offset: const Offset(0.0, -1.0),
                    color: toast.shadowColor ?? Colors.grey.shade100,
                  ),
                  BoxShadow(
                    blurRadius: 12,
                    offset: const Offset(0.0, 7.0),
                    color: toast.shadowColor ?? Colors.grey.shade100,
                  ),
                ],
        ),
        child: toast.child ??
            Text(
              toast.message!,
              style: toast.messageStyle,
            ),
      ),
    );
  }
}

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
  late CurvedAnimation _animation;

  @override
  void initState() {
    super.initState();
    _animation = _buildAnimation();
  }

  @override
  void didUpdateWidget(ToastWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.slideCurve != widget.slideCurve) {
      _animation.dispose();
      _animation = _buildAnimation();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  CurvedAnimation _buildAnimation() => CurvedAnimation(
        parent: widget.controller,
        curve: widget.slideCurve ?? Curves.elasticOut,
        reverseCurve: widget.slideCurve ?? Curves.elasticOut,
      );

  @override
  Widget build(BuildContext context) {
    final offsetTween = Tween<Offset>(
      begin: Offset(0.0, widget.isTop ? -1.0 : 1.0),
      end: Offset.zero,
    );

    final content = _BuildContent(toast: widget);

    if (widget.animationBuilder != null) {
      return AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) => widget.animationBuilder!(
          context,
          child!,
          widget.controller,
          _animation.value,
        ),
        child: content,
      );
    }

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _animation,
          child: AnimatedSlide(
            offset: offsetTween.evaluate(_animation),
            duration: Duration.zero,
            child: child,
          ),
        );
      },
      child: content,
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
        width: MediaQuery.sizeOf(context).width,
        padding: toast.child != null
            ? null
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: toast.backgroundColor ?? Colors.white,
          boxShadow: !toast.isInFront
              ? []
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
        child: Row(
          children: [
            Expanded(
              child: toast.child ??
                  Row(
                    children: [
                      if (toast.message != null)
                        Expanded(
                          child: Text(
                            toast.message!,
                            style: toast.messageStyle,
                          ),
                        ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

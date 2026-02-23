import 'package:flutter/material.dart';

import 'animation/animation.builder.dart';

/// The visual toast widget with slide animation, shadow, and interaction.
class ToastWidget extends StatelessWidget {
  const ToastWidget({
    super.key,
    this.isInFront = false,
    required this.onTap,
    this.onClose,
    this.message,
    this.messageStyle,
    this.leading,
    this.child,
    this.isClosable,
    this.isTop,
    this.backgroundColor,
    this.shadowColor,
    this.iconColor,
    required this.controller,
    this.slideCurve,
    this.animationBuilder,
  }) : assert((message != null || message != '') || child != null);

  final String? message;
  final TextStyle? messageStyle;
  final Widget? child;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? iconColor;
  final AnimationController? controller;
  final bool isInFront;
  final VoidCallback onTap;
  final VoidCallback? onClose;
  final Curve? slideCurve;
  final bool? isClosable;
  final bool? isTop;
  final ToastAnimationBuilder? animationBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller!,
      builder: (context, _) {
        final animationValue = CurvedAnimation(
          parent: controller!,
          curve: slideCurve ?? Curves.elasticOut,
          reverseCurve: slideCurve ?? Curves.elasticOut,
        );

        Widget content = _BuildContent(widget: this);

        // Use custom animation builder if provided
        if (animationBuilder != null) {
          return animationBuilder!(
            context,
            content,
            controller!,
            controller!.value,
          );
        }

        // Default slide animation
        final offset = Tween<Offset>(
          begin: Offset(0.0, isTop == true ? -1 : 1.0),
          end: Offset.zero,
        ).evaluate(animationValue);

        return FadeTransition(
          opacity: animationValue,
          child: AnimatedSlide(
            offset: offset,
            duration: Duration.zero,
            child: content,
          ),
        );
      },
    );
  }
}

@immutable
class _BuildContent extends StatelessWidget {
  const _BuildContent({required this.widget});
  final ToastWidget widget;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: (widget.child != null)
            ? null
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: widget.backgroundColor ?? Colors.white,
          boxShadow: !widget.isInFront
              ? []
              : [
                  BoxShadow(
                    blurRadius: widget.isInFront ? 0.5 : 0.0,
                    offset: const Offset(0.0, -1.0),
                    color: widget.shadowColor ?? Colors.grey.shade100,
                  ),
                  BoxShadow(
                    blurRadius: widget.isInFront ? 12 : 3,
                    offset: const Offset(0.0, 7.0),
                    color: widget.shadowColor ?? Colors.grey.shade100,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  widget.onTap.call();
                },
                borderRadius: BorderRadius.circular(15),
                child: (widget.child != null)
                    ? widget.child
                    : Row(
                        children: [
                          if (widget.leading != null) ...[
                            widget.leading!,
                            const SizedBox(width: 10),
                          ],
                          if (widget.message != null)
                            Expanded(
                              child: Text(
                                widget.message!,
                                style: widget.messageStyle,
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            if (widget.isClosable ?? false)
              InkWell(
                onTap: widget.onClose,
                child: Icon(
                  Icons.close,
                  color: widget.iconColor,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}



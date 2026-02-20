import 'package:flutter/material.dart';

import 'animation/animation.builder.dart';

/// The visual toast widget with slide animation, shadow, and interaction.
class ToastWidget extends StatefulWidget {
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
  State<ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller!,
      builder: (context, _) {
        final animationValue = CurvedAnimation(
          parent: widget.controller!,
          curve: widget.slideCurve ?? Curves.elasticOut,
          reverseCurve: widget.slideCurve ?? Curves.elasticOut,
        );

        Widget content = _buildContent(context);

        // Use custom animation builder if provided
        if (widget.animationBuilder != null) {
          return widget.animationBuilder!(
            context,
            content,
            widget.controller!,
            widget.controller!.value,
          );
        }

        // Default slide animation
        final offset = Tween<Offset>(
          begin: Offset(0.0, widget.isTop == true ? -1 : 1.0),
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

  Widget _buildContent(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: widget.backgroundColor ?? Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: widget.isInFront ? 0.5 : 0.0,
              offset: const Offset(0.0, -1.0),
              color: widget.shadowColor ?? Colors.grey.shade400,
            ),
            BoxShadow(
              blurRadius: widget.isInFront ? 12 : 3,
              offset: const Offset(0.0, 7.0),
              color: widget.shadowColor ?? Colors.grey.shade400,
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

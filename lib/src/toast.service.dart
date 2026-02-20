import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'animation/animation.builder.dart';
import 'toast.future.dart';
import 'toast.length.dart';
import 'toast.position.dart';
import 'toast.theme.dart';
import 'toast.widget.dart';

/// Show and manage toast notifications.
///
/// Wrap your app with [ToastDev] to enable context-free usage:
/// ```dart
/// ToastService.showToast(message: "Hello!");
/// ```
class ToastService {
  // ── Internal state ──────────────────────────────────────────────────

  static final _expandedIndex = ValueNotifier<int>(-1);
  static final List<OverlayEntry?> _overlayEntries = [];
  static final List<double> _overlayPositions = [];
  static final List<int> _overlayIndexList = [];
  static final List<AnimationController?> _animationControllers = [];
  static OverlayState? _overlayState;

  static int? _showToastNumber;

  static final _cache = <dynamic, AnimationController>{};
  static final _futures = <AnimationController, ToastFuture>{};

  // ── Context-free support ────────────────────────────────────────────

  static final LinkedHashMap<State, BuildContext> _contextMap =
      LinkedHashMap<State, BuildContext>();

  /// Called by [ToastDev] to register its context.
  static void registerContext(State state, BuildContext context) {
    _contextMap[state] = context;
  }

  /// Called by [ToastDev] when disposed.
  static void unregisterContext(State state) {
    _contextMap.remove(state);
  }

  static BuildContext _resolveContext(BuildContext? context) {
    if (context != null) return context;
    if (_contextMap.isNotEmpty) return _contextMap.values.first;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary('No BuildContext available for ToastService.'),
      ErrorDescription(
        'Either pass a BuildContext explicitly, or wrap your app '
        'with a ToastDev widget.',
      ),
      ErrorHint(
        'The most common way is to wrap your MaterialApp:\n'
        '  ToastDev(child: MaterialApp(...))',
      ),
    ]);
  }

  // ── Configuration ───────────────────────────────────────────────────

  /// Set the maximum number of visible toasts (default: 5).
  static void showToastNumber(int val) {
    assert(val > 0,
        "Show toast number can't be negative or zero. Default is 5.");
    if (val > 0) {
      _showToastNumber = val;
    }
  }

  // ── Internal helpers ────────────────────────────────────────────────

  static Future _reverseAnimation(int index,
      {bool isRemoveOverlay = true}) async {
    if (_overlayIndexList.contains(index)) {
      await _animationControllers[index]?.reverse();
      // Safety check: verify the toast still exists after the await
      if (!_overlayIndexList.contains(index)) return;
      
      await Future.delayed(const Duration(milliseconds: 50));
      // Safety check: verify the toast still exists after the delay
      if (!_overlayIndexList.contains(index)) return;

      if (isRemoveOverlay) {
        _removeOverlayEntry(index);
      }
      _cache.removeWhere((_, value) => value == _animationControllers[index]);
    }
  }

  static void _removeOverlayEntry(int index) {
    if (!_overlayIndexList.contains(index)) return;

    _overlayEntries[index]?.remove();
    final controller = _animationControllers[index];
    controller?.dispose();
    _overlayIndexList.remove(index);
    _futures.remove(controller);
  }

  static void _forwardAnimation(int index) {
    _overlayState?.insert(_overlayEntries[index]!);
    _animationControllers[index]?.forward();
  }

  static double _calculatePosition(int index) {
    return _overlayPositions[index];
  }

  static void _addOverlayPosition(int index) {
    _overlayPositions.add(30);
    _overlayIndexList.add(index);
  }

  static bool _isToastInFront(int index) =>
      index > _overlayPositions.length - 5;

  static void _updateOverlayPositions({bool isReverse = false, int pos = 0}) {
    if (isReverse) {
      _reverseUpdatePositions(pos: pos);
    } else {
      _forwardUpdatePositions();
    }
  }

  static void _rebuildPositions() {
    for (int i = 0; i < _overlayPositions.length; i++) {
      _overlayEntries[i]?.markNeedsBuild();
    }
  }

  static void _reverseUpdatePositions({int pos = 0}) {
    for (int i = pos - 1; i >= 0; i--) {
      _overlayPositions[i] = _overlayPositions[i] - 10;
      _overlayEntries[i]?.markNeedsBuild();
    }
  }

  static void _forwardUpdatePositions() {
    for (int i = 0; i < _overlayPositions.length; i++) {
      _overlayPositions[i] = _overlayPositions[i] + 10;
      _overlayEntries[i]?.markNeedsBuild();
    }
  }

  static double _calculateOpacity(int index) {
    int noOfShowToast = _showToastNumber ?? 5;
    if (_overlayIndexList.length <= noOfShowToast) return 1;
    final isFirstFiveToast = _overlayIndexList
        .sublist(_overlayIndexList.length - noOfShowToast)
        .contains(index);
    return isFirstFiveToast ? 1 : 0;
  }

  static void _toggleExpand(int index) {
    if (_expandedIndex.value == index) {
      _expandedIndex.value = -1;
    } else {
      _expandedIndex.value = index;
    }
    _rebuildPositions();
  }

  static void _close(AnimationController controller) {
    final index = _animationControllers.indexOf(controller);
    if (index == -1 || !_overlayIndexList.contains(index)) return;

    _removeOverlayEntry(index);
    _updateOverlayPositions(
      isReverse: true,
      pos: index,
    );
    _cache.removeWhere((_, value) => value == controller);
  }

  // ── Core show method ────────────────────────────────────────────────

  static ToastFuture _showToast({
    BuildContext? context,
    dynamic tag,
    String? message,
    TextStyle? messageStyle,
    Widget? leading,
    Widget? child,
    bool? isClosable,
    bool isAutoDismiss = true,
    ToastPosition? position,
    double? expandedHeight,
    Color? backgroundColor,
    Color? shadowColor,
    Color? iconColor,
    Curve? slideCurve,
    Curve? positionCurve,
    ToastLength? length,
    DismissDirection? dismissDirection,
    ToastAnimationBuilder? animationBuilder,
    Duration? animationDuration,
  }) {
    context = _resolveContext(context);

    // Read theme defaults
    final theme = ToastTheme.maybeOf(context);
    final isTop = (position ?? theme?.position ?? ToastPosition.top) == ToastPosition.top;
    final effectiveLength = length ?? theme?.length ?? ToastLength.short;
    final effectiveDismissDir = dismissDirection ?? theme?.dismissDirection ?? DismissDirection.up;
    final effectiveExpandedHeight = expandedHeight ?? theme?.expandedHeight ?? 100.0;
    final effectiveClosable = isClosable ?? theme?.isClosable ?? false;
    final effectivePositionCurve = positionCurve ?? theme?.positionCurve ?? Curves.elasticOut;
    final effectiveSlideCurve = slideCurve ?? theme?.slideCurve;
    final effectiveBgColor = backgroundColor ?? theme?.backgroundColor;
    final effectiveShadowColor = shadowColor ?? theme?.shadowColor;
    final effectiveIconColor = iconColor ?? theme?.iconColor;
    final effectiveMessageStyle = messageStyle ?? theme?.messageStyle;
    final effectiveAnimBuilder = animationBuilder ?? theme?.animationBuilder;
    final effectiveAnimDuration = animationDuration ?? theme?.animationDuration ?? const Duration(milliseconds: 1000);

    assert(effectiveExpandedHeight >= 0.0,
        "Expanded height should not be a negative number!");

    late final ToastFuture future;

    if (context.mounted) {
      _overlayState = Overlay.of(context);
      final controller = AnimationController(
        vsync: _overlayState!,
        duration: effectiveAnimDuration,
        reverseDuration: effectiveAnimDuration,
      );
      _animationControllers.add(controller);
      final controllerIndex = _animationControllers.indexOf(controller);
      _addOverlayPosition(controllerIndex);
      final dragProgress = ValueNotifier<double>(1.0);

      final overlayEntry = OverlayEntry(
        builder: (context) {
          final paddingTop = MediaQuery.paddingOf(context).top;
          final pos = _calculatePosition(controllerIndex) +
              (_expandedIndex.value == controllerIndex
                  ? effectiveExpandedHeight
                  : 0.0);
          return AnimatedPositioned(
            top: isTop ? paddingTop + pos : null,
            bottom: isTop ? null : pos,
            left: 10,
            right: 10,
            duration: const Duration(milliseconds: 500),
            curve: effectivePositionCurve,
            child: Dismissible(
              key: Key(UniqueKey().toString()),
              direction: effectiveDismissDir,
              onUpdate: (details) {
                dragProgress.value = 1.0 - details.progress.clamp(0.0, 1.0);
              },
              onDismissed: (_) {
                _close(controller);
              },
              child: ValueListenableBuilder<double>(
                valueListenable: dragProgress,
                builder: (context, opacity, child) {
                  return Opacity(
                    opacity: opacity,
                    child: child,
                  );
                },
                child: AnimatedPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: (_expandedIndex.value == controllerIndex
                        ? 10
                        : max(_calculatePosition(controllerIndex) - 35, 0.0)),
                  ),
                  duration: const Duration(milliseconds: 500),
                  curve: effectivePositionCurve,
                  child: AnimatedOpacity(
                    opacity: _calculateOpacity(controllerIndex),
                    duration: const Duration(milliseconds: 500),
                    child: ToastWidget(
                      message: message,
                      messageStyle: effectiveMessageStyle,
                      backgroundColor: effectiveBgColor,
                      shadowColor: effectiveShadowColor,
                      iconColor: effectiveIconColor,
                      slideCurve: effectiveSlideCurve,
                      isClosable: effectiveClosable,
                      isTop: isTop,
                      isInFront: _isToastInFront(
                          _animationControllers.indexOf(controller)),
                      controller: controller,
                      animationBuilder: effectiveAnimBuilder,
                      onTap: () => _toggleExpand(controllerIndex),
                      onClose: () {
                        _close(controller);
                      },
                      leading: leading,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

      _overlayEntries.add(overlayEntry);
      _updateOverlayPositions();
      _forwardAnimation(_animationControllers.indexOf(controller));
      _cache.putIfAbsent(tag, () => controller);

      future = ToastFuture.create(
        entry: overlayEntry,
        controller: controller,
        onDismiss: () {
          _close(controller);
        },
      );
      _futures[controller] = future;

      if (isAutoDismiss) {
        future.setTimer(effectiveLength.duration);
        Future.delayed(effectiveLength.duration, () async {
          await _reverseAnimation(
            _animationControllers.indexOf(controller),
            isRemoveOverlay: false,
          );
          _close(controller);
        });
      }
    } else {
      // Return a no-op future if context is not mounted
      future = ToastFuture.create(
        entry: OverlayEntry(builder: (_) => const SizedBox.shrink()),
        controller: AnimationController(
          vsync: const _NoTickerProvider(),
          duration: Duration.zero,
        ),
      );
      future.dismiss();
    }

    return future;
  }
  // ── Public API (top-level functions below) ──────────────────────────

  static Future dismiss({dynamic tag}) async {
    if (tag != null) {
      final controller = _cache[tag];
      await _reverseAnimation(_animationControllers.indexOf(controller));
    } else {
      for (int index = 0; index < _animationControllers.length; index++) {
        await _reverseAnimation(index);
      }
    }
  }
}

// ── Top-level API ─────────────────────────────────────────────────────

/// Show a simple message toast.
///
/// ```dart
/// showToast(message: "Hello!");
/// ```
ToastFuture showToast({
  BuildContext? context,
  dynamic tag,
  String? message,
  TextStyle? messageStyle,
  Widget? leading,
  bool? isClosable,
  bool isAutoDismiss = true,
  ToastPosition? position,
  double? expandedHeight,
  Color? backgroundColor,
  Color? shadowColor,
  Color? iconColor,
  Curve? slideCurve,
  Curve? positionCurve,
  ToastLength? length,
  DismissDirection? dismissDirection,
  ToastAnimationBuilder? animationBuilder,
  Duration? animationDuration,
}) {
  return ToastService._showToast(
    context: context,
    tag: tag,
    message: message,
    messageStyle: messageStyle,
    isClosable: isClosable,
    isAutoDismiss: isAutoDismiss,
    position: position,
    expandedHeight: expandedHeight,
    backgroundColor: backgroundColor,
    shadowColor: shadowColor,
    iconColor: iconColor,
    positionCurve: positionCurve,
    length: length,
    dismissDirection: dismissDirection,
    leading: leading,
    animationBuilder: animationBuilder,
    animationDuration: animationDuration,
  );
}

/// Show a toast with a custom child widget.
///
/// ```dart
/// showWidgetToast(
///   child: ListTile(title: Text("Custom!")),
/// );
/// ```
ToastFuture showWidgetToast({
  BuildContext? context,
  dynamic tag,
  Widget? child,
  bool? isClosable,
  bool isAutoDismiss = true,
  ToastPosition? position,
  double? expandedHeight,
  Color? backgroundColor,
  Color? shadowColor,
  Color? iconColor,
  Curve? slideCurve,
  Curve? positionCurve,
  ToastLength? length,
  DismissDirection? dismissDirection,
  ToastAnimationBuilder? animationBuilder,
  Duration? animationDuration,
}) {
  return ToastService._showToast(
    context: context,
    tag: tag,
    isClosable: isClosable,
    isAutoDismiss: isAutoDismiss,
    position: position,
    expandedHeight: expandedHeight,
    backgroundColor: backgroundColor,
    shadowColor: shadowColor,
    iconColor: iconColor,
    positionCurve: positionCurve,
    length: length,
    dismissDirection: dismissDirection,
    child: child,
    animationBuilder: animationBuilder,
    animationDuration: animationDuration,
  );
}

/// Dismiss a specific toast by [tag], or all toasts if [tag] is null.
///
/// ```dart
/// dismissToast();       // dismiss all
/// dismissToast(tag: 1); // dismiss specific
/// ```
Future dismissToast({dynamic tag}) => ToastService.dismiss(tag: tag);

/// A no-op TickerProvider for fallback ToastFuture when context isn't mounted.
class _NoTickerProvider extends TickerProvider {
  const _NoTickerProvider();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

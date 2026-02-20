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
  static final List<_ToastEntry> _activeToasts = [];
  static OverlayState? _overlayState;

  static int? _showToastNumber;

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
    assert(
        val > 0, "Show toast number can't be negative or zero. Default is 5.");
    if (val > 0) {
      _showToastNumber = val;
    }
  }

  // ── Internal helpers ────────────────────────────────────────────────

  static Future _reverseAnimation(_ToastEntry entry,
      {bool isRemoveOverlay = true}) async {
    if (_activeToasts.contains(entry)) {
      await entry.controller.reverse();
      // Safety check: verify the toast still exists after the await
      if (!_activeToasts.contains(entry)) return;

      await Future.delayed(const Duration(milliseconds: 50));
      // Safety check: verify the toast still exists after the delay
      if (!_activeToasts.contains(entry)) return;

      if (isRemoveOverlay) {
        _removeOverlayEntry(entry);
      }
    }
  }

  static void _removeOverlayEntry(_ToastEntry entry) {
    if (!_activeToasts.contains(entry)) return;

    entry.overlayEntry.remove();
    entry.controller.dispose();
    _activeToasts.remove(entry);
  }

  static void _forwardAnimation(_ToastEntry entry) {
    _overlayState?.insert(entry.overlayEntry);
    entry.controller.forward();
  }

  static double _calculatePosition(_ToastEntry entry) {
    return entry.position.value;
  }

  static void _addOverlayEntry(_ToastEntry entry) {
    _activeToasts.add(entry);
  }

  static bool _isToastInFront(_ToastEntry entry) {
    final index = _activeToasts.indexOf(entry);
    if (index == -1) return false;
    return index > _activeToasts.length - 5;
  }

  static void _updateOverlayPositions({bool isReverse = false, int pos = 0}) {
    if (isReverse) {
      _reverseUpdatePositions(pos: pos);
    } else {
      _forwardUpdatePositions();
    }
  }

  static void _rebuildPositions() {
    for (final entry in _activeToasts) {
      entry.overlayEntry.markNeedsBuild();
    }
  }

  static void _reverseUpdatePositions({int pos = 0}) {
    for (int i = pos - 1; i >= 0; i--) {
      _activeToasts[i].position.value -= 10;
      _activeToasts[i].overlayEntry.markNeedsBuild();
    }
  }

  static void _forwardUpdatePositions() {
    for (final entry in _activeToasts) {
      entry.position.value += 10;
      entry.overlayEntry.markNeedsBuild();
    }
  }

  static double _calculateOpacity(_ToastEntry entry) {
    int noOfShowToast = _showToastNumber ?? 5;
    if (_activeToasts.length <= noOfShowToast) return 1;
    final index = _activeToasts.indexOf(entry);
    if (index == -1) return 0;
    return (index >= _activeToasts.length - noOfShowToast) ? 1 : 0;
  }

  static void _toggleExpand(_ToastEntry entry) {
    final index = _activeToasts.indexOf(entry);
    if (_expandedIndex.value == index) {
      _expandedIndex.value = -1;
    } else {
      _expandedIndex.value = index;
    }
    _rebuildPositions();
  }

  static void _close(_ToastEntry entry) {
    final index = _activeToasts.indexOf(entry);
    if (index == -1) return;

    _removeOverlayEntry(entry);
    _updateOverlayPositions(
      isReverse: true,
      pos: index,
    );
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
    final isTop =
        (position ?? theme?.position ?? ToastPosition.top) == ToastPosition.top;
    final effectiveLength = length ?? theme?.length ?? ToastLength.short;
    final effectiveDismissDir =
        dismissDirection ?? theme?.dismissDirection ?? DismissDirection.up;
    final effectiveExpandedHeight =
        expandedHeight ?? theme?.expandedHeight ?? 100.0;
    final effectiveClosable = isClosable ?? theme?.isClosable ?? false;
    final effectivePositionCurve =
        positionCurve ?? theme?.positionCurve ?? Curves.elasticOut;
    final effectiveSlideCurve = slideCurve ?? theme?.slideCurve;
    final effectiveBgColor = backgroundColor ?? theme?.backgroundColor;
    final effectiveShadowColor = shadowColor ?? theme?.shadowColor;
    final effectiveIconColor = iconColor ?? theme?.iconColor;
    final effectiveMessageStyle = messageStyle ?? theme?.messageStyle;
    final effectiveAnimBuilder = animationBuilder ?? theme?.animationBuilder;
    final effectiveAnimDuration = animationDuration ??
        theme?.animationDuration ??
        const Duration(milliseconds: 1000);

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

      final toastPosition = ValueNotifier<double>(30.0);
      final dragProgress = ValueNotifier<double>(1.0);

      late final _ToastEntry entry;
      final overlayEntry = OverlayEntry(
        builder: (context) {
          final paddingTop = MediaQuery.paddingOf(context).top;
          return ValueListenableBuilder<double>(
            valueListenable: toastPosition,
            builder: (context, currentPos, _) {
              final pos = currentPos +
                  (_activeToasts.indexOf(entry) == _expandedIndex.value
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
                    _close(entry);
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
                        horizontal: (_activeToasts.indexOf(entry) ==
                                _expandedIndex.value
                            ? 10
                            : max(currentPos - 35, 0.0)),
                      ),
                      duration: const Duration(milliseconds: 500),
                      curve: effectivePositionCurve,
                      child: ValueListenableBuilder<int>(
                        valueListenable: _expandedIndex,
                        builder: (context, _, child) {
                          return AnimatedOpacity(
                            opacity: _calculateOpacity(entry),
                            duration: const Duration(milliseconds: 500),
                            child: child,
                          );
                        },
                        child: ToastWidget(
                          message: message,
                          messageStyle: effectiveMessageStyle,
                          backgroundColor: effectiveBgColor,
                          shadowColor: effectiveShadowColor,
                          iconColor: effectiveIconColor,
                          slideCurve: effectiveSlideCurve,
                          isClosable: effectiveClosable,
                          isTop: isTop,
                          isInFront: _isToastInFront(entry),
                          controller: controller,
                          animationBuilder: effectiveAnimBuilder,
                          onTap: () => _toggleExpand(entry),
                          onClose: () {
                            _close(entry);
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
        },
      );

      entry = _ToastEntry(
        overlayEntry: overlayEntry,
        controller: controller,
        tag: tag,
        position: toastPosition,
      );

      _addOverlayEntry(entry);
      _updateOverlayPositions();
      _forwardAnimation(entry);

      future = ToastFuture.create(
        entry: overlayEntry,
        controller: controller,
        onDismiss: () {
          _close(entry);
        },
      );

      if (isAutoDismiss) {
        future.setTimer(effectiveLength.duration);
        Future.delayed(effectiveLength.duration, () async {
          await _reverseAnimation(entry, isRemoveOverlay: false);
          _close(entry);
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
      final entries = _activeToasts.where((e) => e.tag == tag).toList();
      for (final entry in entries) {
        await _reverseAnimation(entry);
      }
    } else {
      final entries = List<_ToastEntry>.from(_activeToasts);
      for (final entry in entries) {
        await _reverseAnimation(entry);
      }
    }
  }
}

/// Internal class to hold toast state.
class _ToastEntry {
  final OverlayEntry overlayEntry;
  final AnimationController controller;
  final dynamic tag;
  final ValueNotifier<double> position;

  _ToastEntry({
    required this.overlayEntry,
    required this.controller,
    required this.tag,
    required this.position,
  });
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

import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'animation/animation.builder.dart';
import 'toast.future.dart';
import 'toast.length.dart';
import 'toast.position.dart';

import 'toast.widget.dart';

class ToastService {
  static final _expandedIndex = ValueNotifier<int>(-1);
  static final _toastCount = ValueNotifier<int>(0);
  static final List<_ToastEntry> _activeToasts = [];

  static int? _showToastNumber;

  static final LinkedHashMap<State, BuildContext> _contextMap =
      LinkedHashMap<State, BuildContext>();

  static void registerContext(State state, BuildContext context) {
    _contextMap[state] = context;
  }

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

  static const int _defaultMaxToasts = 5;
  static const double _toastSpacing = 10.0;
  static const double _initialPosition = 30.0;

  static void showToastNumber(int val) {
    assert(
        val > 0, "Show toast number can't be negative or zero. Default is 5.");
    if (val > 0) {
      _showToastNumber = val;
    }
  }

  static Future _reverseAnimation(_ToastEntry entry,
      {bool isRemoveOverlay = true}) async {
    if (_activeToasts.contains(entry)) {
      final state = entry.stateKey.currentState;
      if (state != null) {
        await state.reverseAnimation();
      }

      if (!_activeToasts.contains(entry)) return;

      await Future.delayed(const Duration(milliseconds: 50));

      if (!_activeToasts.contains(entry)) return;

      if (isRemoveOverlay) {
        _removeOverlayEntry(entry);
      }
    }
  }

  static void _removeOverlayEntry(_ToastEntry entry) {
    if (!_activeToasts.contains(entry)) return;

    entry.overlayEntry.remove();
    entry.position.dispose();
    _activeToasts.remove(entry);
  }

  static void _addOverlayEntry(_ToastEntry entry) {
    _activeToasts.add(entry);
    _toastCount.value = _activeToasts.length;
  }

  static bool _isToastInFront(_ToastEntry entry) {
    final index = _activeToasts.indexOf(entry);
    if (index == -1) return false;
    return index >
        _activeToasts.length - (_showToastNumber ?? _defaultMaxToasts);
  }

  static void _updateOverlayPositions({bool isReverse = false, int pos = 0}) {
    if (isReverse) {
      _reverseUpdatePositions(pos: pos);
    } else {
      _forwardUpdatePositions();
    }
  }

  static void _rebuildPositions() {}

  static void _reverseUpdatePositions({int pos = 0}) {
    for (int i = pos - 1; i >= 0; i--) {
      _activeToasts[i].position.value -= _toastSpacing;
    }
  }

  static void _forwardUpdatePositions() {
    for (final entry in _activeToasts) {
      entry.position.value += _toastSpacing;
    }
  }

  static double _calculateOpacity(_ToastEntry entry) {
    int noOfShowToast = _showToastNumber ?? _defaultMaxToasts;
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
    _toastCount.value = _activeToasts.length;
  }

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

    final isTop = (position ?? ToastPosition.top) == ToastPosition.top;
    final effectiveLength = length ?? ToastLength.short;
    final effectiveDismissDir = dismissDirection ?? DismissDirection.up;
    final effectiveExpandedHeight = expandedHeight ?? 100.0;
    final effectiveClosable = isClosable ?? false;
    final effectivePositionCurve = positionCurve ?? Curves.elasticOut;
    final effectiveSlideCurve = slideCurve;
    final effectiveBgColor = backgroundColor;
    final effectiveShadowColor = shadowColor;
    final effectiveIconColor = iconColor;
    final effectiveMessageStyle = messageStyle;
    final effectiveAnimBuilder = animationBuilder;
    final effectiveAnimDuration =
        animationDuration ?? const Duration(milliseconds: 1000);

    assert(effectiveExpandedHeight >= 0.0,
        "Expanded height should not be a negative number!");

    late final ToastFuture future;

    if (context.mounted) {
      final overlayState = Overlay.of(context);
      final toastPosition = ValueNotifier<double>(_initialPosition);

      late final _ToastEntry entry;
      final key = GlobalKey<_ToastOverlayUIState>();

      final overlayEntry = OverlayEntry(
        builder: (context) => _ToastOverlayUI(
          key: key,
          entry: entry,
          isTop: isTop,
          effectiveExpandedHeight: effectiveExpandedHeight,
          effectivePositionCurve: effectivePositionCurve,
          effectiveDismissDir: effectiveDismissDir,
          effectiveMessageStyle: effectiveMessageStyle,
          effectiveBgColor: effectiveBgColor,
          effectiveShadowColor: effectiveShadowColor,
          effectiveIconColor: effectiveIconColor,
          effectiveSlideCurve: effectiveSlideCurve,
          effectiveClosable: effectiveClosable,
          effectiveAnimBuilder: effectiveAnimBuilder,
          effectiveAnimDuration: effectiveAnimDuration,
          message: message,
          leading: leading,
          child: child,
        ),
      );

      entry = _ToastEntry(
        overlayEntry: overlayEntry,
        tag: tag,
        position: toastPosition,
        stateKey: key,
      );

      _addOverlayEntry(entry);
      overlayState.insert(entry.overlayEntry);
      _updateOverlayPositions();

      future = ToastFuture.create(
        entry: overlayEntry,
        controller: AnimationController(
          vsync: const _NoTickerProvider(),
          duration: Duration.zero,
        ),
        onDismiss: () {
          _close(entry);
        },
      );

      if (isAutoDismiss) {
        future.setTimer(effectiveLength.duration);
        future.onDismissedWithAnimation = () async {
          await _reverseAnimation(entry, isRemoveOverlay: false);
          _close(entry);
        };
      }
    } else {
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

class _ToastEntry {
  final OverlayEntry overlayEntry;
  final dynamic tag;
  final ValueNotifier<double> position;
  final GlobalKey<_ToastOverlayUIState> stateKey;

  _ToastEntry({
    required this.overlayEntry,
    required this.tag,
    required this.position,
    required this.stateKey,
  });
}

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
    slideCurve: slideCurve,
    length: length,
    dismissDirection: dismissDirection,
    leading: leading,
    animationBuilder: animationBuilder,
    animationDuration: animationDuration,
  );
}

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
    slideCurve: slideCurve,
    length: length,
    dismissDirection: dismissDirection,
    child: child,
    animationBuilder: animationBuilder,
    animationDuration: animationDuration,
  );
}

Future dismissToast({dynamic tag}) => ToastService.dismiss(tag: tag);

class _NoTickerProvider extends TickerProvider {
  const _NoTickerProvider();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

class _ToastOverlayUI extends StatefulWidget {
  const _ToastOverlayUI({
    super.key,
    required this.entry,
    required this.isTop,
    required this.effectiveExpandedHeight,
    required this.effectivePositionCurve,
    required this.effectiveDismissDir,
    required this.effectiveMessageStyle,
    required this.effectiveBgColor,
    required this.effectiveShadowColor,
    required this.effectiveIconColor,
    required this.effectiveSlideCurve,
    required this.effectiveClosable,
    required this.effectiveAnimBuilder,
    required this.effectiveAnimDuration,
    this.message,
    this.leading,
    this.child,
  });

  final _ToastEntry entry;
  final bool isTop;
  final double effectiveExpandedHeight;
  final Curve effectivePositionCurve;
  final DismissDirection effectiveDismissDir;
  final TextStyle? effectiveMessageStyle;
  final Color? effectiveBgColor;
  final Color? effectiveShadowColor;
  final Color? effectiveIconColor;
  final Curve? effectiveSlideCurve;
  final bool effectiveClosable;
  final ToastAnimationBuilder? effectiveAnimBuilder;
  final Duration effectiveAnimDuration;
  final String? message;
  final Widget? leading;
  final Widget? child;

  @override
  State<_ToastOverlayUI> createState() => _ToastOverlayUIState();
}

class _ToastOverlayUIState extends State<_ToastOverlayUI>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ValueNotifier<double> _dragProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.effectiveAnimDuration,
      reverseDuration: widget.effectiveAnimDuration,
    );
    _dragProgress = ValueNotifier<double>(1.0);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _dragProgress.dispose();
    super.dispose();
  }

  Future<void> reverseAnimation() async {
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.paddingOf(context).top;
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.entry.position,
        ToastService._expandedIndex,
        ToastService._toastCount
      ]),
      builder: (context, _) {
        final index = ToastService._activeToasts.indexOf(widget.entry);
        if (index == -1) return const SizedBox.shrink();

        final pos = widget.entry.position.value +
            (index == ToastService._expandedIndex.value
                ? widget.effectiveExpandedHeight
                : 0.0);
        return AnimatedPositioned(
          top: widget.isTop ? paddingTop + pos : null,
          bottom: widget.isTop ? null : pos,
          left: 10,
          right: 10,
          duration: const Duration(milliseconds: 300),
          curve: widget.effectivePositionCurve,
          child: Dismissible(
            key: ObjectKey(widget.entry),
            direction: widget.effectiveDismissDir,
            onUpdate: (details) {
              _dragProgress.value = 1.0 - details.progress.clamp(0.0, 1.0);
            },
            onDismissed: (_) {
              ToastService._close(widget.entry);
            },
            child: ValueListenableBuilder<double>(
              valueListenable: _dragProgress,
              builder: (context, opacity, child) {
                return Opacity(
                  opacity: opacity,
                  child: child,
                );
              },
              child: AnimatedPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: (index == ToastService._expandedIndex.value
                      ? 10
                      : max(widget.entry.position.value - 35, 0.0)),
                ),
                duration: const Duration(milliseconds: 300),
                curve: widget.effectivePositionCurve,
                child: AnimatedOpacity(
                  opacity: ToastService._calculateOpacity(widget.entry),
                  duration: const Duration(milliseconds: 300),
                  child: ToastWidget(
                    message: widget.message,
                    messageStyle: widget.effectiveMessageStyle,
                    backgroundColor: widget.effectiveBgColor,
                    shadowColor: widget.effectiveShadowColor,
                    iconColor: widget.effectiveIconColor,
                    slideCurve: widget.effectiveSlideCurve,
                    isClosable: widget.effectiveClosable,
                    isTop: widget.isTop,
                    isInFront: ToastService._isToastInFront(widget.entry),
                    controller: _controller,
                    animationBuilder: widget.effectiveAnimBuilder,
                    onTap: () => ToastService._toggleExpand(widget.entry),
                    onClose: () async {
                      await _controller.reverse();
                      ToastService._close(widget.entry);
                    },
                    leading: widget.leading,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

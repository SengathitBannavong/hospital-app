import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable widget that implements an edge-swipe-only [PageView] with smooth,
/// premium animations resembling iOS interactive page transitions and Samsung
/// One UI.
///
/// It disables normal horizontal PageView scrolling, allowing nested widgets
/// (like maps or horizontal lists) to receive gestures across 95% of the
/// screen. Swiping is only activated when a drag starts within the
/// configurable edge zones.
class EdgeSwipePageView extends StatefulWidget {
  const EdgeSwipePageView({
    required this.children,
    required this.currentIndex,
    required this.onPageChanged,
    this.edgeWidth = 24.0,
    this.animationDuration = const Duration(milliseconds: 350),
    this.swipeThreshold = 0.25,
    this.enableHapticFeedback = true,
    super.key,
  }) : assert(children.length > 0);

  /// The list of pages/widgets to display.
  final List<Widget> children;

  /// The index of the currently active page.
  final int currentIndex;

  /// Callback when a page navigation is successfully completed.
  final ValueChanged<int> onPageChanged;

  /// The width of the left and right interactive edge zones in pixels.
  final double edgeWidth;

  /// The duration of the slide animation when finishing or canceling a swipe.
  final Duration animationDuration;

  /// The percentage of screen width (from 0.0 to 1.0) the user must drag
  /// to trigger the page transition on release.
  final double swipeThreshold;

  /// Whether to trigger a light haptic feedback vibration when the drag
  /// distance crosses the swipe threshold.
  final bool enableHapticFeedback;

  @override
  State<EdgeSwipePageView> createState() => _EdgeSwipePageViewState();
}

class _EdgeSwipePageViewState extends State<EdgeSwipePageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  double _dragOffset = 0.0;
  bool _isDragging = false;
  // 1 for Left-to-Right (prev), -1 for Right-to-Left (next)
  int _dragDirection = 0;
  int? _targetPageIndex;
  bool _hapticTriggered = false;

  late double _pageValue;
  double _startPageValue = 0.0;
  double _endPageValue = 0.0;

  // Programmatic navigation transition states (e.g. from bottom bar clicks)
  bool _isTransitioning = false;
  int? _animatingFromIndex;
  int? _animatingToIndex;

  @override
  void initState() {
    super.initState();
    _pageValue = widget.currentIndex.toDouble();

    _animationController = AnimationController(vsync: this);

    _animationController.addListener(() {
      if (!mounted) return;
      if (!_isTransitioning) {
        setState(() {
          final t = _animationController.value;
          // Easing transition for smooth completion/cancel animations
          final curveValue = Curves.easeOutCubic.transform(t);
          _pageValue =
              _startPageValue + (_endPageValue - _startPageValue) * curveValue;
        });
      } else {
        // Trigger a rebuild to animate the Stack transition
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(EdgeSwipePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      // If the index change matches our current page value (e.g. from a
      // completed swipe or completed transition), do not trigger a new
      // transition.
      if ((widget.currentIndex.toDouble() - _pageValue).abs() < 0.01) {
        return;
      }

      _startProgrammaticTransition(
        from: oldWidget.currentIndex,
        to: widget.currentIndex,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startProgrammaticTransition({required int from, required int to}) {
    setState(() {
      _isTransitioning = true;
      _isDragging = false;
      _animatingFromIndex = from;
      _animatingToIndex = to;
    });

    _animationController
      ..stop()
      ..duration = widget.animationDuration
      ..forward(from: 0.0).then((_) {
        if (!mounted) return;
        setState(() {
          _isTransitioning = false;
          _pageValue = to.toDouble();
        });
        widget.onPageChanged(to);
      });
  }

  void _onDragStartLeft(DragStartDetails details) {
    if (widget.currentIndex == 0 || _animationController.isAnimating) return;
    _startDrag(details);
    _dragDirection = 1;
    _targetPageIndex = widget.currentIndex - 1;
  }

  void _onDragStartRight(DragStartDetails details) {
    if (widget.currentIndex == widget.children.length - 1 ||
        _animationController.isAnimating) {
      return;
    }
    _startDrag(details);
    _dragDirection = -1;
    _targetPageIndex = widget.currentIndex + 1;
  }

  void _startDrag(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset = 0.0;
      _hapticTriggered = false;
      _pageValue = widget.currentIndex.toDouble();
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    final screenWidth = MediaQuery.of(context).size.width;

    setState(() {
      _dragOffset += details.delta.dx;

      // Clamp the drag offset based on direction
      if (_dragDirection == 1) {
        if (_dragOffset < 0.0) _dragOffset = 0.0;
        if (_dragOffset > screenWidth) _dragOffset = screenWidth;
      } else {
        if (_dragOffset > 0.0) _dragOffset = 0.0;
        if (_dragOffset < -screenWidth) _dragOffset = -screenWidth;
      }

      _pageValue = widget.currentIndex.toDouble() - (_dragOffset / screenWidth);

      // Check for swipe threshold and trigger haptics
      final dragFraction = _dragOffset.abs() / screenWidth;
      if (widget.enableHapticFeedback) {
        if (dragFraction >= widget.swipeThreshold) {
          if (!_hapticTriggered) {
            HapticFeedback.lightImpact();
            _hapticTriggered = true;
          }
        } else {
          _hapticTriggered = false;
        }
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final screenWidth = MediaQuery.of(context).size.width;
    final dragFraction = _dragOffset.abs() / screenWidth;
    final velocity = details.primaryVelocity ?? 0.0;

    bool completeNavigation = false;

    // Determine whether to complete the navigation or snap back
    if (dragFraction >= widget.swipeThreshold) {
      completeNavigation = true;
    } else if (_dragDirection == 1 && velocity > 300) {
      completeNavigation = true;
    } else if (_dragDirection == -1 && velocity < -300) {
      completeNavigation = true;
    }

    final int finalPage = completeNavigation
        ? _targetPageIndex!
        : widget.currentIndex;

    // Calculate a velocity-sensitive completion duration
    double remainingFraction = (finalPage.toDouble() - _pageValue).abs();
    int durationMs = widget.animationDuration.inMilliseconds;
    if (velocity.abs() > 100) {
      double pxPerMs = velocity.abs() / 1000.0;
      double distance = remainingFraction * screenWidth;
      int velocityDuration = pxPerMs > 0
          ? (distance / pxPerMs).round()
          : durationMs;
      durationMs = velocityDuration.clamp(
        100,
        widget.animationDuration.inMilliseconds,
      );
    } else {
      durationMs = (widget.animationDuration.inMilliseconds * remainingFraction)
          .round()
          .clamp(100, widget.animationDuration.inMilliseconds);
    }

    _startPageValue = _pageValue;
    _endPageValue = finalPage.toDouble();

    _animationController
      ..stop()
      ..duration = Duration(milliseconds: durationMs)
      ..forward(from: 0.0).then((_) {
        if (completeNavigation && finalPage != widget.currentIndex) {
          setState(() {
            _pageValue = finalPage.toDouble();
          });
          widget.onPageChanged(finalPage);
        }
      });
  }

  Widget _buildTransitionPage(
    BuildContext context, {
    required Widget child,
    required double scale,
    required double translationX,
    double overlayOpacity = 0.0,
    List<BoxShadow>? boxShadow,
  }) {
    return Transform.translate(
      offset: Offset(translationX, 0.0),
      child: Transform.scale(
        scale: scale,
        child: Stack(
          children: [
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: child,
            ),
            if (overlayOpacity > 0.0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withValues(alpha: overlayOpacity),
                  ),
                ),
              ),
            if (boxShadow != null)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 1,
                child: Container(
                  decoration: BoxDecoration(boxShadow: boxShadow),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageWrapper(
    BuildContext context,
    int index,
    double pageValue,
    Widget child,
  ) {
    final double delta = index - pageValue;
    final double absDelta = delta.abs();
    final double screenWidth = MediaQuery.of(context).size.width;

    double scale = 1.0;
    double translationX = 0.0;
    double overlayOpacity = 0.0;
    List<BoxShadow>? boxShadow;

    if (absDelta < 1.0) {
      final int leftIndex = pageValue.floor();
      final int rightIndex = pageValue.ceil();
      final double fraction = pageValue - leftIndex;

      if (leftIndex != rightIndex) {
        if (index == leftIndex) {
          // Bottom page (sliding out to the left)
          scale = 1.0 - 0.05 * fraction;
          translationX = -0.3 * fraction * screenWidth; // Move slightly left
          overlayOpacity = 0.3 * fraction;
        } else if (index == rightIndex) {
          // Top page (sliding in from the right)
          scale = 1.0;
          translationX =
              (1.0 - fraction) * screenWidth; // Move from screenWidth to 0
          boxShadow = [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18 * (1.0 - fraction)),
              blurRadius: 18,
              spreadRadius: 1.5,
              offset: const Offset(-8, 0),
            ),
          ];
        }
      }
    }

    return Offstage(
      offstage: absDelta >= 1.0,
      child: Transform.translate(
        offset: Offset(translationX, 0.0),
        child: Transform.scale(
          scale: scale,
          child: Stack(
            children: [
              // Safe wrapper ensuring pages have backgrounds
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: child,
              ),
              // Dimming overlay for bottom page
              if (overlayOpacity > 0.0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.black.withValues(alpha: overlayOpacity),
                    ),
                  ),
                ),
              // Floating drop shadow overlay cast to the left of top page
              if (boxShadow != null)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 1,
                  child: Container(
                    decoration: BoxDecoration(boxShadow: boxShadow),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (!_isDragging && !_animationController.isAnimating) {
      final expectedValue = widget.currentIndex.toDouble();
      if ((_pageValue - expectedValue).abs() > 0.01) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _pageValue = expectedValue);
        });
      }
    }

    // The main interactive page structure implemented as a simple Stack.
    // By keeping all branches strictly inside the Stack at all times
    // (just hidden via Offstage), they are perfectly maintained in the
    // element tree. This fully prevents GoRouter / Flutter from ever
    // destroying their state.
    final mainPageView = Stack(
      children: [
        // We render all pages simultaneously. Offstage hides the inactive ones.
        for (int i = 0; i < widget.children.length; i++)
          Positioned.fill(
            child: _buildPageWrapper(
              context,
              i,
              _pageValue,
              // Prevent GlobalKey collision by removing the child from this
              // tree while it is being actively animated in the top
              // transition stack.
              (_isTransitioning &&
                      (i == _animatingFromIndex || i == _animatingToIndex))
                  ? const SizedBox.shrink()
                  : widget.children[i],
            ),
          ),
        // Left Edge zone (24px) for swiping to previous page
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: widget.edgeWidth,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: _onDragStartLeft,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
          ),
        ),
        // Right Edge zone (24px) for swiping to next page
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: widget.edgeWidth,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: _onDragStartRight,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
          ),
        ),
      ],
    );

    Widget? bottomPage;
    Widget? topPage;

    if (_isTransitioning) {
      final progress = Curves.easeOutCubic.transform(
        _animationController.value,
      );
      final isForward = _animatingToIndex! > _animatingFromIndex!;

      final Widget sourceWidget = widget.children[_animatingFromIndex!];
      final Widget destWidget = widget.children[_animatingToIndex!];

      if (isForward) {
        // Source is bottom, Dest is top
        bottomPage = _buildTransitionPage(
          context,
          child: sourceWidget,
          scale: 1.0 - 0.05 * progress,
          translationX: -0.3 * progress * screenWidth,
          overlayOpacity: 0.3 * progress,
        );
        topPage = _buildTransitionPage(
          context,
          child: destWidget,
          scale: 1.0,
          translationX: (1.0 - progress) * screenWidth,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18 * (1.0 - progress)),
              blurRadius: 18,
              spreadRadius: 1.5,
              offset: const Offset(-8, 0),
            ),
          ],
        );
      } else {
        // Dest is bottom, Source is top
        bottomPage = _buildTransitionPage(
          context,
          child: destWidget,
          scale: 0.95 + 0.05 * progress,
          translationX: -0.3 * (1.0 - progress) * screenWidth,
          overlayOpacity: 0.3 * (1.0 - progress),
        );
        topPage = _buildTransitionPage(
          context,
          child: sourceWidget,
          scale: 1.0,
          translationX: progress * screenWidth,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18 * (1.0 - progress)),
              blurRadius: 18,
              spreadRadius: 1.5,
              offset: const Offset(-8, 0),
            ),
          ],
        );
      }
    }

    // CRITICAL: We must ALWAYS return the exact same widget tree structure.
    return Stack(
      children: [
        Offstage(offstage: _isTransitioning, child: mainPageView),
        if (_isTransitioning && bottomPage != null) bottomPage,
        if (_isTransitioning && topPage != null) topPage,
      ],
    );
  }
}

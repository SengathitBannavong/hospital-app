part of '../../pages/map_page.dart';

class ExpandableMapActionMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool active;

  const ExpandableMapActionMenuItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
  });
}

class ExpandableMapActionMenu extends StatefulWidget {
  final String tooltip;
  final List<ExpandableMapActionMenuItem> actions;

  const ExpandableMapActionMenu({
    super.key,
    required this.tooltip,
    required this.actions,
  });

  @override
  State<ExpandableMapActionMenu> createState() =>
      _ExpandableMapActionMenuState();
}

class _ExpandableMapActionMenuState extends State<ExpandableMapActionMenu>
    with SingleTickerProviderStateMixin {
  static const Duration _menuDuration = Duration(milliseconds: 300);
  static const Duration _staggerStep = Duration(milliseconds: 40);
  static const double _slideDistance = 0.16;

  final GlobalKey _fabKey = GlobalKey();
  final OverlayPortalController _overlayController = OverlayPortalController();
  late final AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _menuDuration)
      ..addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    // Tear down the overlay (scrim + items) only once the close animation has
    // finished, so the collapse stays visible.
    if (status == AnimationStatus.dismissed && _overlayController.isShowing) {
      _overlayController.hide();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openMenu() {
    if (_isOpen) {
      return;
    }
    setState(() => _isOpen = true);
    _overlayController.show();
    _controller.forward();
  }

  void _closeMenu() {
    if (!_isOpen) {
      return;
    }
    setState(() => _isOpen = false);
    _controller.reverse();
  }

  void _toggleMenu() => _isOpen ? _closeMenu() : _openMenu();

  void _handleActionTap(ExpandableMapActionMenuItem item) {
    _closeMenu();
    item.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: _buildOverlay,
      child: KeyedSubtree(key: _fabKey, child: _buildMainButton(context)),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    // Anchor the popup to the FAB's real on-screen rect so it always grows
    // straight up from the button's left edge (not centered on the overlay).
    final fabBox = _fabKey.currentContext?.findRenderObject() as RenderBox?;
    if (fabBox == null || !fabBox.hasSize) {
      return const SizedBox.shrink();
    }
    final screen = MediaQuery.of(context).size;
    final fabTopLeft = fabBox.localToGlobal(Offset.zero);
    final maxHeight = screen.height * 0.6;

    return Stack(
      children: [
        // Tap-outside-to-close scrim. Transparent but catches taps so the menu
        // dismisses without leaking the gesture to the map underneath.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _closeMenu,
          ),
        ),
        Positioned(
          left: fabTopLeft.dx,
          bottom: screen.height - fabTopLeft.dy + AppSpacing.sm,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < widget.actions.length; index++)
                    _buildActionItem(context, widget.actions[index], index),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    ExpandableMapActionMenuItem item,
    int index,
  ) {
    final scheme = context.colorScheme;
    final theme = Theme.of(context);
    final start =
        (index * _staggerStep.inMilliseconds) / _menuDuration.inMilliseconds;
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start.clamp(0.0, 1.0), 1.0, curve: Curves.easeOutCubic),
      reverseCurve: Curves.easeInCubic,
    );

    final foreground = item.active
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;
    final background = item.active
        ? scheme.primaryContainer
        : scheme.surfaceContainerHigh;

    return Padding(
      padding: EdgeInsets.only(
        bottom: index == widget.actions.length - 1 ? AppSpacing.sm : 8,
      ),
      child: SizeTransition(
        sizeFactor: animation,
        alignment: Alignment.bottomCenter,
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, _slideDistance),
              end: Offset.zero,
            ).animate(animation),
            // No Tooltip here: the label is already shown as visible text, and
            // a Tooltip (itself an OverlayPortal) cannot compute its paint
            // transform while nested inside this CompositedTransformFollower.
            child: Semantics(
              button: true,
              label: item.label,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _handleActionTap(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, size: 20, color: foreground),
                          const SizedBox(width: 12),
                          Text(
                            item.label,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton(BuildContext context) {
    final scheme = context.colorScheme;

    return Semantics(
      button: true,
      label: widget.tooltip,
      child: Tooltip(
        message: widget.tooltip,
        child: FloatingActionButton(
          heroTag: 'map-actions-fab',
          elevation: 3,
          onPressed: _toggleMenu,
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: _menuDuration,
            curve: Curves.easeOutCubic,
            child: Icon(_isOpen ? Icons.close_rounded : Icons.menu_rounded),
          ),
        ),
      ),
    );
  }
}

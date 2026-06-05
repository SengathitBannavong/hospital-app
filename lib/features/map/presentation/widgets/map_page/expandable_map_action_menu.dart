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

  late final AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _menuDuration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
    });
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _closeMenu() {
    if (!_isOpen) {
      return;
    }
    setState(() {
      _isOpen = false;
    });
    _controller.reverse();
  }

  void _handleActionTap(ExpandableMapActionMenuItem item) {
    _closeMenu();
    item.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      for (var index = 0; index < widget.actions.length; index++)
        _buildActionItem(context, widget.actions[index], index),
      _buildMainButton(context),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
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

    return IgnorePointer(
      ignoring: !_isOpen,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: index == widget.actions.length - 1 ? AppSpacing.sm : 8,
        ),
        child: SizeTransition(
          sizeFactor: animation,
          axisAlignment: 1,
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, _slideDistance),
                end: Offset.zero,
              ).animate(animation),
              child: Tooltip(
                message: item.label,
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

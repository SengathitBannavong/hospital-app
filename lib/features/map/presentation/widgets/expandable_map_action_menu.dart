import 'package:flutter/material.dart';

/// A lightweight model representing a single map action in the speed-dial.
class MapActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool active;

  const MapActionItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
  });
}

/// ExpandableMapActionMenu
///
/// A reusable, accessible, and animated speed-dial that reveals a vertical
/// list of labeled actions above a single main FAB. Uses an
/// [AnimationController] for staggered child animations and an
/// [AnimatedRotation] for the main FAB rotation.
class ExpandableMapActionMenu extends StatefulWidget {
  final List<MapActionItem> actions;
  final String tooltip;
  final Duration duration;

  const ExpandableMapActionMenu({
    super.key,
    required this.actions,
    this.tooltip = 'Map Actions',
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<ExpandableMapActionMenu> createState() =>
      _ExpandableMapActionMenuState();
}

class _ExpandableMapActionMenuState extends State<ExpandableMapActionMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _open = false;

  static const int _staggerMs = 40; // per-item stagger gap

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_open) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _open = !_open);
  }

  // Build animated child with staggered interval using the index.
  Widget _buildAction(BuildContext context, int index, MapActionItem item) {
    final totalMs = widget.duration.inMilliseconds;
    final start = (index * _staggerMs) / totalMs;
    final end = (start + 0.6).clamp(0.0, 1.0);
    final curve = Interval(start, end, curve: Curves.easeOutCubic);

    final anim = CurvedAnimation(parent: _controller, curve: curve);

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(anim),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                // Close first for immediate visual feedback then run action.
                _toggle();
                // Ensure tap handler runs after close animation starts.
                Future.delayed(
                  const Duration(milliseconds: 50),
                  item.onPressed,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Column where children appear above the main FAB. Keep minimal size.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Build actions in order so first action appears nearest to FAB.
        for (var i = widget.actions.length - 1; i >= 0; i--)
          // Only render the child when the controller is at least near
          // the child's interval for performance. We still build the widget
          // because transitions are cheap; this keeps code simple.
          _buildAction(context, i, widget.actions[i]),

        // Spacing between top actions and main FAB
        const SizedBox(height: 8),

        // Main FAB with animated rotation and tooltip.
        AnimatedRotation(
          // Rotate 45 degrees (1/8 of a turn) when open.
          turns: _open ? 0.125 : 0.0,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: FloatingActionButton(
            onPressed: _toggle,
            tooltip: widget.tooltip,
            elevation: 6,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Icon(_open ? Icons.close_rounded : Icons.menu_rounded),
          ),
        ),
      ],
    );
  }
}

part of '../../pages/map_page.dart';

class _MapFab extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool active;

  const _MapFab({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: active ? scheme.primaryContainer : scheme.surface,
        elevation: 2,
        shadowColor: scheme.shadow,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              icon,
              size: 22,
              color: active ? scheme.primary : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

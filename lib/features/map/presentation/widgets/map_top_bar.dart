import 'package:flutter/material.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/presentation/theme/map_tokens.dart';

class MapTopBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback? onCollapse;

  const MapTopBar({
    super.key,
    required this.controller,
    this.isLoading = false,
    this.onCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: 'Map search',
      child: Material(
        color: scheme.surface,
        elevation: 1,
        shadowColor: scheme.shadow,
        borderRadius: AppRadius.borderXl,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  _TopBarIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  if (onCollapse != null)
                    _TopBarIconButton(
                      icon: Icons.keyboard_arrow_up_rounded,
                      tooltip: 'Hide search',
                      onPressed: onCollapse!,
                    ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: 'Search rooms, services, places',
                        prefixIcon: Icon(Icons.search_rounded),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isCollapsed: false,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (controller.text.isNotEmpty)
                    _TopBarIconButton(
                      icon: Icons.close_rounded,
                      tooltip: 'Clear search',
                      onPressed: controller.clear,
                    ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: MapMotion.short,
              child: isLoading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      height: 2,
                      child: LinearProgressIndicator(minHeight: 2),
                    )
                  : const SizedBox(key: ValueKey('idle'), height: 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _TopBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        tooltip: tooltip,
        iconSize: 22,
        splashRadius: 22,
      ),
    );
  }
}

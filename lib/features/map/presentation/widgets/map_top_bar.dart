import 'package:flutter/material.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
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
      label: context.l10n.mapSearchSemantic,
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
                  if (onCollapse != null)
                    _TopBarIconButton(
                      icon: Icons.keyboard_arrow_up_rounded,
                      tooltip: context.l10n.mapHideSearch,
                      onPressed: onCollapse!,
                    ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        hintText: context.l10n.mapSearchHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isCollapsed: false,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return _TopBarIconButton(
                        icon: Icons.close_rounded,
                        tooltip: context.l10n.mapClearSearch,
                        onPressed: controller.clear,
                      );
                    },
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

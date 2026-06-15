import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'map_route_status.dart';

class MapRoutePanel extends StatelessWidget {
  final int? userPosition;
  final String? userPositionName;
  final MapPoi? dest;
  final String mode;
  final AsyncValue<RouteResult?> routeResult;
  final List<int> routeLocations;
  final VoidCallback onRetry;
  final VoidCallback onClear;
  final ValueChanged<String> onModeChanged;
  final VoidCallback onPickDestination;
  final VoidCallback? onStartNavigation;

  const MapRoutePanel({
    super.key,
    required this.userPosition,
    required this.userPositionName,
    required this.dest,
    required this.mode,
    required this.routeResult,
    required this.routeLocations,
    required this.onRetry,
    required this.onClear,
    required this.onModeChanged,
    required this.onPickDestination,
    required this.onStartNavigation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.mapRoutePanelTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: dest == null ? null : onClear,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(context.l10n.commonClear),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _RouteStartChip(
            icon: Icons.my_location_rounded,
            label: context.l10n.routeFrom,
            value: userPositionName ?? context.l10n.mapYouAreHere,
            isSet: userPosition != null,
            accent: scheme.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          _RouteEndpointRow(
            icon: Icons.flag_rounded,
            label: context.l10n.routeDestination,
            value: dest?.poiName ?? context.l10n.mapPickAPlace,
            isSet: dest != null,
            onPick: onPickDestination,
            accent: scheme.secondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                context.l10n.routeModeLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              DropdownButton<String>(
                value: mode,
                underline: const SizedBox.shrink(),
                onChanged: (value) {
                  if (value != null) onModeChanged(value);
                },
                items: [
                  DropdownMenuItem(
                    value: 'walking',
                    child: Text(context.l10n.routeModeWalking),
                  ),
                  DropdownMenuItem(
                    value: 'wheelchair',
                    child: Text(context.l10n.routeModeWheelchair),
                  ),
                  DropdownMenuItem(
                    value: 'stretcher',
                    child: Text(context.l10n.routeModeStretcher),
                  ),
                  DropdownMenuItem(
                    value: 'hospital_cart',
                    child: Text(context.l10n.routeModeCart),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          MapRouteStatus(
            routeResult: routeResult,
            routeLocations: routeLocations,
            hasStart: userPosition != null,
            hasDestination: dest != null,
            onRetry: onRetry,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStartNavigation,
              icon: const Icon(Icons.navigation_rounded),
              label: Text(context.l10n.routeStartNavigation),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteStartChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSet;
  final Color accent;

  const _RouteStartChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSet,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  isSet ? value : context.l10n.routeLocatingEntrance,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isSet ? scheme.onSurface : scheme.onSurfaceVariant,
                    fontWeight: isSet ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteEndpointRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSet;
  final VoidCallback onPick;
  final Color accent;

  const _RouteEndpointRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSet,
    required this.onPick,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Semantics(
      button: true,
      label: context.l10n.routeSelectorSemantic(label, value),
      child: InkWell(
        onTap: onPick,
        borderRadius: AppRadius.borderMd,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: AppRadius.borderMd,
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 16, color: accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isSet
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                        fontWeight: isSet ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

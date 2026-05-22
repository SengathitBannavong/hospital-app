import 'package:flutter/material.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';

class MapAsyncMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  const MapAsyncMessage({
    super.key,
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final iconWidget = Icon(icon, color: scheme.onSurfaceVariant);
    final titleWidget = Text(
      title,
      style: context.textTheme.bodyMedium,
      maxLines: compact ? 2 : null,
      overflow: compact ? TextOverflow.ellipsis : null,
    );
    final action = actionLabel != null && onAction != null
        ? TextButton(onPressed: onAction, child: Text(actionLabel!))
        : null;

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: titleWidget),
          ?action,
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(height: AppSpacing.sm),
          titleWidget,
          if (action != null) ...[
            const SizedBox(height: AppSpacing.sm),
            action,
          ],
        ],
      ),
    );
  }
}

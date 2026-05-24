import 'package:flutter/material.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../data/models/app_notification.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: notification.isRead
              ? context.colorScheme.surfaceContainerHighest
              : context.colorScheme.primaryContainer,
          child: Icon(
            notification.isRead
                ? Icons.notifications_none_rounded
                : Icons.notifications_active_rounded,
            color: context.colorScheme.primary,
          ),
        ),
        title: Text(
          notification.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (notification.createdAt.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                notification.createdAt,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

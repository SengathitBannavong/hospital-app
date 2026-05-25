// lib/features/notification/presentation/widgets/notification_badge.dart
//
// Usage example in your bottom navigation bar:
//
//   NavigationDestination(
//     icon: NotificationBadge(child: Icon(Icons.notifications_outlined)),
//     selectedIcon: NotificationBadge(
//       child: Icon(Icons.notifications_rounded),
//     ),
//     label: 'Thông báo',
//   )

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';

class NotificationBadge extends ConsumerWidget {
  final Widget child;
  final double? top;
  final double? right;

  const NotificationBadge({
    super.key,
    required this.child,
    this.top,
    this.right,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadCountProvider);
    final cs = Theme.of(context).colorScheme;

    if (count == 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: top ?? -4,
          right: right ?? -4,
          child: Container(
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: cs.error,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.surface, width: 1.5),
            ),
            child: Text(
              count > 99 ? '99+' : '$count',
              style: TextStyle(
                color: cs.onError,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

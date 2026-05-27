import 'package:flutter/material.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import '../../data/models/chat_room.dart';
import 'chat_avatar.dart';
import 'chat_time_label.dart';

class ChatRoomCard extends StatelessWidget {
  const ChatRoomCard({required this.room, required this.onTap, super.key});

  final ChatRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasUnread = room.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            ChatAvatar(name: room.name, avatarUrl: room.avatarUrl),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.name.isEmpty ? 'Phòng chat' : room.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: hasUnread
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ChatTimeLabel(isoString: room.lastMessageAt),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.lastMessage.isEmpty
                              ? 'Chưa có tin nhắn'
                              : room.lastMessage,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: hasUnread
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                                fontWeight: hasUnread
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _UnreadBadge(count: room.unreadCount),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          color: cs.onPrimary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

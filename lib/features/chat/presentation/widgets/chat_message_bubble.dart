import 'package:flutter/material.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/network/media_url.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import '../../data/models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    required this.message,
    required this.isMe,
    this.showSenderName = true,
    super.key,
  });

  final ChatMessage message;
  final bool isMe;
  final bool showSenderName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final senderLabel = _senderLabel;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe && showSenderName && senderLabel.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: 2),
                child: Text(
                  senderLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: message.type == 'image' ? 4 : AppSpacing.md,
                vertical: message.type == 'image' ? 4 : AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isMe ? cs.primary : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.lg),
                  topRight: const Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(isMe ? AppRadius.lg : 4),
                  bottomRight: Radius.circular(isMe ? 4 : AppRadius.lg),
                ),
                boxShadow: AppShadows.card,
              ),
              child: _buildContent(context),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 6),
                    Text(
                      message.isRead
                          ? context.l10n.chatMsgRead
                          : context.l10n.chatMsgSent,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _senderLabel {
    final label = message.senderName.trim();
    if (label.isNotEmpty) return label;
    return _fallbackSideLabel;
  }

  String get _fallbackSideLabel => switch (message.senderType) {
    'user' => appL10n.senderPatient,
    'admin' => appL10n.senderAdmin,
    'coordinator' => appL10n.senderCoordinator,
    _ => appL10n.senderStaff,
  };

  Widget _buildContent(BuildContext context) {
    return switch (message.type) {
      'image' => _buildImageContent(context),
      'voice' => _buildVoiceContent(context),
      _ => _buildTextContent(context),
    };
  }

  Widget _buildTextContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      message.content,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: isMe ? cs.onPrimary : cs.onSurface,
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final resolvedUrl = resolveMediaUrl(message.mediaUrl);
    if (resolvedUrl == null) {
      return Text(
        context.l10n.chatImageLoadError,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isMe ? cs.onPrimary : cs.onSurface,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.network(
        resolvedUrl,
        fit: BoxFit.cover,
        width: 220,
        height: 180,
        errorBuilder: (context, error, stackTrace) => Text(
          context.l10n.chatImageLoadError,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isMe ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.graphic_eq_rounded,
          color: isMe ? cs.onPrimary : cs.onSurface,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          context.l10n.chatVoiceMessage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isMe ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${_pad(dt.hour)}:${_pad(dt.minute)}';
    } catch (_) {
      return raw;
    }
  }

  String _pad(int v) => v.toString().padLeft(2, '0');
}

import 'package:flutter/material.dart';

class ChatTimeLabel extends StatelessWidget {
  const ChatTimeLabel({required this.isoString, super.key});
  final String isoString;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      _format(isoString),
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
    );
  }

  String _format(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final msgDay = DateTime(dt.year, dt.month, dt.day);

      if (msgDay == today) {
        return '${_pad(dt.hour)}:${_pad(dt.minute)}';
      }
      final yesterday = today.subtract(const Duration(days: 1));
      if (msgDay == yesterday) return 'Hôm qua';

      return '${_pad(dt.day)}/${_pad(dt.month)}';
    } catch (_) {
      return raw;
    }
  }

  String _pad(int v) => v.toString().padLeft(2, '0');
}

part of '../../pages/map_page.dart';

class _AnalyticsRow extends StatelessWidget {
  final String title;
  final bool active;
  final ValueChanged<bool> onChanged;

  const _AnalyticsRow({
    required this.title,
    required this.active,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          // Expanded lets longer labels (e.g. Vietnamese) wrap instead of
          // overflowing the fixed-width analytics panel.
          Expanded(
            child: Text(title, style: context.textTheme.bodyMedium),
          ),
          const SizedBox(width: AppSpacing.sm),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: active,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

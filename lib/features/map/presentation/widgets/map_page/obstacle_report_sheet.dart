part of '../../pages/map_page.dart';

class _ObstacleReportSheet extends StatefulWidget {
  final int location;

  const _ObstacleReportSheet({required this.location});

  @override
  State<_ObstacleReportSheet> createState() => _ObstacleReportSheetState();
}

class _ObstacleReportSheetState extends State<_ObstacleReportSheet> {
  static const _types = ['blockage', 'spill', 'crowd', 'maintenance'];

  late final TextEditingController _noteController;
  String _type = _types.first;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg + bottomInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.obstacleReportTitle,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.l10n.obstacleCell(widget.location),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: context.l10n.obstacleFieldType,
              ),
              items: [
                DropdownMenuItem(
                  value: 'blockage',
                  child: Text(context.l10n.obstacleOptionBlockage),
                ),
                DropdownMenuItem(
                  value: 'spill',
                  child: Text(context.l10n.obstacleOptionSpill),
                ),
                DropdownMenuItem(
                  value: 'crowd',
                  child: Text(context.l10n.obstacleOptionCrowd),
                ),
                DropdownMenuItem(
                  value: 'maintenance',
                  child: Text(context.l10n.obstacleOptionMaintenance),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _type = value);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.l10n.obstacleFieldNote,
                hintText: context.l10n.commonOptional,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final note = _noteController.text.trim();
                  Navigator.of(context).pop(
                    _ObstacleReportDraft(
                      type: _type,
                      note: note.isEmpty ? null : note,
                    ),
                  );
                },
                icon: const Icon(Icons.report_problem_rounded),
                label: Text(context.l10n.obstacleSubmit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
              'Report obstacle',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Cell ${widget.location}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: 'blockage', child: Text('Blockage')),
                DropdownMenuItem(value: 'spill', child: Text('Spill')),
                DropdownMenuItem(value: 'crowd', child: Text('Crowd')),
                DropdownMenuItem(
                  value: 'maintenance',
                  child: Text('Maintenance'),
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
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'Optional',
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
                label: const Text('Submit report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

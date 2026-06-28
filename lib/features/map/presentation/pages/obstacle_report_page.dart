import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/map/data/models/map_obstacle.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

class ObstacleReportPage extends ConsumerStatefulWidget {
  const ObstacleReportPage({super.key, required this.gridLocation});

  /// Grid location captured from the user's current position on the map.
  /// The user only reads this value here — it is never typed in.
  final int? gridLocation;

  @override
  ConsumerState<ObstacleReportPage> createState() => _ObstacleReportPageState();
}

class _ObstacleReportPageState extends ConsumerState<ObstacleReportPage> {
  final _noteController = TextEditingController();
  String _obstacleType = 'obstacle';
  bool _isSubmitting = false;
  bool _submitted = false;
  bool _sentOnline = true;

  static const _typeKeys = [
    'obstacle',
    'wet_floor',
    'construction',
    'crowd',
    'other',
  ];

  String _typeLabel(BuildContext context, String key) {
    final l10n = context.l10n;
    return switch (key) {
      'obstacle' => l10n.obstacleTypeObstacle,
      'wet_floor' => l10n.obstacleTypeWetFloor,
      'construction' => l10n.obstacleTypeConstruction,
      'crowd' => l10n.obstacleTypeCrowd,
      _ => l10n.genderOther,
    };
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final gridLocation = widget.gridLocation;
    if (gridLocation == null) {
      AppToast.showError(context.l10n.obErrorNoLocation);
      return;
    }

    final note = _noteController.text.trim();
    final obstacle = MapObstacle(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      gridLocation: gridLocation,
      type: _obstacleType,
      note: note.isEmpty ? null : note,
      reportedAt: DateTime.now(),
    );

    setState(() => _isSubmitting = true);
    try {
      // Goes through the offline queue: posts immediately when online,
      // otherwise persists locally and syncs on the next obstacle load.
      final sentOnline = await ref
          .read(reportQueueProvider)
          .submitObstacle(obstacle);
      // Invalidate cached obstacle providers so the map merges this report
      // (from the server when online, or from the local queue when offline).
      final selectedMapId = ref.read(selectedFloorProvider);
      if (selectedMapId != null) {
        ref.invalidate(mapObstaclesProvider(selectedMapId));
      }
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitted = true;
          _sentOnline = sentOnline;
        });
        AppToast.showSuccess(
          sentOnline ? context.l10n.obSuccess : context.l10n.obSavedOffline,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppToast.showError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(context.l10n.mlObstacleTitle),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pageWithTop,
        child: _submitted
            ? _SuccessState(
                subtitle: _sentOnline
                    ? context.l10n.obSuccessSubtitle
                    : context.l10n.obSavedOfflineSubtitle,
                onBack: () =>
                    context.canPop() ? context.pop() : context.go('/'),
              )
            : Card(
                child: Padding(
                  padding: AppSpacing.cardPaddingLarge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.l10n.obTypeLabel,
                        style: context.textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: _typeKeys
                            .map(
                              (key) => ChoiceChip(
                                label: Text(_typeLabel(context, key)),
                                selected: _obstacleType == key,
                                onSelected: _isSubmitting
                                    ? null
                                    : (_) =>
                                          setState(() => _obstacleType = key),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        context.l10n.obLocationLabel,
                        style: context.textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.pin_drop_outlined,
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                widget.gridLocation == null
                                    ? context.l10n.obErrorNoLocation
                                    : context.l10n.obstacleCell(
                                        widget.gridLocation!,
                                      ),
                                style: context.textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _noteController,
                        enabled: !_isSubmitting,
                        minLines: 3,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: context.l10n.obNoteLabel,
                          hintText: context.l10n.obNoteHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton.icon(
                        onPressed: _isSubmitting ? null : _submit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.report_rounded),
                        label: Text(context.l10n.baSubmit),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => context.canPop()
                                  ? context.pop()
                                  : context.go('/'),
                        child: Text(context.l10n.commonBack),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.subtitle, required this.onBack});

  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.cardPaddingLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.obSuccessTitle,
              style: context.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: onBack,
              child: Text(context.l10n.commonBack),
            ),
          ],
        ),
      ),
    );
  }
}

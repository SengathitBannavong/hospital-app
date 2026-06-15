import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

class ObstacleReportPage extends ConsumerStatefulWidget {
  const ObstacleReportPage({super.key});

  @override
  ConsumerState<ObstacleReportPage> createState() => _ObstacleReportPageState();
}

class _ObstacleReportPageState extends ConsumerState<ObstacleReportPage> {
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  String _obstacleType = 'obstacle';
  bool _isSubmitting = false;
  bool _submitted = false;

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
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final locationText = _locationController.text.trim();
    if (locationText.isEmpty) {
      AppToast.showError(context.l10n.obErrorNoLocation);
      return;
    }
    final gridLocation = int.tryParse(locationText);
    if (gridLocation == null) {
      AppToast.showError(context.l10n.obErrorNotInteger);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(mapRepositoryProvider)
          .reportObstacle(
            gridLocation: gridLocation,
            type: _obstacleType,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
      // Invalidate all cached obstacle providers so the map refreshes.
      final selectedMapId = ref.read(selectedFloorProvider);
      if (selectedMapId != null) {
        ref.invalidate(mapObstaclesProvider(selectedMapId));
      }
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitted = true;
        });
        AppToast.showSuccess(context.l10n.obSuccess);
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
                      TextField(
                        controller: _locationController,
                        enabled: !_isSubmitting,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.l10n.obLocationLabel,
                          hintText: context.l10n.obLocationHint,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.pin_drop_outlined),
                          helperText: context.l10n.obLocationHelper,
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
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.onBack});

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
              context.l10n.obSuccessSubtitle,
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

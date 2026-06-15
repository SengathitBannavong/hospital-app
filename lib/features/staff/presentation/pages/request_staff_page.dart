import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/presentation/widgets/poi_picker.dart';
import 'package:hospital_app/features/staff/presentation/providers/staff_providers.dart';

class RequestStaffPage extends ConsumerStatefulWidget {
  const RequestStaffPage({super.key, this.initialPoi});

  /// Pre-selected location, e.g. when opened from a POI on the map.
  final MapPoi? initialPoi;

  @override
  ConsumerState<RequestStaffPage> createState() => _RequestStaffPageState();
}

class _RequestStaffPageState extends ConsumerState<RequestStaffPage> {
  final _assetController = TextEditingController();
  final _noteController = TextEditingController();
  MapPoi? _poi;
  int _assistanceTypeIndex = 0;
  bool _isSubmitting = false;
  bool _submitted = false;

  List<String> _typeList(BuildContext context) {
    final l10n = context.l10n;
    return [
      l10n.staffTypeMove,
      l10n.staffTypeWheelchair,
      l10n.staffTypeMedical,
      l10n.staffTypeOther,
    ];
  }

  @override
  void initState() {
    super.initState();
    _poi = widget.initialPoi;
  }

  @override
  void dispose() {
    _assetController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickPoi() async {
    final poi = await showPoiPicker(
      context,
      title: context.l10n.staffPickLocationTitle,
    );
    if (poi != null) setState(() => _poi = poi);
  }

  Future<void> _submit() async {
    final nodeId = _poi?.poiCode ?? '';
    if (nodeId.isEmpty) {
      AppToast.showError(context.l10n.staffErrorSelectLocation);
      return;
    }

    final assistanceType = _typeList(context)[_assistanceTypeIndex];
    final extraNote = _noteController.text.trim();
    final note = extraNote.isEmpty
        ? '[$assistanceType]'
        : '[$assistanceType] $extraNote';

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(staffRepositoryProvider)
          .requestStaff(
            nodeId: nodeId,
            assetId: _assetController.text.trim(),
            note: note,
          );
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitted = true;
        });
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
        title: Text(context.l10n.staffTitle),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pageWithTop,
        child: _submitted
            ? _SuccessView()
            : _FormView(
                selectedPoi: _poi,
                onPickLocation: _pickPoi,
                assetController: _assetController,
                noteController: _noteController,
                assistanceType: _typeList(context)[_assistanceTypeIndex],
                onTypeChanged: (v) => setState(
                  () => _assistanceTypeIndex = _typeList(context).indexOf(v),
                ),
                onSubmit: _isSubmitting ? null : _submit,
                isSubmitting: _isSubmitting,
                types: _typeList(context),
              ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.selectedPoi,
    required this.onPickLocation,
    required this.assetController,
    required this.noteController,
    required this.assistanceType,
    required this.onTypeChanged,
    required this.onSubmit,
    required this.isSubmitting,
    required this.types,
  });

  final MapPoi? selectedPoi;
  final VoidCallback onPickLocation;
  final TextEditingController assetController;
  final TextEditingController noteController;
  final String assistanceType;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback? onSubmit;
  final bool isSubmitting;
  final List<String> types;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPaddingLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.staffTypeLabel,
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: types
                  .map(
                    (t) => ChoiceChip(
                      label: Text(t),
                      selected: assistanceType == t,
                      onSelected: (_) => onTypeChanged(t),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            PoiPickerField(
              label: context.l10n.staffCurrentLocationLabel,
              hint: context.l10n.staffCurrentLocationHint,
              selected: selectedPoi,
              onTap: isSubmitting ? () {} : onPickLocation,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: assetController,
              enabled: !isSubmitting,
              decoration: InputDecoration(
                labelText: context.l10n.staffAssetCodeLabel,
                hintText: context.l10n.staffAssetCodeHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.accessible_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: noteController,
              enabled: !isSubmitting,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: context.l10n.staffNoteLabel,
                hintText: context.l10n.staffNoteHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onSubmit,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.support_agent_rounded),
              label: Text(context.l10n.staffSubmit),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
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
              context.l10n.staffSuccessTitle,
              style: context.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.staffSuccessSubtitle,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/'),
              child: Text(context.l10n.commonBack),
            ),
          ],
        ),
      ),
    );
  }
}

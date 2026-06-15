import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/device/presentation/providers/asset_providers.dart';

class BrokenAssetReportPage extends ConsumerStatefulWidget {
  const BrokenAssetReportPage({super.key, required this.assetId});

  final String assetId;

  @override
  ConsumerState<BrokenAssetReportPage> createState() =>
      _BrokenAssetReportPageState();
}

class _BrokenAssetReportPageState extends ConsumerState<BrokenAssetReportPage> {
  final _assetIdController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _assetIdController.text = widget.assetId;
  }

  @override
  void dispose() {
    _assetIdController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final assetId = _assetIdController.text.trim();
    final reason = _reasonController.text.trim();
    if (assetId.isEmpty) {
      AppToast.showError(context.l10n.baErrorNoAssetId);
      return;
    }
    if (reason.isEmpty) {
      AppToast.showError(context.l10n.baErrorNoReason);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(assetRepositoryProvider)
          .reportBrokenAsset(assetId: assetId, reason: reason);
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitted = true;
        });
        AppToast.showSuccess(context.l10n.baSuccess);
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
        title: Text(context.l10n.baTitle),
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
                        context.l10n.baCardTitle,
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        controller: _assetIdController,
                        enabled: !_isSubmitting,
                        decoration: InputDecoration(
                          labelText: context.l10n.baAssetCodeLabel,
                          hintText: context.l10n.staffAssetCodeHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _reasonController,
                        enabled: !_isSubmitting,
                        minLines: 4,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: context.l10n.baReasonLabel,
                          hintText: context.l10n.baReasonHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(context.l10n.baSubmit),
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
            context.l10n.baSuccessTitle,
            style: context.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.baSuccessSubtitle,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(onPressed: onBack, child: Text(context.l10n.commonBack)),
        ],
      ),
    );
  }
}

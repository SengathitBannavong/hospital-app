import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class _BrokenAssetReportPageState
    extends ConsumerState<BrokenAssetReportPage> {
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
      AppToast.showError('Vui lòng nhập mã thiết bị.');
      return;
    }
    if (reason.isEmpty) {
      AppToast.showError('Vui lòng nhập mô tả tình trạng hỏng.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(assetRepositoryProvider).reportBrokenAsset(
        assetId: assetId,
        reason: reason,
      );
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitted = true;
        });
        AppToast.showSuccess('Đã báo cáo hỏng thiết bị thành công!');
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
        title: const Text('Báo hỏng thiết bị'),
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
                        'Báo cáo thiết bị hỏng',
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        controller: _assetIdController,
                        enabled: !_isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Mã thiết bị *',
                          hintText: 'vd: WL-001',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _reasonController,
                        enabled: !_isSubmitting,
                        minLines: 4,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả tình trạng hỏng *',
                          hintText: 'Mô tả chi tiết vấn đề...',
                          border: OutlineInputBorder(),
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
                            : const Text('Gửi báo cáo'),
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
          Icon(
            Icons.check_circle_outline_rounded,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Đã báo cáo thành công!',
            style: context.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Đội ngũ kỹ thuật sẽ xử lý sự cố sớm nhất có thể.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(onPressed: onBack, child: const Text('Quay lại')),
        ],
      ),
    );
  }
}

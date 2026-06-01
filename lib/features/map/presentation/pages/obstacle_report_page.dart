import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  static const _types = [
    ('obstacle', 'Vật cản'),
    ('wet_floor', 'Sàn ướt'),
    ('construction', 'Đang thi công'),
    ('crowd', 'Đông người'),
    ('other', 'Khác'),
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final locationText = _locationController.text.trim();
    if (locationText.isEmpty) {
      AppToast.showError('Vui lòng nhập mã vị trí (grid location).');
      return;
    }
    final gridLocation = int.tryParse(locationText);
    if (gridLocation == null) {
      AppToast.showError('Mã vị trí phải là số nguyên.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(mapRepositoryProvider).reportObstacle(
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
        AppToast.showSuccess('Đã báo cáo vật cản thành công!');
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
        title: const Text('Báo cáo vật cản'),
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
                        'Loại vật cản',
                        style: context.textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: _types
                            .map(
                              (t) => ChoiceChip(
                                label: Text(t.$2),
                                selected: _obstacleType == t.$1,
                                onSelected: _isSubmitting
                                    ? null
                                    : (_) =>
                                        setState(() => _obstacleType = t.$1),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        controller: _locationController,
                        enabled: !_isSubmitting,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Mã vị trí *',
                          hintText: 'Nhập số grid location (vd: 342)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.pin_drop_outlined),
                          helperText:
                              'Tìm mã vị trí trên bản đồ hoặc hỏi nhân viên',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _noteController,
                        enabled: !_isSubmitting,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả thêm',
                          hintText: 'Mô tả tình trạng vật cản...',
                          border: OutlineInputBorder(),
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
                        label: const Text('Gửi báo cáo'),
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
              'Đã gửi báo cáo!',
              style: context.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Cảm ơn bạn đã thông báo vật cản. Đội ngũ sẽ xử lý sớm nhất.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: onBack,
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}

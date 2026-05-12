import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../providers/medical_providers.dart';
import '../widgets/prescription_item_tile.dart';

class PrescriptionPage extends ConsumerWidget {
  const PrescriptionPage({super.key});

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(medicalPrescriptionProvider);
    await ref.read(medicalPrescriptionProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionAsync = ref.watch(medicalPrescriptionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Đơn thuốc')),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: AppSpacing.pagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: AppSpacing.md),
            prescriptionAsync.when(
              data: (prescription) {
                if (prescription == null) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                    child: Center(child: Text('Chưa có đơn thuốc')),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: AppSpacing.cardPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prescription.pharmacyName ?? 'Nhà thuốc',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text('Trạng thái: ${prescription.status}'),
                            Text('Ngày kê: ${prescription.issuedAt}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Danh sách thuốc',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final item in prescription.items) ...[
                      PrescriptionItemTile(item: item),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: Center(child: Text(_cleanError(error))),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

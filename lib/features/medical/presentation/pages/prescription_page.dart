import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/locale_controller.dart';
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
      appBar: AppBar(title: Text(context.l10n.homeActionPrescription)),
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxl,
                    ),
                    child: Center(child: Text(context.l10n.presEmpty)),
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
                              prescription.pharmacyName ??
                                  context.l10n.presPharmacy,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(context.l10n.presStatus(prescription.status)),
                            Text(
                              context.l10n.presIssuedAt(prescription.issuedAt),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      context.l10n.presMedList,
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

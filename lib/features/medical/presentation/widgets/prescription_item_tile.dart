import 'package:flutter/material.dart';
import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../data/models/prescription.dart';

class PrescriptionItemTile extends StatelessWidget {
  const PrescriptionItemTile({super.key, required this.item});

  final PrescriptionItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(context.l10n.presDosage(item.dosage)),
            Text(context.l10n.presQuantity(item.quantity)),
            if (item.instructions != null && item.instructions!.isNotEmpty)
              Text(context.l10n.presInstructions(item.instructions!)),
          ],
        ),
      ),
    );
  }
}

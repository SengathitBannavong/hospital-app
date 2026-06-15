import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../data/models/medical_task.dart';
import '../providers/medical_providers.dart';
import '../widgets/task_card.dart';

/// Detail page for a single medical task. Holds the check-in / check-out /
/// result / cancel actions that used to live inline on the list card.
class TaskDetailPage extends ConsumerWidget {
  const TaskDetailPage({super.key, required this.task});

  final MedicalTask task;

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Runs an action, refreshes the lists, and pops back so the user sees the
  /// updated task list.
  Future<void> _runAction(
    BuildContext context,
    WidgetRef ref,
    Future<bool> Function() action,
    String successMessage,
  ) async {
    try {
      await action();
      ref
        ..invalidate(medicalTasksProvider)
        ..invalidate(medicalHistoryProvider);
      if (!context.mounted) return;
      _showSnackBar(context, successMessage);
      if (context.canPop()) context.pop();
    } catch (error) {
      if (!context.mounted) return;
      _showSnackBar(context, _cleanError(error), isError: true);
    }
  }

  Future<void> _showResultStatus(BuildContext context, WidgetRef ref) async {
    try {
      final result = await ref
          .read(medicalRepositoryProvider)
          .getResultStatus(treatmentId: task.treatmentId);

      if (!context.mounted) return;

      if (result == null) {
        _showSnackBar(context, context.l10n.tdNoResultData);
        return;
      }

      final l10n = context.l10n;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.tdResultTitle),
          content: Text(
            l10n.tdResultBody(
              result.treatmentId,
              result.status,
              result.hasResult ? l10n.tdResultHas : l10n.tdResultNotYet,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.commonClose),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      _showSnackBar(context, _cleanError(error), isError: true);
    }
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.tdCancelTitle),
        content: Text(context.l10n.tdCancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonNo),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.commonYes),
          ),
        ],
      ),
    );

    if (!context.mounted || confirmed != true) return;

    await _runAction(
      context,
      ref,
      () => ref
          .read(medicalRepositoryProvider)
          .cancelTask(treatmentId: task.treatmentId),
      context.l10n.tdCancelled,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCancelled = task.status == 'cancelled';
    final isCompleted = task.status == 'completed';
    final canAct = !isCancelled && !isCompleted;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.tdDetailTitle)),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          const SizedBox(height: AppSpacing.md),
          // Informational card (no inline callbacks -> no buttons here).
          TaskCard(task: task),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.tdActions,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          if (canAct)
            FilledButton.icon(
              onPressed: () => _runAction(
                context,
                ref,
                () => ref
                    .read(medicalRepositoryProvider)
                    .checkinRoom(treatmentId: task.treatmentId),
                context.l10n.tdCheckinSuccess,
              ),
              icon: const Icon(Icons.login_rounded),
              label: Text(context.l10n.tdCheckin),
            ),
          if (canAct) const SizedBox(height: AppSpacing.sm),
          if (canAct)
            FilledButton.tonalIcon(
              onPressed: () => _runAction(
                context,
                ref,
                () => ref
                    .read(medicalRepositoryProvider)
                    .checkoutRoom(treatmentId: task.treatmentId),
                context.l10n.tdCheckoutSuccess,
              ),
              icon: const Icon(Icons.logout_rounded),
              label: Text(context.l10n.tdCheckout),
            ),
          if (canAct) const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => _showResultStatus(context, ref),
            icon: const Icon(Icons.assignment_turned_in_outlined),
            label: Text(context.l10n.tdResultTitle),
          ),
          if (canAct) const SizedBox(height: AppSpacing.sm),
          if (canAct)
            TextButton.icon(
              onPressed: () => _confirmCancel(context, ref),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: Text(context.l10n.tdCancelTitle),
            ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

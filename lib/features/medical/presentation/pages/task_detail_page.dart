import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
        _showSnackBar(context, 'Không có dữ liệu kết quả');
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kết quả'),
          content: Text(
            'Treatment: ${result.treatmentId}\n'
            'Trạng thái: ${result.status}\n'
            'Có kết quả: ${result.hasResult ? 'Có' : 'Chưa'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
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
        title: const Text('Hủy chỉ định'),
        content: const Text('Bạn có chắc chắn muốn hủy không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Có'),
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
      'Đã hủy chỉ định',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCancelled = task.status == 'cancelled';
    final isCompleted = task.status == 'completed';
    final canAct = !isCancelled && !isCompleted;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết chỉ định')),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          const SizedBox(height: AppSpacing.md),
          // Informational card (no inline callbacks -> no buttons here).
          TaskCard(task: task),
          const SizedBox(height: AppSpacing.lg),
          Text('Thao tác', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          if (canAct)
            FilledButton.icon(
              onPressed: () => _runAction(
                context,
                ref,
                () => ref
                    .read(medicalRepositoryProvider)
                    .checkinRoom(treatmentId: task.treatmentId),
                'Check-in thành công',
              ),
              icon: const Icon(Icons.login_rounded),
              label: const Text('Check-in'),
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
                'Check-out thành công',
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Check-out'),
            ),
          if (canAct) const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => _showResultStatus(context, ref),
            icon: const Icon(Icons.assignment_turned_in_outlined),
            label: const Text('Kết quả'),
          ),
          if (canAct) const SizedBox(height: AppSpacing.sm),
          if (canAct)
            TextButton.icon(
              onPressed: () => _confirmCancel(context, ref),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Hủy chỉ định'),
            ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

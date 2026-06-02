import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/staff/presentation/providers/staff_providers.dart';

class RequestStaffPage extends ConsumerStatefulWidget {
  const RequestStaffPage({super.key});

  @override
  ConsumerState<RequestStaffPage> createState() => _RequestStaffPageState();
}

class _RequestStaffPageState extends ConsumerState<RequestStaffPage> {
  final _nodeController = TextEditingController();
  final _assetController = TextEditingController();
  final _noteController = TextEditingController();
  String _assistanceType = 'Hỗ trợ di chuyển';
  bool _isSubmitting = false;
  bool _submitted = false;

  static const _types = [
    'Hỗ trợ di chuyển',
    'Hỗ trợ xe lăn',
    'Hỗ trợ y tế',
    'Hỗ trợ khác',
  ];

  @override
  void dispose() {
    _nodeController.dispose();
    _assetController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nodeId = _nodeController.text.trim();
    if (nodeId.isEmpty) {
      AppToast.showError('Vui lòng nhập mã vị trí của bạn.');
      return;
    }

    final extraNote = _noteController.text.trim();
    final note = extraNote.isEmpty
        ? '[$_assistanceType]'
        : '[$_assistanceType] $extraNote';

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
        title: const Text('Yêu cầu hỗ trợ'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pageWithTop,
        child: _submitted
            ? _SuccessView()
            : _FormView(
                nodeController: _nodeController,
                assetController: _assetController,
                noteController: _noteController,
                assistanceType: _assistanceType,
                onTypeChanged: (v) => setState(() => _assistanceType = v),
                onSubmit: _isSubmitting ? null : _submit,
                isSubmitting: _isSubmitting,
                types: _types,
              ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.nodeController,
    required this.assetController,
    required this.noteController,
    required this.assistanceType,
    required this.onTypeChanged,
    required this.onSubmit,
    required this.isSubmitting,
    required this.types,
  });

  final TextEditingController nodeController;
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
            Text('Loại hỗ trợ', style: context.textTheme.titleSmall),
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
            TextField(
              controller: nodeController,
              enabled: !isSubmitting,
              decoration: const InputDecoration(
                labelText: 'Mã vị trí hiện tại *',
                hintText: 'vd: ENT-01',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: assetController,
              enabled: !isSubmitting,
              decoration: const InputDecoration(
                labelText: 'Mã thiết bị (nếu có)',
                hintText: 'vd: WL-001',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.accessible_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: noteController,
              enabled: !isSubmitting,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Ghi chú thêm',
                hintText: 'Mô tả tình huống cần hỗ trợ...',
                border: OutlineInputBorder(),
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
              label: const Text('Gửi yêu cầu'),
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
              'Yêu cầu đã được gửi!',
              style: context.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Nhân viên sẽ đến hỗ trợ bạn trong thời gian sớm nhất.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/'),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}

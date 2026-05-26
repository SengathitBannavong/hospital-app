import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/util/presentation/providers/util_providers.dart';
import 'package:image_picker/image_picker.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _commentController = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _images = [];
  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;
    setState(() => _images.add(image));
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      AppToast.showError('Vui lòng chọn số sao đánh giá.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(utilRepositoryProvider)
          .sendFeedback(
            rating: _rating,
            comment: _commentController.text.trim(),
            images: const <String>[],
          );
      ref.invalidate(feedbackSummaryProvider);
      if (!mounted) return;
      AppToast.showSuccess('Cảm ơn bạn đã đánh giá!');
      context.pop();
    } catch (error) {
      if (mounted) {
        AppToast.showError(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(feedbackSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Đánh giá ứng dụng'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pageWithTop,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            summary.when(
              loading: () => const _SummaryLoadingCard(),
              error: (_, _) => const SizedBox.shrink(),
              data: (item) => Card(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Text(
                    'Đã có ${item.totalFeedbacks} đánh giá • '
                    '${item.averageRating.toStringAsFixed(1)}★',
                    style: context.textTheme.titleMedium,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Card(
              child: Padding(
                padding: AppSpacing.cardPaddingLarge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bạn hài lòng mức nào?',
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        for (var i = 1; i <= 5; i++)
                          IconButton(
                            tooltip: '$i sao',
                            onPressed: _isSubmitting
                                ? null
                                : () => setState(() => _rating = i),
                            icon: Icon(
                              i <= _rating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: Colors.amber.shade700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _commentController,
                      enabled: !_isSubmitting,
                      minLines: 4,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Góp ý',
                        hintText: 'Nhập chia sẻ của bạn',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _pickImage,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Chọn ảnh'),
                    ),
                    if (_images.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      for (final image in _images)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            image.name,
                            style: context.textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Gửi đánh giá'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryLoadingCard extends StatelessWidget {
  const _SummaryLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('Đang tải đánh giá...', style: context.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

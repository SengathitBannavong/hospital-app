import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/util/presentation/providers/util_providers.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      AppToast.showError(context.l10n.feedbackErrorNoRating);
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
      AppToast.showSuccess(context.l10n.feedbackThanks);
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
        title: Text(context.l10n.profileRateApp),
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
                    context.l10n.feedbackSummary(
                      item.totalFeedbacks,
                      item.averageRating.toStringAsFixed(1),
                    ),
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
                      context.l10n.feedbackHowSatisfied,
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        for (var i = 1; i <= 5; i++)
                          IconButton(
                            tooltip: context.l10n.feedbackStars(i),
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
                      decoration: InputDecoration(
                        labelText: context.l10n.feedbackCommentLabel,
                        hintText: context.l10n.feedbackCommentHint,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Tooltip(
                      message: context.l10n.feedbackImageTooltip,
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.image_outlined),
                        label: Text(context.l10n.feedbackPickImage),
                      ),
                    ),
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
                  : Text(context.l10n.feedbackSubmit),
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
            Text(
              context.l10n.feedbackLoading,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

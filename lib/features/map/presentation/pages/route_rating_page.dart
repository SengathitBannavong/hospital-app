import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

class RouteRatingPage extends ConsumerStatefulWidget {
  const RouteRatingPage({super.key, required this.routeId});

  final String routeId;

  @override
  ConsumerState<RouteRatingPage> createState() => _RouteRatingPageState();
}

class _RouteRatingPageState extends ConsumerState<RouteRatingPage> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isAccurate = true;
  bool _isSubmitting = false;
  bool _submitted = false;

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
          .read(mapRepositoryProvider)
          .rateRoute(
            routeId: widget.routeId,
            rating: _rating,
            comment: _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
            isAccurate: _isAccurate,
          );
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitted = true;
        });
        AppToast.showSuccess(context.l10n.rrThanks);
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
        title: Text(context.l10n.rrTitle),
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
                      Row(
                        children: [
                          Icon(
                            Icons.route_rounded,
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              context.l10n.rrRouteId(widget.routeId),
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        context.l10n.rrQuality,
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
                                size: 32,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _commentController,
                        enabled: !_isSubmitting,
                        minLines: 3,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: context.l10n.rrCommentLabel,
                          hintText: context.l10n.rrCommentHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        context.l10n.rrAccurateQuestion,
                        style: context.textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SegmentedButton<bool>(
                          segments: [
                            ButtonSegment<bool>(
                              value: true,
                              label: Text(context.l10n.commonYes),
                            ),
                            ButtonSegment<bool>(
                              value: false,
                              label: Text(context.l10n.commonNo),
                            ),
                          ],
                          selected: {_isAccurate},
                          onSelectionChanged: _isSubmitting
                              ? null
                              : (selection) {
                                  setState(() {
                                    _isAccurate = selection.first;
                                  });
                                },
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
                            : const Icon(Icons.send_rounded),
                        label: Text(context.l10n.feedbackSubmit),
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
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.rrSuccessTitle,
            style: context.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.rrSuccessSubtitle,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(onPressed: onBack, child: Text(context.l10n.commonBack)),
        ],
      ),
    );
  }
}

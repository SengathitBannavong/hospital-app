import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/features/util/data/models/faq_item.dart';
import 'package:hospital_app/features/util/presentation/providers/util_providers.dart';
import '../../../../core/theme/hospital_theme.dart';

class FaqPage extends ConsumerStatefulWidget {
  const FaqPage({super.key});

  @override
  ConsumerState<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends ConsumerState<FaqPage> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final faqs = ref.watch(faqProvider(null));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/info'),
        ),
        title: const Text('FAQ'),
      ),
      body: faqs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            _FaqErrorState(onRetry: () => ref.invalidate(faqProvider(null))),
        data: (items) {
          final categories = _categories(items);
          final visibleItems = _selectedCategory == null
              ? items
              : items
                    .where((item) => item.category == _selectedCategory)
                    .toList();
          return ListView(
            padding: AppSpacing.pageWithTop,
            children: [
              if (categories.length > 1) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: const Text('Tất cả'),
                          selected: _selectedCategory == null,
                          onSelected: (_) {
                            setState(() => _selectedCategory = null);
                          },
                        ),
                      ),
                      for (final category in categories)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (_) {
                              setState(() => _selectedCategory = category);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (visibleItems.isEmpty)
                Card(
                  child: Padding(
                    padding: AppSpacing.cardPaddingLarge,
                    child: Text(
                      'Chưa có câu hỏi thường gặp.',
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                for (final item in visibleItems) ...[
                  _FaqTile(item: item),
                  const SizedBox(height: AppSpacing.md),
                ],
            ],
          );
        },
      ),
    );
  }

  List<String> _categories(List<FaqItem> items) {
    final categories =
        items
            .map((item) => item.category.trim())
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return categories;
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item});

  final FaqItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(
          Icons.help_outline_rounded,
          color: context.colorScheme.primary,
        ),
        title: Text(item.question),
        childrenPadding: AppSpacing.cardPadding,
        children: [
          Align(alignment: Alignment.centerLeft, child: Text(item.answer)),
        ],
      ),
    );
  }
}

class _FaqErrorState extends StatelessWidget {
  const _FaqErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.cardPaddingLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 36),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Không thể tải câu hỏi thường gặp. Vui lòng thử lại.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

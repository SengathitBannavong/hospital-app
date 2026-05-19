import 'package:flutter/material.dart';
import '../../../../core/theme/hospital_theme.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'Làm sao để tìm phòng khám?',
        'a': 'Bạn có thể mở Bản đồ và tìm tên phòng hoặc khoa.',
      },
      {
        'q': 'Làm sao để xem nhiệm vụ y tế?',
        'a': 'Vào mục Y tế để xem nhiệm vụ, hàng chờ và đơn thuốc.',
      },
      {
        'q': 'Làm sao để xem thông báo?',
        'a': 'Vào mục Thông báo trên thanh điều hướng.',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView.separated(
        padding: AppSpacing.pageWithTop,
        itemCount: faqs.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = faqs[index];
          return Card(
            child: ExpansionTile(
              title: Text(item['q']!),
              childrenPadding: AppSpacing.cardPadding,
              children: [Text(item['a']!)],
            ),
          );
        },
      ),
    );
  }
}

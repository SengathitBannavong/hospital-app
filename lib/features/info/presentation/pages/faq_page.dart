import 'package:flutter/material.dart';
import '../../../../core/theme/hospital_theme.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'question': 'Làm sao để tìm phòng khám?',
        'answer': 'Bạn có thể mở mục Bản đồ và tìm tên phòng hoặc khoa.',
      },
      {
        'question': 'Làm sao để xem nhiệm vụ y tế?',
        'answer':
            'Bạn có thể vào mục Y tế để xem nhiệm vụ, hàng chờ và đơn thuốc.',
      },
      {
        'question': 'Làm sao để xem thông báo?',
        'answer': 'Bạn có thể vào mục Thông báo để xem các thông báo mới.',
      },
      {
        'question': 'Tôi có thể chỉnh sửa hồ sơ ở đâu?',
        'answer': 'Bạn có thể vào mục Hồ sơ và nhấn nút chỉnh sửa.',
      },
      {
        'question': 'Nếu tôi không tìm thấy phòng thì làm sao?',
        'answer':
            'Bạn có thể dùng bản đồ hoặc liên hệ nhân viên bệnh viện để giúp',
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
              leading: Icon(
                Icons.help_outline_rounded,
                color: context.colorScheme.primary,
              ),
              title: Text(item['question']!),
              childrenPadding: AppSpacing.cardPadding,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(item['answer']!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

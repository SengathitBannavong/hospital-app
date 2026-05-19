import 'package:flutter/material.dart';
import '../../../../core/theme/hospital_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giới thiệu')),
      body: SingleChildScrollView(
        padding: AppSpacing.pageWithTop,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: AppSpacing.cardPaddingLarge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hospital App',
                      style: context.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Ứng dụng hỗ trợ bệnh viện giúp bệnh nhân '
                      'xem lịch hẹn, bản đồ, nhiệm vụ y tế và thông báo.',
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Text('Tính năng chính', style: context.textTheme.titleMedium),

            const SizedBox(height: AppSpacing.md),

            const ListTile(
              leading: Icon(Icons.map_rounded),
              title: Text('Bản đồ bệnh viện'),
            ),

            const ListTile(
              leading: Icon(Icons.notifications_rounded),
              title: Text('Thông báo'),
            ),

            const ListTile(
              leading: Icon(Icons.local_hospital_rounded),
              title: Text('Quản lý y tế'),
            ),

            const ListTile(
              leading: Icon(Icons.person_rounded),
              title: Text('Hồ sơ người dùng'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/hospital_theme.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/info'),
        ),
        title: const Text('Liên hệ'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pageWithTop,
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: AppSpacing.cardPaddingLarge,
                child: Column(
                  children: [
                    Icon(
                      Icons.local_hospital_rounded,
                      size: 64,
                      color: context.colorScheme.primary,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'Bệnh viện Trung tâm',
                      style: context.textTheme.headlineSmall,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    const ListTile(
                      leading: Icon(Icons.phone_rounded),
                      title: Text('+84 81 441 9625'),
                    ),

                    const ListTile(
                      leading: Icon(Icons.email_rounded),
                      title: Text('support@hospitalapp.com'),
                    ),

                    const ListTile(
                      leading: Icon(Icons.location_on_rounded),
                      title: Text('Hanoi, Viet nam'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

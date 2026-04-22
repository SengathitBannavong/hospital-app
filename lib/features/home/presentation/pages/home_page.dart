import 'package:flutter/material.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/medical_info_card.dart';
import '../../../profile/presentation/pages/medical_profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // Theme Toggle Button
          IconButton(
            icon: Icon(context.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: () {
              themeController.toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xl),

            // Welcome Card
            Card(
              child: Padding(
                padding: AppSpacing.cardPaddingLarge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Hospital App',
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: context.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your health, our priority. Architecture and '
                      'theme system initialized successfully.',
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Using our New Reusable Component
            Text('Patient Overview', style: context.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),

            MedicalInfoCard(
              label: 'Total Appointments',
              value: '$_counter Today',
              icon: Icons.calendar_month,
              onTap: () {
                debugPrint('Tapped appointments card');
              },
            ),

            const SizedBox(height: AppSpacing.md),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MedicalProfilePage(),
                  ),
                );
              },
              icon: const Icon(Icons.health_and_safety),
              label: const Text('Update Medical Profile'),
            ),

            const SizedBox(height: AppSpacing.xl),

            const MedicalInfoCard(
              label: 'Available Doctors',
              value: '42 Specialists',
              icon: Icons.medical_services,
              color: AppColors.secondary,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Status Badge Example
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest,
                borderRadius: AppRadius.borderLg,
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.statusAvailable,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'All systems operational',
                    style: context.textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment Appointments',
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../core/theme/hospital_theme.dart';
import '../core/theme/theme_controller.dart';
import '../features/home/presentation/pages/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Hospital App',
          // USING CUSTOM THEME SYSTEM
          theme: HospitalTheme.light,
          darkTheme: HospitalTheme.dark,
          themeMode: themeController.themeMode,
          home: const HomePage(title: 'Hospital App Home'),
        );
      },
    );
  }
}

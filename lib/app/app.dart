import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/hospital_theme.dart';
import '../core/theme/theme_controller.dart';
import '../features/auth/presentation/pages/login_otp_page.dart';
import '../features/auth/presentation/pages/welcome_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

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
          home: FutureBuilder<bool>(
            future: _isLoggedIn(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data == true) {
                return const WelcomePage();
              }

              return const LoginOtpPage();
            },
          ),
        );
      },
    );
  }
}

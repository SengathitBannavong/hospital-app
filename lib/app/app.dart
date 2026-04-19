import 'package:flutter/material.dart';

import 'package:hospital_app/core/network/token_repository.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/theme/theme_controller.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/auth/presentation/pages/login_otp_page.dart';
import 'package:hospital_app/features/home/presentation/pages/home_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<bool> _hasSessionFuture;

  @override
  void initState() {
    super.initState();
    _hasSessionFuture = TokenRepository.hasToken();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        return MaterialApp(
          scaffoldMessengerKey: AppToast.scaffoldKey,
          navigatorKey: AppToast.navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Hospital App',
          // USING CUSTOM THEME SYSTEM
          theme: HospitalTheme.light,
          darkTheme: HospitalTheme.dark,
          themeMode: themeController.themeMode,
          home: FutureBuilder<bool>(
            future: _hasSessionFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final hasSession = snapshot.data ?? false;
              return hasSession
                  ? const HomePage(title: 'Hospital App Home')
                  : const LoginOtpPage();
            },
          ),
        );
      },
    );
  }
}

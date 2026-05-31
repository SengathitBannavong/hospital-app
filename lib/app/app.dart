import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/navigation/app_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/theme/theme_controller.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/core/config/app_initializer.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/features/chat/presentation/providers/chat_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final authUser = ref.watch(authStateProvider);
    if (authUser != null) {
      ref.watch(chatRoomsProvider);
    }

    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: router,
          scaffoldMessengerKey: AppToast.scaffoldKey,
          // go_router handles its own navigation key,
          // but AppToast might need one
          // We can set it in the router if needed.
          debugShowCheckedModeBanner: false,
          title: 'Hospital App',
          theme: HospitalTheme.light,
          darkTheme: HospitalTheme.dark,
          themeMode: themeController.themeMode,
          builder: (context, child) {
            return AppInitializer(child: child ?? const SizedBox.shrink());
          },
        );
      },
    );
  }
}

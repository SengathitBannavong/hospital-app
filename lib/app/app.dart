import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/navigation/app_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/theme/theme_controller.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/core/widgets/version_check_widget.dart';
import 'package:hospital_app/core/widgets/app_initializer.dart';
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

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
            return AppInitializer(
              child: VersionCheckWidget(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}

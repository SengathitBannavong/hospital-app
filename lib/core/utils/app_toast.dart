import 'package:flutter/material.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AppToast {
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  static final navigatorKey = GlobalKey<NavigatorState>();

  static void showError(String message) => _show(
    message,
    solidColor: AppColors.error,
    surfaceColor: AppColors.errorSurface,
    icon: Icons.error_outline,
  );

  static void showSuccess(String message) => _show(
    message,
    solidColor: AppColors.success,
    surfaceColor: AppColors.successSurface,
    icon: Icons.check_circle_outline,
  );

  static void showWarning(String message) => _show(
    message,
    solidColor: AppColors.warning,
    surfaceColor: AppColors.warningSurface,
    icon: Icons.warning_amber_outlined,
  );

  static void _show(
    String message, {
    required Color solidColor,
    required Color surfaceColor,
    required IconData icon,
  }) {
    final state = scaffoldKey.currentState;
    final overlay = navigatorKey.currentState?.overlay;
    if (state == null || overlay == null) return;

    final isDark = Theme.of(state.context).brightness == Brightness.dark;
    final backgroundColor = isDark ? surfaceColor : solidColor;
    final contentColor = isDark ? solidColor : Colors.white;

    showTopSnackBar(
      overlay,
      CustomSnackBar.info(
        message: message,
        backgroundColor: backgroundColor,
        textStyle: TextStyle(
          color: contentColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        icon: Icon(icon, color: contentColor, size: 64),
      ),
    );
  }
}

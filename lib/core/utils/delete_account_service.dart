import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/theme/app_colors.dart';

class DeleteAccountService {
  /// Show confirmation dialog for account deletion
  static Future<bool?> showDeleteAccountConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.settingsDeleteAccount),
        content: Text(context.l10n.daConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.l10n.commonDelete,
              style: const TextStyle(color: AppColors.emergency),
            ),
          ),
        ],
      ),
    );
  }

  /// Show password confirmation dialog for account deletion
  static Future<String?> showPasswordConfirmation(BuildContext context) {
    final passwordController = TextEditingController();

    return showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.daPasswordTitle),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: context.l10n.daPasswordHint,
            labelText: context.l10n.authPassword,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, passwordController.text),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    ).whenComplete(passwordController.dispose);
  }

  /// Show success message after account deletion
  static void showDeleteAccountSuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.daSuccessTitle),
        content: Text(context.l10n.daSuccessBody),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen
              context.go('/login');
            },
            child: Text(context.l10n.commonOk),
          ),
        ],
      ),
    );
  }

  /// Show error message
  static void showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.daErrorTitle),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.commonOk),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/app_colors.dart';

class DeleteAccountService {
  /// Show confirmation dialog for account deletion
  static Future<bool?> showDeleteAccountConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tài khoản của mình không?\n'
          'Hành động này không thể đảo ngược.\n'
          'Tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.emergency),
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
        title: const Text('Xác nhận mật khẩu'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Nhập mật khẩu của bạn',
            labelText: 'Mật khẩu',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy bỏ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, passwordController.text),
            child: const Text('Xác nhận'),
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
        title: const Text('Tài khoản đã được xóa'),
        content: const Text('Tài khoản của bạn đã được xóa thành công.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen
              context.go('/login');
            },
            child: const Text('OK'),
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
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

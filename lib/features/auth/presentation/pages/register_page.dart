import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/core/widgets/fade_slide_transition.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/features/auth/presentation/widgets/auth_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  DateTime? _selectedDob;
  int _selectedGender = 0; // 0 = male, 1 = female, 2 = other

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final firstDate = DateTime(1950);
    final initialDate = DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: initialDate,
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedDob == null) {
      AppToast.showError('Vui lòng chọn ngày sinh.');
      return;
    }

    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final fullName = _nameController.text.trim();

    // Format date as yyyy-MM-dd
    final dob = _selectedDob!.toIso8601String().split('T')[0];

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authStateProvider.notifier)
          .signup(
            phoneNumber: phone,
            password: password,
            fullName: fullName,
            dob: dob,
            gender: _selectedGender,
          );

      if (mounted) {
        AppToast.showSuccess('Mã xác thực đã được gửi.');
        context.push(
          '/verify-otp/$phone/signup',
          extra: {'password': password, 'fullName': fullName},
        );
      }
    } catch (error) {
      if (!mounted) return;
      AppToast.showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isSmallScreen = screenHeight < 700;

    final dobFormatted = _selectedDob != null
        ? '${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}'
        : 'Chọn ngày sinh';

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: isSmallScreen ? 40 : null,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 100),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                            isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                          ),
                          decoration: BoxDecoration(
                            color: context.colorScheme.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_add_rounded,
                            size: isSmallScreen ? 48 : 64,
                            color: context.colorScheme.secondary,
                          ),
                        ),
                        SizedBox(
                          height: isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                        ),
                        Text(
                          'Tạo tài khoản',
                          textAlign: TextAlign.center,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 20 : null,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Tham gia cùng chúng tôi để được hỗ trợ tốt nhất',
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                            fontSize: isSmallScreen ? 13 : null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: isSmallScreen ? AppSpacing.lg : AppSpacing.xxl,
                  ),

                  // Register Form Card
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 300),
                    child: Card(
                      elevation: 0,
                      color: context.colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderLg,
                        side: BorderSide(
                          color: context.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(
                          isSmallScreen ? AppSpacing.lg : AppSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Thông tin cá nhân',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: isSmallScreen
                                  ? AppSpacing.lg
                                  : AppSpacing.xl,
                            ),
                            AuthTextField(
                              controller: _nameController,
                              hintText: 'Họ và tên',
                              prefixIcon: Icons.person_outline,
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Nhập họ tên của bạn'
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AuthTextField(
                              controller: _phoneController,
                              hintText: 'Số điện thoại',
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_outlined,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              maxLength: 11,
                              validator: (value) =>
                                  (value == null || value.trim().length < 8)
                                  ? 'Số điện thoại không hợp lệ'
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            // Date of Birth Picker
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _selectDateOfBirth,
                                borderRadius: AppRadius.borderMd,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.md,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: context.colorScheme.outlineVariant,
                                    ),
                                    borderRadius: AppRadius.borderMd,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        color: context
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Text(
                                          dobFormatted,
                                          style: context.textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            // Gender Dropdown
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: context.colorScheme.outlineVariant,
                                ),
                                borderRadius: AppRadius.borderMd,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                ),
                                child: DropdownButton<int>(
                                  value: _selectedGender,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items: [
                                    DropdownMenuItem(
                                      value: 0,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.male_outlined,
                                            color: context
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          const Text('Nam'),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 1,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.female_outlined,
                                            color: context
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          const Text('Nữ'),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 2,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.wc_outlined,
                                            color: context
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          const Text('Khác'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _selectedGender = value);
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: isSmallScreen
                                  ? AppSpacing.lg
                                  : AppSpacing.xl,
                            ),
                            Text(
                              'Thông tin bảo mật',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: isSmallScreen
                                  ? AppSpacing.lg
                                  : AppSpacing.xl,
                            ),
                            AuthTextField(
                              controller: _passwordController,
                              hintText: 'Mật khẩu',
                              obscureText: !_isPasswordVisible,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: _togglePasswordVisibility,
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                tooltip: _isPasswordVisible
                                    ? 'Ẩn mật khẩu'
                                    : 'Hiện mật khẩu',
                                visualDensity: VisualDensity.compact,
                              ),
                              validator: (value) =>
                                  (value == null || value.trim().length < 6)
                                  ? 'Mật khẩu tối thiểu 6 ký tự'
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AuthTextField(
                              controller: _confirmPasswordController,
                              hintText: 'Xác nhận mật khẩu',
                              obscureText: !_isConfirmPasswordVisible,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: _toggleConfirmPasswordVisibility,
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                tooltip: _isConfirmPasswordVisible
                                    ? 'Ẩn mật khẩu'
                                    : 'Hiện mật khẩu',
                                visualDensity: VisualDensity.compact,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Vui lòng xác nhận mật khẩu';
                                }
                                if (value != _passwordController.text) {
                                  return 'Mật khẩu không khớp';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: isSmallScreen
                                  ? AppSpacing.md
                                  : AppSpacing.lg,
                            ),
                            SizedBox(
                              height: isSmallScreen ? 48 : 56,
                              child: FilledButton(
                                onPressed: _isLoading ? null : _submit,
                                style: FilledButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppRadius.borderMd,
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        'Đăng ký',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: isSmallScreen ? AppSpacing.lg : AppSpacing.xl,
                  ),

                  // Footer Section
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 400),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đã có tài khoản?',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                            fontSize: isSmallScreen ? 13 : null,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            'Đăng nhập ngay',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 13 : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

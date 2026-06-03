import 'package:flutter/material.dart';

import '../../../../core/theme/hospital_theme.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/dob_utils.dart';
import '../../data/models/profile_update_request.dart';
import '../../data/models/user_profile.dart';

class ProfileForm extends StatefulWidget {
  final UserProfile initialProfile;
  final Future<void> Function(ProfileUpdateRequest request) onSave;
  final VoidCallback onCancel;
  final bool isSubmitting;

  const ProfileForm({
    super.key,
    required this.initialProfile,
    required this.onSave,
    required this.onCancel,
    this.isSubmitting = false,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _dobController;
  int? _selectedGender;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.initialProfile.fullName,
    );
    _dobController = TextEditingController(text: widget.initialProfile.dob);
    _selectedGender = widget.initialProfile.gender;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final parsed = DateTime.tryParse(_dobController.text);
    final firstDate = DateTime(1950);
    final lastDate = lastAllowedDob();

    DateTime initialDate;
    if (parsed != null) {
      if (parsed.isAfter(lastDate)) {
        initialDate = lastDate;
      } else if (parsed.isBefore(firstDate)) {
        initialDate = firstDate;
      } else {
        initialDate = parsed;
      }
    } else {
      initialDate = lastDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        final year = picked.year;
        final month = picked.month.toString().padLeft(2, '0');
        final day = picked.day.toString().padLeft(2, '0');
        _dobController.text = "$year-$month-$day";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _fullNameController,
            enabled: !widget.isSubmitting,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập họ và tên';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _dobController,
            enabled: !widget.isSubmitting,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Ngày sinh',
              prefixIcon: Icon(Icons.calendar_today_outlined),
            ),
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<int>(
            initialValue: _selectedGender,
            onChanged: widget.isSubmitting
                ? null
                : (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
            decoration: const InputDecoration(
              labelText: 'Giới tính',
              prefixIcon: Icon(Icons.wc_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 0, child: Text('Nam')),
              DropdownMenuItem(value: 1, child: Text('Nữ')),
              DropdownMenuItem(value: 2, child: Text('Khác')),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.isSubmitting ? null : widget.onCancel,
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.isSubmitting
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;

                          // If DOB provided, validate minimum age 13
                          final dobText = _dobController.text.trim();
                          if (dobText.isNotEmpty) {
                            final parsedDob = DateTime.tryParse(dobText);
                            if (parsedDob == null) {
                              AppToast.showError('Ngày sinh không hợp lệ.');
                              return;
                            }
                            if (!isAtLeastAge(parsedDob, 13)) {
                              AppToast.showError(
                                'Bạn phải ít nhất 13 tuổi để đăng ký.',
                              );
                              return;
                            }
                          }

                          await widget.onSave(
                            ProfileUpdateRequest(
                              fullName: _fullNameController.text.trim(),
                              dob: _dobController.text.trim().isEmpty
                                  ? null
                                  : _dobController.text.trim(),
                              gender: _selectedGender,
                              avatar: widget.initialProfile.avatar,
                            ),
                          );
                        },
                  child: widget.isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Lưu'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

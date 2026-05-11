import 'package:flutter/material.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../data/models/user_profile.dart';

class ProfileForm extends StatefulWidget {
  final UserProfile initialProfile;
  final Function(String fullName, String dob, int gender) onSave;
  final VoidCallback onCancel;

  const ProfileForm({
    super.key,
    required this.initialProfile,
    required this.onSave,
    required this.onCancel,
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dobController.text) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _fullNameController,
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
            decoration: const InputDecoration(
              labelText: 'Giới tính',
              prefixIcon: Icon(Icons.wc_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 0, child: Text('Nam')),
              DropdownMenuItem(value: 1, child: Text('Nữ')),
              DropdownMenuItem(value: 2, child: Text('Khác')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSave(
                        _fullNameController.text,
                        _dobController.text,
                        _selectedGender ?? 0,
                      );
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

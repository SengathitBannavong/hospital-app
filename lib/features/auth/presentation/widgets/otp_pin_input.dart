import 'package:flutter/material.dart';

class OtpPinInput extends StatelessWidget {
  const OtpPinInput({super.key, required this.controller, this.length = 6});

  final TextEditingController controller;
  final int length;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: length,
      decoration: InputDecoration(
        hintText: 'Enter OTP',
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

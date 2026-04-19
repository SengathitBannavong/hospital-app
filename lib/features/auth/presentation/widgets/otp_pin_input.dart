import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpPinInput extends StatelessWidget {
  const OtpPinInput({super.key, required this.controller, this.length = 6});

  final TextEditingController controller;
  final int length;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: length,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(length),
      ],
      decoration: const InputDecoration(counterText: '', hintText: 'Enter OTP'),
    );
  }
}

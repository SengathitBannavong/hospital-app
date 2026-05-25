import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';

class OtpVerifyFormWidget extends ConsumerStatefulWidget {
  final String email;

  const OtpVerifyFormWidget({Key? key, required this.email}) : super(key: key);

  @override
  ConsumerState<OtpVerifyFormWidget> createState() =>
      _OtpVerifyFormWidgetState();
}

class _OtpVerifyFormWidgetState extends ConsumerState<OtpVerifyFormWidget> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getOtpCode() =>
      _controllers.map((controller) => controller.text).join();

  void _fillOtpValues(int index, String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    for (var i = 0; i < digits.length && index + i < _controllers.length; i++) {
      _controllers[index + i].text = digits[i];
    }

    final nextIndex = (index + digits.length).clamp(0, _focusNodes.length - 1);
    _focusNodes[nextIndex].requestFocus();
  }

  Future<void> _verifyOtp(BuildContext context) async {
    final otpCode = _getOtpCode();
    if (otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ 6 số OTP')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authStateProvider.notifier)
          .verifyOtp(phoneNumber: widget.email, otp: otpCode);

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Xác nhận OTP thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mã OTP đã được gửi đến email:\n${widget.email}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Hàng ô nhập số OTP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 45,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    counterText: "",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (value.length > 1) {
                      _fillOtpValues(index, value);
                      return;
                    }

                    if (value.isNotEmpty && index < 5) {
                      _focusNodes[index + 1]
                          .requestFocus(); // Tự nhảy sang ô kế tiếp
                    } else if (value.isEmpty && index > 0) {
                      _focusNodes[index - 1]
                          .requestFocus(); // Tự lùi về ô trước nếu xóa
                    }
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 30),

          // Nút bấm Xác nhận OTP
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isLoading ? null : () => _verifyOtp(context),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Xác nhận OTP', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

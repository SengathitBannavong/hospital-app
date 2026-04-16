import 'dart:async';

import 'package:flutter/material.dart';

class OtpCountdownButton extends StatefulWidget {
  const OtpCountdownButton({
    super.key,
    required this.onSendOtp,
    this.initialSeconds = 60,
  });

  final Future<void> Function() onSendOtp;
  final int initialSeconds;

  @override
  State<OtpCountdownButton> createState() => _OtpCountdownButtonState();
}

class _OtpCountdownButtonState extends State<OtpCountdownButton> {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isSending = false;

  Future<void> _handleSendOtp() async {
    if (_secondsRemaining > 0 || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await widget.onSendOtp();
      if (!mounted) {
        return;
      }
      setState(() {
        _secondsRemaining = widget.initialSeconds;
      });
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsRemaining == 0) {
          timer.cancel();
        } else {
          setState(() {
            _secondsRemaining--;
          });
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = _isSending
        ? 'Sending...'
        : (_secondsRemaining == 0
              ? 'Send OTP'
              : 'Resend in $_secondsRemaining s');

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_secondsRemaining == 0 && !_isSending)
            ? _handleSendOtp
            : null,
        child: Text(label),
      ),
    );
  }
}

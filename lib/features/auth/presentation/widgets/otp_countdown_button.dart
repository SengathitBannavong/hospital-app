import 'dart:async';

import 'package:flutter/material.dart';

class OtpCountdownButton extends StatefulWidget {
  const OtpCountdownButton({
    super.key,
    required this.onSendOtp,
    this.initialCountdown = 60,
    this.buttonLabel = 'Send OTP',
    this.resendLabel = 'Resend OTP',
    this.errorMessage = 'Unable to send OTP. Please try again.',
  });

  final Future<void> Function() onSendOtp;
  final int initialCountdown;
  final String buttonLabel;
  final String resendLabel;
  final String errorMessage;

  @override
  State<OtpCountdownButton> createState() => _OtpCountdownButtonState();
}

class _OtpCountdownButtonState extends State<OtpCountdownButton> {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isSending = false;

  bool get _isCountingDown => _secondsRemaining > 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handlePressed() async {
    if (_isCountingDown || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await widget.onSendOtp();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_resolveErrorMessage(error))));
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }

    if (!mounted) {
      return;
    }

    _startCountdown();
  }

  String _resolveErrorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    if (message.startsWith('StateError: ')) {
      return message.replaceFirst('StateError: ', '');
    }
    return widget.errorMessage;
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = widget.initialCountdown;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
        });
        return;
      }

      setState(() {
        _secondsRemaining--;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = _isCountingDown
        ? '${widget.resendLabel} (${_secondsRemaining}s)'
        : widget.buttonLabel;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isCountingDown || _isSending ? null : _handlePressed,
        child: _isSending
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}

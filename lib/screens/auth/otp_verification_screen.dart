import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';
import '../../config/app_config.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/otp_input.dart';
import 'reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String identifier;
  final String method;
  final VoidCallback? onVerified;
  final bool isRegistration;

  const OtpVerificationScreen({
    super.key,
    required this.identifier,
    required this.method,
    this.onVerified,
    this.isRegistration = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  int _countdown = 600;
  Timer? _timer;
  String? _devOtp;
  String _otpCode = '';
  String? _otpError;
  bool _loading = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _fetchDevOtp();
  }

  Future<void> _fetchDevOtp() async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/auth/debug-otp');
      final response = await http.get(url).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) setState(() => _devOtp = data['otp']);
      }
    } catch (_) {}
  }

  void _startTimer() {
    _timer?.cancel();
    _countdown = 600;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 0) {
        t.cancel();
        return;
      }
      if (mounted) setState(() => _countdown--);
    });
  }

  String get _formattedTime {
    final min = (_countdown ~/ 60).toString().padLeft(2, '0');
    final sec = (_countdown % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  String get _destinationLabel {
    if (widget.method == "email") return "your email";
    return "your phone";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length < 6) {
      setState(() => _otpError = "Please enter the complete verification code.");
      return;
    }

    setState(() => _loading = true);

    try {
      await AuthService.verifyOTP(widget.identifier, _otpCode);
      if (!mounted) return;
      if (widget.onVerified != null) {
        widget.onVerified!();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(identifier: widget.identifier),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _otpError = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() => _resending = true);
    try {
      await AuthService.forgotPassword(widget.identifier, widget.method);
      if (!mounted) return;
      _startTimer();
      _fetchDevOtp();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Verification code resent."),
            backgroundColor: Color(0xFF006E2F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _onOtpCompleted(String code) {
    setState(() {
      _otpCode = code;
      _otpError = null;
    });
    _verifyOtp();
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _countdown <= 0 && !_resending;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF121C2A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              AuthHeader(
                title: widget.isRegistration ? "Verify Your Email" : "Verification Code",
                subtitle: "Enter the 6-digit code sent to $_destinationLabel",
              ),
              const SizedBox(height: 40),
              OtpInput(
                length: 6,
                onCompleted: _onOtpCompleted,
              ),
              if (_otpError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _otpError!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "Code expires in $_formattedTime",
                  style: const TextStyle(
                    color: Color(0xFF6D7B6C),
                    fontSize: 13,
                  ),
                ),
              ),
              if (_devOtp != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFE0B2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.developer_mode,
                                size: 16, color: Colors.orange.shade700),
                            const SizedBox(width: 6),
                            Text(
                              "DEV MODE",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Your OTP: $_devOtp",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              AuthButton(
                label: "Verify Code",
                loading: _loading,
                disabled: _otpCode.length < 6,
                onPressed: _verifyOtp,
              ),
              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive the code? ",
                      style: TextStyle(color: Color(0xFF6D7B6C), fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: canResend ? _resendCode : null,
                      child: Text(
                        _resending ? "Resending..." : "Resend Code",
                        style: TextStyle(
                          color: canResend
                              ? const Color(0xFF006E2F)
                              : const Color(0xFFBCCBB9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/email_textfield.dart';
import '../../widgets/auth/recovery_method_selector.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _identifierController = TextEditingController();
  String? _identifierError;
  bool _loading = false;
  bool _findingAccount = false;
  bool _accountFound = false;
  String _identifier = "";
  String? _maskedEmail;
  String? _maskedPhone;
  String? _selectedMethod;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    ).hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return digits.length >= 8;
  }

  bool get _identifierValid {
    final value = _identifierController.text.trim();
    if (value.isEmpty) return false;
    return _isValidEmail(value) || _isValidPhone(value);
  }

  Future<void> _findAccount() async {
    final identifier = _identifierController.text.trim();

    if (identifier.isEmpty) {
      setState(() =>
          _identifierError = "Please enter your email or phone number.");
      return;
    }

    if (!_isValidEmail(identifier) && !_isValidPhone(identifier)) {
      setState(() =>
          _identifierError = "Please enter a valid email or phone number.");
      return;
    }

    setState(() {
      _findingAccount = true;
      _identifierError = null;
      _accountFound = false;
      _selectedMethod = null;
    });

    try {
      final result = await AuthService.findAccount(identifier);
      if (!mounted) return;
      setState(() {
        _findingAccount = false;
        _accountFound = true;
        _identifier = identifier;
        _maskedEmail = result["email"];
        _maskedPhone = result["phone"];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _findingAccount = false;
        _identifierError = e.toString();
      });
    }
  }

  bool get _canContinue => _selectedMethod != null && !_loading;

  Future<void> _sendCode() async {
    if (_selectedMethod == null) return;

    setState(() => _loading = true);

    try {
      await AuthService.forgotPassword(_identifier, _selectedMethod!);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            identifier: _identifier,
            method: _selectedMethod!,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                title: "Forgot Password",
                subtitle:
                    "Enter your registered email or phone number to receive a verification code.",
              ),
              const SizedBox(height: 40),
              EmailTextField(
                controller: _identifierController,
                hintText: "Email or phone number",
                errorText: _identifierError,
                onChanged: (_) {
                  if (_identifierError != null) {
                    setState(() => _identifierError = null);
                  }
                  if (_accountFound) {
                    setState(() => _accountFound = false);
                  }
                },
              ),
              const SizedBox(height: 16),
              if (!_accountFound)
                AuthButton(
                  label: "Find Account",
                  loading: _findingAccount,
                  disabled: !_identifierValid || _findingAccount,
                  onPressed: _findAccount,
                ),
              if (_accountFound) ...[
                RecoveryMethodSelector(
                  selectedMethod: _selectedMethod,
                  maskedEmail: _maskedEmail,
                  maskedPhone: _maskedPhone,
                  onMethodSelected: (method) {
                    setState(() => _selectedMethod = method);
                  },
                ),
                const SizedBox(height: 24),
                AuthButton(
                  label: "Send Verification Code",
                  loading: _loading,
                  disabled: !_canContinue,
                  onPressed: _sendCode,
                ),
              ],
              const SizedBox(height: 32),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Remember your password? ",
                      style:
                          TextStyle(color: Color(0xFF6D7B6C), fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: Color(0xFF006E2F),
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

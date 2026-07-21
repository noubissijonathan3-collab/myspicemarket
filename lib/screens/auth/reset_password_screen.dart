import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/password_textfield.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String identifier;

  const ResetPasswordScreen({super.key, required this.identifier});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _passwordError;
  String? _confirmError;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _isValidPassword(String pwd) => pwd.length >= 6;

  double get _strength {
    final pwd = _passwordController.text;
    if (pwd.isEmpty) return 0;
    double s = 0;
    if (pwd.length >= 6) s += 0.25;
    if (pwd.length >= 10) s += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(pwd)) s += 0.2;
    if (RegExp(r'[0-9]').hasMatch(pwd)) s += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pwd)) s += 0.2;
    return s.clamp(0, 1);
  }

  Color get _strengthColor {
    if (_strength < 0.3) return Colors.red;
    if (_strength < 0.6) return Colors.orange;
    if (_strength < 0.8) return const Color(0xFF22C55E);
    return const Color(0xFF006E2F);
  }

  String get _strengthLabel {
    if (_strength == 0) return "";
    if (_strength < 0.3) return "Weak";
    if (_strength < 0.6) return "Fair";
    if (_strength < 0.8) return "Strong";
    return "Very Strong";
  }

  void _validatePassword(String value) {
    setState(() {
      _passwordError = value.isEmpty || _isValidPassword(value)
          ? null
          : "Password must be at least 6 characters.";
    });
  }

  void _validateConfirm(String value) {
    setState(() {
      _confirmError = value.isEmpty
          ? null
          : (value == _passwordController.text
              ? null
              : "Passwords do not match.");
    });
  }

  bool get _canSubmit =>
      _passwordController.text.isNotEmpty &&
      _confirmController.text.isNotEmpty &&
      _passwordError == null &&
      _confirmError == null &&
      !_loading;

  Future<void> _resetPassword() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password.isEmpty) {
      setState(() => _passwordError = "Password is required.");
      return;
    }
    if (!_isValidPassword(password)) {
      setState(
          () => _passwordError = "Password must be at least 6 characters.");
      return;
    }
    if (confirm.isEmpty) {
      setState(() => _confirmError = "Please confirm your password.");
      return;
    }
    if (password != confirm) {
      setState(() => _confirmError = "Passwords do not match.");
      return;
    }

    setState(() => _loading = true);

    try {
      await AuthService.resetPassword(widget.identifier, password);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset successfully. Please sign in."),
          backgroundColor: Color(0xFF006E2F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
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
                title: "Reset Password",
                subtitle: "Create a new password for your account.",
              ),
              const SizedBox(height: 40),
              PasswordTextField(
                controller: _passwordController,
                hintText: "New password",
                errorText: _passwordError,
                obscureText: _obscurePassword,
                onToggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onChanged: _validatePassword,
              ),
              if (_passwordController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _strength,
                    backgroundColor: const Color(0xFFE6EEFF),
                    valueColor: AlwaysStoppedAnimation(_strengthColor),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _strengthLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _strengthColor,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              PasswordTextField(
                controller: _confirmController,
                hintText: "Confirm new password",
                errorText: _confirmError,
                obscureText: _obscureConfirm,
                onToggleObscure: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                onChanged: _validateConfirm,
              ),
              const SizedBox(height: 24),
              AuthButton(
                label: "Reset Password",
                loading: _loading,
                disabled: !_canSubmit,
                onPressed: _resetPassword,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

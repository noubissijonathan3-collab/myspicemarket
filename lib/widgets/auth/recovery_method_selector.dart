import 'package:flutter/material.dart';
import 'recovery_method_card.dart';

class RecoveryMethodSelector extends StatelessWidget {
  final String? selectedMethod;
  final String? maskedEmail;
  final String? maskedPhone;
  final ValueChanged<String> onMethodSelected;

  const RecoveryMethodSelector({
    super.key,
    required this.selectedMethod,
    this.maskedEmail,
    this.maskedPhone,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Choose Verification Method",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF121C2A),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Select how you want to receive the verification code",
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF6D7B6C),
          ),
        ),
        const SizedBox(height: 16),
        if (maskedEmail != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RecoveryMethodCard(
              icon: Icons.email_outlined,
              title: "Send via Email",
              subtitle: "Send code to $maskedEmail",
              isSelected: selectedMethod == "email",
              onTap: () => onMethodSelected("email"),
            ),
          ),
        if (maskedPhone != null)
          RecoveryMethodCard(
            icon: Icons.phone_android_outlined,
            title: "Send via SMS",
            subtitle: "Send code to $maskedPhone",
            isSelected: selectedMethod == "sms",
            onTap: () => onMethodSelected("sms"),
          ),
      ],
    );
  }
}

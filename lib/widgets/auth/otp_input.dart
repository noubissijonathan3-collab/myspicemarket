import 'package:flutter/material.dart';

class OtpInput extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final int length;

  const OtpInput({
    super.key,
    required this.onCompleted,
    this.length = 6,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(widget.length, (_) => TextEditingController());
    focusNodes = List.generate(widget.length, (_) => FocusNode());
    for (var i = 0; i < widget.length; i++) {
      controllers[i].addListener(() => _onFieldChanged(i));
    }
  }

  void _onFieldChanged(int index) {
    final text = controllers[index].text;
    if (text.length > 1) {
      final chars = text.split('');
      for (var i = 0; i < chars.length && index + i < widget.length; i++) {
        controllers[index + i].text = chars[i];
      }
      if (index + chars.length < widget.length) {
        focusNodes[index + chars.length].requestFocus();
      } else {
        focusNodes.last.unfocus();
        _checkComplete();
      }
      return;
    }
    if (text.isNotEmpty && index < widget.length - 1) {
      focusNodes[index + 1].requestFocus();
    }
    if (text.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    _checkComplete();
  }

  void _checkComplete() {
    final code = controllers.map((c) => c.text).join();
    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (i) {
        return SizedBox(
          width: 48,
          height: 56,
          child: TextField(
            controller: controllers[i],
            focusNode: focusNodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF121C2A),
            ),
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF006E2F), width: 2),
              ),
            ),
          ),
        );
      }),
    );
  }
}

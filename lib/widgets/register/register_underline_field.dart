import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Figma üslubunda: label + alt xətt ilə mətn sahəsi.
class RegisterUnderlineField extends StatelessWidget {
  const RegisterUnderlineField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  static const Color _ink = Color(0xFF121212);
  static const Color _muted = Color(0xFF6B6B6B);
  static const Color _line = Color(0xFFC9C9C9);

  @override
  Widget build(BuildContext context) {
    final softKeyboard = keyboardType == TextInputType.emailAddress ||
        keyboardType == TextInputType.phone ||
        obscureText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: _ink,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          autocorrect: !softKeyboard,
          enableSuggestions: !softKeyboard,
          style: const TextStyle(fontSize: 16, color: _ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _muted, fontSize: 15),
            isDense: true,
            contentPadding: const EdgeInsets.only(bottom: 10),
            border: InputBorder.none,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: _line, width: 1),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: _ink, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// Ağ fon, tünd incə çərçivə, pill formalı sosial giriş düyməsi.
class RegisterSocialButton extends StatelessWidget {
  const RegisterSocialButton({
    super.key,
    required this.label,
    required this.leading,
    this.onPressed,
  });

  final String label;
  final Widget leading;
  final VoidCallback? onPressed;

  static const Color _border = Color(0xFF2D2D2D);
  static const Color _ink = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] RegisterSocialButton($label)');
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _ink,
          side: BorderSide(color: _border.withValues(alpha: 0.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _ink,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

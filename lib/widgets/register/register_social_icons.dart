import 'package:flutter/material.dart';

class RegisterSocialIcons {
  static Widget google() {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4285F4),
        height: 1,
      ),
    );
  }

  static Widget apple() {
    return const Icon(Icons.apple, size: 26, color: Color(0xFF121212));
  }

  static Widget facebook() {
    return const Icon(Icons.facebook, size: 28, color: Color(0xFF1877F2));
  }
}

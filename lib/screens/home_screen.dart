import 'package:flutter/material.dart';

import '../tarz/tarz_home_screen.dart';

/// Layihə marşrutlarından açılan əsas ekran — Tarz mobil UI.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.initialNavIndex});

  final int? initialNavIndex;

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] HomeScreen');
    return TarzHomeScreen(initialNavIndex: initialNavIndex);
  }
}


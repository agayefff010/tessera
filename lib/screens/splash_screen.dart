import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String _splashAsset = 'assets/splashscreen.png';

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _timer = Timer(const Duration(seconds: 3), _goToHome);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToHome() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Image.asset(
          _splashAsset,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

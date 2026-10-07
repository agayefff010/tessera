import 'package:flutter/material.dart';

import 'bootstrap/app_bootstrap.dart';
import 'routes/app_routes.dart';
import 'screens/splash_video_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppBootstrap.instance.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] MyApp');
    return MaterialApp(
      title: 'Tessera',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      onGenerateRoute: AppRoutes.generateRoute,
      home: const SplashVideoPage(),
      //home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

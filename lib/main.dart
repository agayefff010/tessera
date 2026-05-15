import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tessera',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: AppRoutes.splash,
      debugShowCheckedModeBanner: false,
    );
  }
}

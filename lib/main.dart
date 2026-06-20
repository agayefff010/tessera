import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'tarz/cart/tarz_cart_controller.dart';
import 'tarz/wishlist/tarz_wishlist_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        TarzCartController.instance,
        TarzWishlistController.instance,
      ]),
      builder: (context, _) {
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
      },
    );
  }
}

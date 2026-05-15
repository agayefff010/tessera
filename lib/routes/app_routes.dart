import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import '../tarz/data/tarz_mock_catalog.dart';
import '../tarz/models/tarz_product_preview.dart';
import '../tarz/screens/tarz_category_listing_screen.dart';
import '../tarz/screens/tarz_search_screen.dart';

/// Məhsul siyahısı səhifəsinə `Navigator.pushNamed` ilə ötürülən arqumentlər.
class ProductListingArgs {
  const ProductListingArgs({required this.title, required this.products});

  final String title;
  final List<TarzProductPreview> products;
}

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String productListing = '/listing/products';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (context) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case search:
        return MaterialPageRoute<void>(
          builder: (context) => const TarzSearchScreen(),
        );
      case productListing:
        final args = settings.arguments;
        var title = 'Trend';
        var products = TarzMockCatalog.homeTrendler();
        if (args is ProductListingArgs) {
          title = args.title;
          products = args.products;
        }
        return MaterialPageRoute<void>(
          builder: (context) => TarzCategoryListingScreen(
            title: title,
            products: products,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}

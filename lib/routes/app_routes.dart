import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import '../tarz/data/tarz_mock_catalog.dart';
import '../tarz/models/tarz_product_preview.dart';
import '../tarz/screens/product_details_screen.dart';
import '../tarz/screens/tarz_cart_screen.dart';
import '../tarz/screens/tarz_category_listing_screen.dart';
import '../tarz/screens/tarz_filter_screen.dart';
import '../tarz/screens/tarz_notifications_screen.dart';
import '../tarz/screens/tarz_search_screen.dart';

/// Məhsul siyahısı səhifəsinə `Navigator.pushNamed` ilə ötürülən arqumentlər.
class ProductListingArgs {
  const ProductListingArgs({
    required this.title,
    required this.products,
    this.totalCount,
    this.isLoading = false,
  });

  final String title;
  final List<TarzProductPreview> products;
  /// API-dən gələn ümumi məhsul sayı; null olduqda `products.length` istifadə olunur.
  final int? totalCount;
  final bool isLoading;
}

/// Məhsul detalları səhifəsinə ötürülən arqumentlər.
class ProductDetailsArgs {
  const ProductDetailsArgs({
    required this.product,
    this.similarProducts = const [],
  });

  final TarzProductPreview product;
  final List<TarzProductPreview> similarProducts;
}

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String filter = '/filter';
  static const String productListing = '/listing/products';
  static const String productDetails = '/product/details';
  static const String cart = '/cart';
  static const String notifications = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (context) => const RegisterScreen());
      case home:
        final navIndex =
            settings.arguments is int ? settings.arguments as int : null;
        return MaterialPageRoute(
          builder: (context) => HomeScreen(initialNavIndex: navIndex),
        );
      case search:
        return MaterialPageRoute<void>(
          builder: (context) => const TarzSearchScreen(),
        );
      case filter:
        final count =
            settings.arguments is int ? settings.arguments as int : null;
        return MaterialPageRoute<void>(
          builder: (context) => TarzFilterScreen(productCount: count),
        );
      case productListing:
        final args = settings.arguments;
        var title = 'Trend';
        var products = TarzMockCatalog.trendListingDemo();
        int? totalCount;
        var isLoading = false;
        if (args is ProductListingArgs) {
          title = args.title;
          products = args.products;
          totalCount = args.totalCount;
          isLoading = args.isLoading;
        }
        return MaterialPageRoute<void>(
          fullscreenDialog: false,
          builder: (context) => TarzCategoryListingScreen(
            title: title,
            products: products,
            totalCount: totalCount,
            isLoading: isLoading,
          ),
        );
      case productDetails:
        final args = settings.arguments;
        if (args is ProductDetailsArgs) {
          return MaterialPageRoute<void>(
            builder: (context) => ProductDetailsScreen(
              product: args.product,
              similarProducts: args.similarProducts,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      case cart:
        return MaterialPageRoute<void>(
          builder: (context) => const TarzCartScreen(),
        );
      case notifications:
        return MaterialPageRoute<void>(
          builder: (context) => const TarzNotificationsScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
    }
  }
}

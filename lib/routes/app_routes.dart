import 'package:flutter/material.dart';

import 'product_listing_args.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import '../tarz/data/tarz_mock_catalog.dart';
import '../tarz/models/product_filter_state.dart';
import '../tarz/models/tarz_product_preview.dart';
import '../tarz/screens/product_details_screen.dart';
import '../tarz/screens/tarz_cart_screen.dart';
import '../tarz/screens/tarz_category_listing_screen.dart';
import '../tarz/screens/tarz_filter_screen.dart';
import '../tarz/screens/tarz_notifications_screen.dart';
import '../tarz/screens/tarz_search_screen.dart';

export 'product_listing_args.dart';

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
        final args = settings.arguments;
        FilterArgs? filterArgs;
        int? legacyCount;
        if (args is FilterArgs) {
          filterArgs = args;
        } else if (args is int) {
          legacyCount = args;
        }
        return MaterialPageRoute<ProductFilterState>(
          builder: (context) => TarzFilterScreen(
            productCount: filterArgs?.productCount ?? legacyCount,
            initial: filterArgs?.initial ?? const ProductFilterState(),
            categories: filterArgs?.categories ?? const [],
          ),
        );
      case productListing:
        final args = settings.arguments;
        if (args is ProductListingArgs) {
          return MaterialPageRoute<void>(
            fullscreenDialog: false,
            builder: (context) => TarzCategoryListingScreen(
              title: args.title,
              categoryId: args.categoryId,
              genderIndex: args.genderIndex,
              searchQuery: args.searchQuery,
              initialFilter: args.initialFilter,
              products: args.products,
              totalCount: args.totalCount,
              useApi: args.usesApi,
            ),
          );
        }
        return MaterialPageRoute<void>(
          fullscreenDialog: false,
          builder: (context) => TarzCategoryListingScreen(
            title: 'Trend',
            products: TarzMockCatalog.trendListingDemo(),
            useApi: false,
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

import '../data/tarz_product_assets.dart';
import '../models/tarz_cart_item.dart';

/// Köhnə statik mock — artıq əsasən `TarzCartController` istifadə olunur.
abstract final class TarzMockCart {
  static List<TarzCartItem> demoItems() => const [
        TarzCartItem(
          id: 'cart_1',
          title: 'Brown Check Asymmetric Wrap Skirt',
          brand: 'River Island',
          priceLabel: '90₼',
          originalPriceLabel: '120₼',
          badgeLabel: '-25%',
          imageAsset: TarzProductAssets.nikeV5Rnr,
          priceManat: 90,
          originalPriceManat: 120,
        ),
      ];
}

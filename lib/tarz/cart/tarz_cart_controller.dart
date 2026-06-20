import 'package:flutter/foundation.dart';

import '../data/tarz_product_assets.dart';
import '../models/tarz_cart_item.dart';
import '../models/tarz_product_preview.dart';
import 'tarz_price_utils.dart';

/// Tətbiq üzrə səbət vəziyyəti — əlavə/silmə, hesablama, sayğac.
class TarzCartController extends ChangeNotifier {
  TarzCartController._();

  static final TarzCartController instance = TarzCartController._();

  static const double giftWrapFeeManat = 10;

  final List<TarzCartItem> _items = [];

  List<TarzCartItem> get items => List.unmodifiable(_items);

  /// Səbət ikonundakı rəqəm (ümumi miqdar).
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => _items.isEmpty;

  String get itemCountLabel {
    final n = totalQuantity;
    if (n == 0) return '0 məhsul';
    if (n == 1) return '1 məhsul';
    return '$n məhsul';
  }

  /// Məhsul detallarından səbətə əlavə (ölçü ilə unikal sətir).
  void addFromProduct(TarzProductPreview product, {required String size}) {
    final cartId = '${product.id}_$size';
    final price = TarzPriceUtils.parseManat(product.priceLabel);
    final original = product.originalPriceLabel != null
        ? TarzPriceUtils.parseManat(product.originalPriceLabel!)
        : null;

    final title = product.title == 'Nike V5 RNR'
        ? 'Brown Check Asymmetric Wrap Skirt'
        : product.title;

    final index = _items.indexWhere((e) => e.id == cartId);
    if (index >= 0) {
      final existing = _items[index];
      _items[index] = TarzCartItem(
        id: existing.id,
        title: existing.title,
        brand: existing.brand,
        priceLabel: existing.priceLabel,
        imageAsset: existing.imageAsset,
        originalPriceLabel: existing.originalPriceLabel,
        badgeLabel: existing.badgeLabel,
        quantity: existing.quantity + 1,
        priceManat: existing.priceManat,
        originalPriceManat: existing.originalPriceManat,
        size: existing.size,
        color: existing.color,
        vendor: existing.vendor,
      );
    } else {
      _items.add(
        TarzCartItem(
          id: cartId,
          title: title,
          brand: product.brand ?? 'River Island',
          priceLabel: product.priceLabel,
          imageAsset: product.imageAsset ?? TarzProductAssets.nikeV5Rnr,
          originalPriceLabel: product.originalPriceLabel,
          badgeLabel: product.badgeLabel,
          quantity: 1,
          priceManat: price,
          originalPriceManat: original,
          size: size,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    if (quantity < 1) return;
    final index = _items.indexWhere((e) => e.id == id);
    if (index < 0) return;
    final existing = _items[index];
    _items[index] = TarzCartItem(
      id: existing.id,
      title: existing.title,
      brand: existing.brand,
      priceLabel: existing.priceLabel,
      imageAsset: existing.imageAsset,
      originalPriceLabel: existing.originalPriceLabel,
      badgeLabel: existing.badgeLabel,
      quantity: quantity,
      priceManat: existing.priceManat,
      originalPriceManat: existing.originalPriceManat,
      size: existing.size,
      color: existing.color,
      vendor: existing.vendor,
    );
    notifyListeners();
  }

  void incrementQuantity(String id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index < 0) return;
    updateQuantity(id, _items[index].quantity + 1);
  }

  void decrementQuantity(String id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index < 0 || _items[index].quantity <= 1) return;
    updateQuantity(id, _items[index].quantity - 1);
  }

  void removeItem(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  TarzCartSummary buildSummary({bool includeGiftWrap = true}) {
    if (_items.isEmpty) {
      return const TarzCartSummary(
        itemCountLabel: '0 məhsul',
        subtotalLabel: '0₼',
        discountLabel: '0₼',
        giftWrapLabel: '+0₼',
        totalLabel: '0₼',
        strikethroughTotalLabel: '0₼',
        discountManat: 0,
        giftWrapManat: 0,
        totalManat: 0,
        subtotalManat: 0,
        itemsSubtotalManat: 0,
        shippingManat: 0,
      );
    }

    var subtotalOriginal = 0.0;
    var itemsCurrent = 0.0;

    for (final item in _items) {
      final unitOriginal = item.originalPriceManat ?? item.priceManat;
      subtotalOriginal += unitOriginal * item.quantity;
      itemsCurrent += item.priceManat * item.quantity;
    }

    const shipping = 0.0;
    final discountAmount = subtotalOriginal - itemsCurrent;
    final gift = includeGiftWrap ? giftWrapFeeManat : 0.0;
    final total = itemsCurrent + gift + shipping;

    return TarzCartSummary(
      itemCountLabel: itemCountLabel,
      subtotalLabel: TarzPriceUtils.formatManat(subtotalOriginal),
      discountLabel: discountAmount > 0
          ? '-${TarzPriceUtils.formatManat(discountAmount).replaceAll('₼', '')}₼'
          : '0₼',
      giftWrapLabel: '+${TarzPriceUtils.formatManat(gift).replaceAll('₼', '')}₼',
      totalLabel: TarzPriceUtils.formatManat(total),
      strikethroughTotalLabel: TarzPriceUtils.formatManat(subtotalOriginal),
      discountManat: discountAmount,
      giftWrapManat: gift,
      totalManat: total,
      subtotalManat: subtotalOriginal,
      itemsSubtotalManat: itemsCurrent,
      shippingManat: shipping,
    );
  }
}

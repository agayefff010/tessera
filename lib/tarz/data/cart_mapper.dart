import '../cart/tarz_price_utils.dart';
import '../models/tarz_cart_item.dart';
import 'product_mapper.dart';
import 'tarz_product_assets.dart';

/// Backend səbət JSON → UI modelləri.
class CartServerTotals {
  const CartServerTotals({
    this.subtotal,
    this.discount,
    this.total,
    this.shipping,
  });

  final double? subtotal;
  final double? discount;
  final double? total;
  final double? shipping;
}

class CartFetchResult {
  const CartFetchResult({
    required this.items,
    this.totals,
  });

  final List<TarzCartItem> items;
  final CartServerTotals? totals;
}

abstract final class CartMapper {
  static CartFetchResult fromResponse(Map<String, dynamic> body) {
    final root = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : body;

    final itemsRaw = root['items'] ?? root['cartItems'] ?? root['products'];
    final items = <TarzCartItem>[];

    if (itemsRaw is List) {
      for (final entry in itemsRaw) {
        if (entry is Map<String, dynamic>) {
          final item = lineFromJson(entry);
          if (item != null) items.add(item);
        }
      }
    }

    return CartFetchResult(
      items: items,
      totals: _parseTotals(root),
    );
  }

  static CartServerTotals? _parseTotals(Map<String, dynamic> root) {
    final subtotal = _num(root['subtotal'] ?? root['subTotal']);
    final discount = _num(
      root['discount'] ?? root['discountAmount'] ?? root['totalDiscount'],
    );
    final total = _num(root['total'] ?? root['grandTotal']);
    final shipping = _num(root['shipping'] ?? root['shippingCost']);

    if (subtotal == null &&
        discount == null &&
        total == null &&
        shipping == null) {
      return null;
    }

    return CartServerTotals(
      subtotal: subtotal,
      discount: discount,
      total: total,
      shipping: shipping,
    );
  }

  static double? _num(Object? value) {
    if (value is num) return value.toDouble();
    return null;
  }

  static TarzCartItem? lineFromJson(Map<String, dynamic> json) {
    final quantity = (json['quantity'] as num?)?.toInt() ?? 1;
    if (quantity < 1) return null;

    Map<String, dynamic>? productMap;
    String? productId;

    final rawProduct = json['product'];
    if (rawProduct is Map<String, dynamic>) {
      productMap = rawProduct;
      productId = rawProduct['_id']?.toString();
    }

    final rawProductId = json['productId'];
    if (rawProductId is Map<String, dynamic>) {
      productMap ??= rawProductId;
      productId ??= rawProductId['_id']?.toString();
    } else if (rawProductId is String && rawProductId.isNotEmpty) {
      productId = rawProductId;
    }

    productId ??= json['_id']?.toString();
    if (productId == null || productId.isEmpty) return null;

    if (productMap != null) {
      final preview = ProductMapper.fromJson(productMap);
      final price = TarzPriceUtils.parseManat(preview.priceLabel);
      final original = preview.originalPriceLabel != null
          ? TarzPriceUtils.parseManat(preview.originalPriceLabel!)
          : null;

      return TarzCartItem(
        id: productId,
        productId: productId,
        title: preview.title,
        brand: preview.brand ?? 'Tessera',
        priceLabel: preview.priceLabel,
        imageAsset: preview.imageAsset ?? TarzProductAssets.nikeV5Rnr,
        imageUrl: preview.imageUrl,
        originalPriceLabel: preview.originalPriceLabel,
        badgeLabel: preview.badgeLabel,
        quantity: quantity,
        priceManat: price,
        originalPriceManat: original,
        size: json['size']?.toString(),
        color: json['color']?.toString(),
      );
    }

    final price = _num(json['price']) ?? 0;
    final original = _num(json['originalPrice']);

    return TarzCartItem(
      id: productId,
      productId: productId,
      title: json['name']?.toString() ?? json['title']?.toString() ?? 'Məhsul',
      brand: json['brand']?.toString() ?? 'Tessera',
      priceLabel: TarzPriceUtils.formatManatSpaced(price),
      imageAsset: TarzProductAssets.nikeV5Rnr,
      originalPriceLabel:
          original != null ? TarzPriceUtils.formatManatSpaced(original) : null,
      quantity: quantity,
      priceManat: price,
      originalPriceManat: original,
      size: json['size']?.toString(),
      color: json['color']?.toString(),
    );
  }

  static String lineId({
    required String productId,
    String? size,
    String? color,
  }) {
    if (color != null && color.isNotEmpty) {
      return '${productId}_${size ?? 'std'}_$color';
    }
    if (size != null && size.isNotEmpty) {
      return '${productId}_$size';
    }
    return productId;
  }

  static Map<String, dynamic> itemToJson(TarzCartItem item) => {
        'id': item.id,
        'productId': item.productId,
        'title': item.title,
        'brand': item.brand,
        'priceLabel': item.priceLabel,
        'priceManat': item.priceManat,
        'quantity': item.quantity,
        if (item.imageUrl != null) 'imageUrl': item.imageUrl,
        if (item.imageAsset.isNotEmpty) 'imageAsset': item.imageAsset,
        if (item.originalPriceLabel != null)
          'originalPriceLabel': item.originalPriceLabel,
        if (item.originalPriceManat != null)
          'originalPriceManat': item.originalPriceManat,
        if (item.badgeLabel != null) 'badgeLabel': item.badgeLabel,
        if (item.size != null) 'size': item.size,
        if (item.color != null) 'color': item.color,
        if (item.vendor != null) 'vendor': item.vendor,
      };

  static TarzCartItem itemFromJson(Map<String, dynamic> json) {
    return TarzCartItem(
      id: json['id']?.toString() ?? json['productId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      brand: json['brand']?.toString() ?? 'Tessera',
      priceLabel: json['priceLabel']?.toString() ?? '0 ₼',
      imageAsset:
          json['imageAsset']?.toString() ?? TarzProductAssets.nikeV5Rnr,
      imageUrl: json['imageUrl']?.toString(),
      originalPriceLabel: json['originalPriceLabel']?.toString(),
      badgeLabel: json['badgeLabel']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      priceManat: (json['priceManat'] as num?)?.toDouble() ?? 0,
      originalPriceManat: (json['originalPriceManat'] as num?)?.toDouble(),
      size: json['size']?.toString(),
      color: json['color']?.toString(),
      vendor: json['vendor']?.toString(),
    );
  }
}

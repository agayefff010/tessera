import 'package:flutter/foundation.dart';

@immutable
class TarzCartItem {
  const TarzCartItem({
    required this.id,
    required this.title,
    required this.brand,
    required this.priceLabel,
    required this.imageAsset,
    required this.priceManat,
    this.originalPriceLabel,
    this.originalPriceManat,
    this.badgeLabel,
    this.quantity = 1,
    this.size,
    this.color,
    this.vendor,
  });

  final String id;
  final String title;
  final String brand;
  final String priceLabel;
  final String imageAsset;
  final double priceManat;
  final String? originalPriceLabel;
  final double? originalPriceManat;
  final String? badgeLabel;
  final int quantity;
  final String? size;
  final String? color;
  final String? vendor;
}

@immutable
class TarzCartSummary {
  const TarzCartSummary({
    required this.itemCountLabel,
    required this.subtotalLabel,
    required this.discountLabel,
    required this.giftWrapLabel,
    required this.totalLabel,
    required this.strikethroughTotalLabel,
    required this.discountManat,
    required this.giftWrapManat,
    required this.totalManat,
    required this.subtotalManat,
    this.itemsSubtotalManat = 0,
    this.shippingManat = 0,
  });

  final String itemCountLabel;
  final String subtotalLabel;
  final String discountLabel;
  final String giftWrapLabel;
  final String totalLabel;
  final String strikethroughTotalLabel;
  final double discountManat;
  final double giftWrapManat;
  final double totalManat;
  final double subtotalManat;
  final double itemsSubtotalManat;
  final double shippingManat;
}

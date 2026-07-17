import 'package:flutter/foundation.dart';

import 'tarz_product_preview.dart';

@immutable
class TarzProductSizeOption {
  const TarzProductSizeOption({
    required this.size,
    required this.stock,
    this.color,
  });

  final String size;
  final int stock;
  final String? color;

  bool get inStock => stock > 0;
}

@immutable
class TarzProductDetail {
  const TarzProductDetail({
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.imageUrls,
    required this.sizes,
    required this.colors,
    required this.preview,
    this.brand,
    this.originalPriceLabel,
    this.badgeLabel,
    this.description,
    this.materials,
    this.details,
    this.careInstructions,
    this.vendorName,
    this.vendorSlug,
    this.vendorDeliveryAvailable,
    this.vendorAddress,
    this.vendorOpenHours,
    this.vendorStoreAddresses = const [],
    this.styleTag,
    this.season,
  });

  final String id;
  final String title;
  final String? brand;
  final String priceLabel;
  final String? originalPriceLabel;
  final String? badgeLabel;
  final List<String> imageUrls;
  final List<TarzProductSizeOption> sizes;
  final List<String> colors;
  final String? description;
  final String? materials;
  final String? details;
  final String? careInstructions;
  final String? vendorName;
  final String? vendorSlug;
  /// Mağaza çatdırılma təklif edir?
  final bool? vendorDeliveryAvailable;
  final String? vendorAddress;
  final String? vendorOpenHours;
  final List<String> vendorStoreAddresses;
  final String? styleTag;
  final String? season;

  /// Səbət / seçilmişlər üçün qısa model.
  final TarzProductPreview preview;

  List<String> get availableSizes => sizes
      .where((s) => s.inStock)
      .map((s) => s.size)
      .toSet()
      .toList();

  List<String> sizesForColor(String? color) {
    final filtered = color == null || color.isEmpty
        ? sizes
        : sizes.where((s) => s.color == color);
    return filtered
        .where((s) => s.inStock)
        .map((s) => s.size)
        .toSet()
        .toList();
  }

  bool isSizeAvailable(String size, {String? color}) {
    return sizes.any(
      (s) =>
          s.size == size &&
          s.inStock &&
          (color == null || color.isEmpty || s.color == color),
    );
  }

  String? get fullDescription {
    final parts = <String>[
      if (description != null && description!.trim().isNotEmpty) description!.trim(),
      if (materials != null && materials!.trim().isNotEmpty) 'Material: ${materials!.trim()}',
      if (details != null && details!.trim().isNotEmpty) details!.trim(),
      if (careInstructions != null && careInstructions!.trim().isNotEmpty)
        'Qulluq: ${careInstructions!.trim()}',
    ];
    if (parts.isEmpty) return null;
    return parts.join('\n\n');
  }
}

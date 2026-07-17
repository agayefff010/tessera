import 'package:flutter/foundation.dart';

@immutable
class TarzProductPreview {
  const TarzProductPreview({
    required this.id,
    required this.title,
    required this.priceLabel,
    this.brand,
    this.imageUrl,
    this.badgeLabel,
    this.subtitle,
    this.originalPriceLabel,
    this.imageAsset,
    this.rating,
    this.reviewCount,
    this.categoryId,
    this.subcategoryId,
    this.genderId,
    this.slug,
  });

  final String id;
  final String? brand;
  final String title;
  final String priceLabel;
  final String? imageUrl;
  final String? badgeLabel;
  /// İkinci mətn sətri (məs. məhsul tipi).
  final String? subtitle;
  /// Köhnə qiymət (üstündən xətt).
  final String? originalPriceLabel;
  /// Lokal şəkil yolu — şəbəkə URL-i yoxdursa istifadə olunur.
  final String? imageAsset;
  /// API-dən gələn reytinq (məs. 4.3).
  final double? rating;
  /// API-dən gələn rəy sayı.
  final int? reviewCount;
  /// Backend `category` ID-si.
  final String? categoryId;
  /// Backend `subcategory` ID-si.
  final String? subcategoryId;
  /// Backend `gender` ID-si.
  final String? genderId;
  /// Backend `slug` — outfit generate üçün.
  final String? slug;
}

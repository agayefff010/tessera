import 'package:flutter/foundation.dart';

@immutable
class TarzProductPreview {
  const TarzProductPreview({
    required this.id,
    required this.title,
    required this.priceLabel,
    this.imageUrl,
    this.badgeLabel,
    this.subtitle,
    this.originalPriceLabel,
    this.imageAsset,
  });

  final String id;
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
}

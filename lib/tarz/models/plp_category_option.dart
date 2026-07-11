import 'package:flutter/foundation.dart';

@immutable
class PlpCategoryOption {
  const PlpCategoryOption({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlpCategoryOption && id == other.id && name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
}

/// Filtr / PLP xüsusi kateqoriya identifikatorları (API-də yoxdur).
abstract final class PlpSpecialCategory {
  static const discounts = '__discounts__';
  static const brands = '__brands__';
}

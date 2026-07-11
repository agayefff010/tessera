import 'package:flutter/foundation.dart';

/// PLP filtr ekranından və sıralama panelindən gələn state.
@immutable
class ProductFilterState {
  const ProductFilterState({
    this.quickFilterIndex = 2,
    this.minPrice,
    this.maxPrice,
    this.sortCheapFirst = false,
    this.sortExpensiveFirst = false,
    this.subcategoryIds = const {},
  });

  /// 0=Endirimlər, 1=Yenilər, 2=Trend
  final int quickFilterIndex;
  final double? minPrice;
  final double? maxPrice;
  final bool sortCheapFirst;
  final bool sortExpensiveFirst;
  final Set<String> subcategoryIds;

  bool get hasQuickFilter => quickFilterIndex != 2;

  bool get discountsOnly => quickFilterIndex == 0;
  bool get newestQuickFilter => quickFilterIndex == 1;

  String? get apiSort {
    if (sortCheapFirst) return 'price_asc';
    if (sortExpensiveFirst) return 'price_desc';
    if (newestQuickFilter) return 'newest';
    return null;
  }

  bool get hasPriceFilter =>
      minPrice != null || maxPrice != null;

  bool get hasSubcategories => subcategoryIds.isNotEmpty;

  bool get isEmpty =>
      !hasQuickFilter &&
      minPrice == null &&
      maxPrice == null &&
      !sortCheapFirst &&
      !sortExpensiveFirst &&
      subcategoryIds.isEmpty;

  ProductFilterState copyWith({
    int? quickFilterIndex,
    double? minPrice,
    double? maxPrice,
    bool? sortCheapFirst,
    bool? sortExpensiveFirst,
    Set<String>? subcategoryIds,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return ProductFilterState(
      quickFilterIndex: quickFilterIndex ?? this.quickFilterIndex,
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      sortCheapFirst: sortCheapFirst ?? this.sortCheapFirst,
      sortExpensiveFirst: sortExpensiveFirst ?? this.sortExpensiveFirst,
      subcategoryIds: subcategoryIds ?? this.subcategoryIds,
    );
  }
}

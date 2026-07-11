import '../models/product_filter_state.dart';

/// PLP sıralama indeksi ↔ API `sort` parametri.
abstract final class PlpSortMapper {
  static const apiSupportedIndices = {0, 2, 3};

  static String? apiValueForIndex(int index, {String? filterSort}) {
    if (filterSort != null && filterSort.isNotEmpty) return filterSort;
    return switch (index) {
      0 => 'newest',
      2 => 'price_asc',
      3 => 'price_desc',
      _ => null,
    };
  }

  static bool needsClientProcessing(int index, ProductFilterState filter) {
    if (filter.discountsOnly) return true;
    return !apiSupportedIndices.contains(index) && filter.apiSort == null;
  }
}

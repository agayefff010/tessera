import '../tarz/models/plp_category_option.dart';
import '../tarz/models/product_filter_state.dart';
import '../tarz/models/tarz_product_preview.dart';

/// Filtr ekranına ötürülən arqumentlər.
class FilterArgs {
  const FilterArgs({
    this.productCount,
    this.initial = const ProductFilterState(),
    this.categories = const [],
  });

  final int? productCount;
  final ProductFilterState initial;
  final List<PlpCategoryOption> categories;
}

/// Məhsul siyahısı səhifəsinə ötürülən arqumentlər.
class ProductListingArgs {
  const ProductListingArgs({
    required this.title,
    this.categoryId,
    this.genderIndex,
    this.searchQuery,
    this.initialFilter,
    this.products = const [],
    this.totalCount,
  });

  final String title;
  final String? categoryId;
  final int? genderIndex;
  final String? searchQuery;
  final ProductFilterState? initialFilter;
  /// Statik/mock siyahı — API rejimi deyilsə istifadə olunur.
  final List<TarzProductPreview> products;
  final int? totalCount;

  bool get usesApi =>
      searchQuery != null ||
      categoryId != null ||
      genderIndex != null ||
      products.isEmpty;
}

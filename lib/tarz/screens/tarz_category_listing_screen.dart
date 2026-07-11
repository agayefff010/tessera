import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../cart/tarz_price_utils.dart';
import '../data/category_repository.dart';
import '../data/plp_sort_mapper.dart';
import '../data/product_repository.dart';
import '../models/plp_category_option.dart';
import '../../services/api_exception.dart';
import '../models/product_filter_state.dart';
import '../models/tarz_product_preview.dart';
import '../widgets/catalogue/gender_selector.dart';
import '../widgets/listing/plp_category_bottom_sheet.dart';
import '../widgets/listing/plp_empty_state.dart';
import '../widgets/listing/plp_filter_action_bar.dart';
import '../widgets/listing/plp_header.dart';
import '../widgets/listing/plp_product_card.dart';
import '../widgets/listing/plp_shimmer_card.dart';
import '../widgets/listing/plp_sort_bottom_sheet.dart';
import '../widgets/tarz_flash_message.dart';
import '../wishlist/tarz_wishlist_controller.dart';

/// Kateqoriya PLP — API: pagination, filter, sort, kateqoriya.
class TarzCategoryListingScreen extends StatefulWidget {
  const TarzCategoryListingScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.genderIndex,
    this.searchQuery,
    this.initialFilter,
    this.products = const [],
    this.totalCount,
    this.useApi = true,
  });

  final String title;
  final String? categoryId;
  final int? genderIndex;
  final String? searchQuery;
  final ProductFilterState? initialFilter;
  final List<TarzProductPreview> products;
  final int? totalCount;
  final bool useApi;

  @override
  State<TarzCategoryListingScreen> createState() =>
      _TarzCategoryListingScreenState();
}

class _TarzCategoryListingScreenState extends State<TarzCategoryListingScreen> {
  final _productRepo = ProductRepository();
  final _categoryRepo = CategoryRepository();
  final _wishlist = TarzWishlistController.instance;
  final _scrollController = ScrollController();

  late String _title;
  String? _categoryId;
  late int? _genderIndex;
  late ProductFilterState _filter;
  int _sortIndex = 0;

  List<TarzProductPreview> _products = [];
  List<PlpCategoryOption> _categoryOptions = [];
  Set<String>? _categoryScope;
  int _lastRawPage = 1;
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _loadedCount = 0;
  PlpFilterAction? _activeAction;

  bool get _isApiMode => widget.useApi;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _categoryId = widget.categoryId;
    _genderIndex = widget.genderIndex;
    _filter = widget.initialFilter ?? const ProductFilterState();
    _wishlist.addListener(_rebuild);
    _scrollController.addListener(_onScroll);

    if (_isApiMode) {
      _bootstrapApi();
    } else {
      _products = List.from(widget.products);
      _loadedCount = widget.totalCount ?? _products.length;
    }
  }

  @override
  void dispose() {
    _wishlist.removeListener(_rebuild);
    _scrollController.dispose();
    _productRepo.dispose();
    _categoryRepo.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _bootstrapApi() async {
    await _refreshCategoryScope();
    await Future.wait([
      _loadCategoryOptions(),
      _loadFirstPage(),
    ]);
  }

  Future<void> _refreshCategoryScope() async {
    if (_filter.subcategoryIds.isNotEmpty) {
      _categoryScope = Set<String>.from(_filter.subcategoryIds);
      return;
    }

    final id = _categoryId;
    if (id == null ||
        id.isEmpty ||
        id == PlpSpecialCategory.discounts ||
        id == PlpSpecialCategory.brands ||
        id.length < 20) {
      _categoryScope = null;
      return;
    }
    try {
      _categoryScope = await _categoryRepo.collectCategoryScope(id);
    } catch (_) {
      _categoryScope = {id};
    }
  }

  Future<void> _loadCategoryOptions() async {
    try {
      if (_categoryId != null && _categoryId!.isNotEmpty) {
        final subs = await _categoryRepo.fetchSubcategories(_categoryId!);
        if (subs.isNotEmpty) {
          final parent = await _categoryRepo.findById(_categoryId!);
          if (!mounted) return;
          setState(() {
            _categoryOptions = parent != null ? [parent, ...subs] : subs;
          });
          return;
        }
      }
      final catalogue = _genderIndex != null
          ? await _categoryRepo.fetchCatalogueCategories(_genderIndex!)
          : const <PlpCategoryOption>[];
      if (mounted) setState(() => _categoryOptions = catalogue);
    } catch (_) {
      // Kateqoriya siyahısı olmadan da PLP işləyir.
    }
  }

  String? get _effectiveCategoryId {
    if (_filter.subcategoryIds.isNotEmpty) {
      return _filter.subcategoryIds.first;
    }
    return _categoryId;
  }

  String? get _effectiveSort =>
      PlpSortMapper.apiValueForIndex(_sortIndex, filterSort: _filter.apiSort);

  Future<void> _loadFirstPage() async {
    setState(() {
      _loading = true;
      _error = null;
      _lastRawPage = 1;
      _hasMore = true;
      _products = [];
    });

    try {
      final result = await _productRepo.fetchProducts(
        page: 1,
        categoryId: _effectiveCategoryId,
        categoryScope: _categoryScope,
        genderIndex: _genderIndex,
        search: widget.searchQuery,
        sort: _effectiveSort ?? 'newest',
        minPrice: _filter.minPrice,
        maxPrice: _filter.maxPrice,
      );

      if (!mounted) return;
      final processed = _applyClientProcessing(result.products);
      setState(() {
        _products = processed;
        _loadedCount = _products.length;
        _lastRawPage = result.rawPage;
        _hasMore = result.hasMore && processed.isNotEmpty;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : 'Məlumat yüklənmədi';
        _loading = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (!_isApiMode || _loadingMore || !_hasMore || _loading) return;

    setState(() => _loadingMore = true);
    final nextStartPage = _lastRawPage + 1;

    try {
      final result = await _productRepo.fetchProducts(
        page: nextStartPage,
        categoryId: _effectiveCategoryId,
        categoryScope: _categoryScope,
        genderIndex: _genderIndex,
        search: widget.searchQuery,
        sort: _effectiveSort ?? 'newest',
        minPrice: _filter.minPrice,
        maxPrice: _filter.maxPrice,
      );

      if (!mounted) return;
      final processed = _applyClientProcessing(result.products);
      setState(() {
        _lastRawPage = result.rawPage;
        _products = [..._products, ...processed];
        _loadedCount = _products.length;
        _hasMore = result.hasMore && processed.isNotEmpty;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 320) {
      _loadNextPage();
    }
  }

  List<TarzProductPreview> _applyClientProcessing(
    List<TarzProductPreview> list,
  ) {
    var result = List<TarzProductPreview>.from(list);

    if (_filter.discountsOnly) {
      result = result
          .where((p) => p.badgeLabel != null && p.badgeLabel!.isNotEmpty)
          .toList();
    }

    if (!_isApiMode || PlpSortMapper.needsClientProcessing(_sortIndex, _filter)) {
      switch (_sortIndex) {
        case 1:
          result = result.reversed.toList();
        case 2:
          result.sort(
            (a, b) => TarzPriceUtils.parseManat(a.priceLabel)
                .compareTo(TarzPriceUtils.parseManat(b.priceLabel)),
          );
        case 3:
          result.sort(
            (a, b) => TarzPriceUtils.parseManat(b.priceLabel)
                .compareTo(TarzPriceUtils.parseManat(a.priceLabel)),
          );
        case 4:
          result.sort((a, b) => a.id.compareTo(b.id));
        case 5:
          result = result
              .where((p) => p.badgeLabel != null && p.badgeLabel!.isNotEmpty)
              .toList();
        default:
          break;
      }
    }

    return result;
  }

  List<TarzProductPreview> get _displayProducts {
    if (_isApiMode) return _products;
    return _applyClientProcessing(List.from(widget.products));
  }

  String get _productCountLabel {
    final count = _isApiMode ? _loadedCount : (widget.totalCount ?? _displayProducts.length);
    return '$count məhsul';
  }

  void _toast(String message) => TarzFlashMessage.show(context, message);

  void _openProductDetails(TarzProductPreview product) {
    Navigator.of(context).pushNamed(
      AppRoutes.productDetails,
      arguments: ProductDetailsArgs(
        product: product,
        similarProducts: _displayProducts,
      ),
    );
  }

  Future<void> _openFilters() async {
    setState(() => _activeAction = PlpFilterAction.filters);
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.filter,
      arguments: FilterArgs(
        productCount: _loadedCount,
        initial: _filter,
        categories: _categoryOptions,
      ),
    );
    if (!mounted) return;
    setState(() => _activeAction = null);

    if (result is ProductFilterState) {
      setState(() => _filter = result);
      if (_isApiMode) {
        await _refreshCategoryScope();
        await _loadFirstPage();
      } else {
        setState(() {});
      }
    }
  }

  Future<void> _openSort() async {
    setState(() => _activeAction = PlpFilterAction.sort);
    final picked = await showPlpSortBottomSheet(
      context,
      selectedIndex: _sortIndex,
    );
    if (!mounted) return;
    if (picked != null && picked != _sortIndex) {
      setState(() => _sortIndex = picked);
      if (_isApiMode) {
        await _loadFirstPage();
      }
    }
    setState(
      () => _activeAction = _sortIndex == 0 ? null : PlpFilterAction.sort,
    );
  }

  Future<void> _openCategories() async {
    if (_categoryOptions.isEmpty) {
      _toast('Kateqoriyalar yüklənir...');
      await _loadCategoryOptions();
    }
    if (!mounted || _categoryOptions.isEmpty) return;

    setState(() => _activeAction = PlpFilterAction.categories);
    final selectedOption = _categoryOptions.cast<PlpCategoryOption?>().firstWhere(
          (c) => c!.id == _categoryId || c.name == _title,
          orElse: () => null,
        );

    final picked = await showPlpCategoryBottomSheet(
      context,
      categories: _categoryOptions,
      selected: selectedOption,
    );
    if (!mounted) return;

    if (picked != null) {
      if (picked.id == PlpSpecialCategory.discounts) {
        setState(() {
          _categoryId = null;
          _title = picked.name;
          _filter = _filter.copyWith(quickFilterIndex: 0, subcategoryIds: {});
        });
      } else if (picked.id == PlpSpecialCategory.brands) {
        setState(() {
          _categoryId = null;
          _title = picked.name;
          _filter = const ProductFilterState();
        });
      } else {
        setState(() {
          _categoryId = picked.id;
          _title = picked.name;
          _filter = _filter.copyWith(subcategoryIds: {});
        });
      }
      if (_isApiMode) {
        await _refreshCategoryScope();
        await _loadFirstPage();
        await _loadCategoryOptions();
      }
    }
    setState(
      () => _activeAction =
          _categoryId != null ? PlpFilterAction.categories : null,
    );
  }

  Future<void> _toggleFavorite(TarzProductPreview product) async {
    final added = await _wishlist.toggle(product);
    _toast(
      added
          ? 'Seçilmişlərə əlavə edildi'
          : 'Seçilmişlərdən silindi',
    );
  }

  void _showQuickActions(TarzProductPreview product) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  _wishlist.contains(product.id)
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: const Color(0xFFE53935),
                ),
                title: const Text('Favorilərə əlavə et'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleFavorite(product);
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('Sürətli baxış'),
                onTap: () {
                  Navigator.pop(context);
                  _openProductDetails(product);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _resetFilters() async {
    setState(() {
      _sortIndex = 0;
      _filter = const ProductFilterState();
      _categoryId = widget.categoryId;
      _title = widget.title;
      _activeAction = null;
    });
    if (_isApiMode) {
      await _refreshCategoryScope();
      await _loadFirstPage();
    }
    _toast('Filtrlər sıfırlandı');
  }

  Color? get _genderAccentColor => _genderIndex != null
      ? GenderSelector.colorForIndex(_genderIndex!)
      : null;

  @override
  Widget build(BuildContext context) {
    final products = _displayProducts;
    final showEmpty = !_loading && products.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: showEmpty
            ? Column(
                children: [
                  PlpHeader(
                    title: _title,
                    productCountLabel: _productCountLabel,
                    accentColor: _genderAccentColor,
                    onBack: () => Navigator.of(context).maybePop(),
                    onSearch: () =>
                        Navigator.of(context).pushNamed(AppRoutes.search),
                  ),
                  PlpFilterActionBar(
                    selected: _activeAction,
                    onFilters: _openFilters,
                    onSort: _openSort,
                    onCategories: _openCategories,
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Expanded(child: PlpEmptyState(onResetFilters: _resetFilters)),
                ],
              )
            : CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: PlpHeader(
                      title: _title,
                      productCountLabel: _productCountLabel,
                      accentColor: _genderAccentColor,
                      onBack: () => Navigator.of(context).maybePop(),
                      onSearch: () =>
                          Navigator.of(context).pushNamed(AppRoutes.search),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyFilterBarDelegate(
                      child: PlpFilterActionBar(
                        selected: _activeAction ??
                            (_sortIndex != 0 ? PlpFilterAction.sort : null) ??
                            (_filter.isEmpty ? null : PlpFilterAction.filters),
                        onFilters: _openFilters,
                        onSort: _openSort,
                        onCategories: _openCategories,
                      ),
                    ),
                  ),
                  if (_loading)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.48,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (_, __) => const PlpShimmerCard(),
                          childCount: 6,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.48,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = products[index];
                            return PlpProductCard(
                              product: product,
                              isFavorite: _wishlist.contains(product.id),
                              onTap: () => _openProductDetails(product),
                              onFavorite: () => _toggleFavorite(product),
                              onLongPress: () => _showQuickActions(product),
                            );
                          },
                          childCount: products.length,
                        ),
                      ),
                    ),
                  if (_loadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _StickyFilterBarDelegate extends SliverPersistentHeaderDelegate {
  _StickyFilterBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 66;

  @override
  double get maxExtent => 66;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyFilterBarDelegate oldDelegate) =>
      child != oldDelegate.child;
}

import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../cart/tarz_price_utils.dart';
import '../data/tarz_mock_catalog.dart';
import '../models/tarz_product_preview.dart';
import '../widgets/listing/plp_category_bottom_sheet.dart';
import '../widgets/listing/plp_empty_state.dart';
import '../widgets/listing/plp_filter_action_bar.dart';
import '../widgets/listing/plp_header.dart';
import '../widgets/listing/plp_product_card.dart';
import '../widgets/listing/plp_shimmer_card.dart';
import '../widgets/listing/plp_sort_bottom_sheet.dart';
import '../wishlist/tarz_wishlist_controller.dart';

/// Kateqoriya PLP — 2 sütunlu şəbəkə, yapışqan filtr paneli.
class TarzCategoryListingScreen extends StatefulWidget {
  const TarzCategoryListingScreen({
    super.key,
    required this.title,
    required this.products,
    this.totalCount,
    this.isLoading = false,
  });

  final String title;
  final List<TarzProductPreview> products;
  /// API-dən gələn ümumi məhsul sayı.
  final int? totalCount;
  final bool isLoading;

  @override
  State<TarzCategoryListingScreen> createState() =>
      _TarzCategoryListingScreenState();
}

class _TarzCategoryListingScreenState extends State<TarzCategoryListingScreen> {
  int _sortIndex = 0;
  String? _selectedCategory;
  final _wishlist = TarzWishlistController.instance;
  PlpFilterAction? _activeAction;

  @override
  void initState() {
    super.initState();
    _wishlist.addListener(_rebuild);
  }

  @override
  void dispose() {
    _wishlist.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  String get _productCountLabel {
    final count = widget.totalCount ?? widget.products.length;
    return '$count məhsul';
  }

  List<TarzProductPreview> get _displayProducts {
    var list = List<TarzProductPreview>.from(widget.products);
    switch (_sortIndex) {
      case 1:
        list = list.reversed.toList();
      case 2:
        list.sort(
          (a, b) => TarzPriceUtils.parseManat(a.priceLabel)
              .compareTo(TarzPriceUtils.parseManat(b.priceLabel)),
        );
      case 3:
        list.sort(
          (a, b) => TarzPriceUtils.parseManat(b.priceLabel)
              .compareTo(TarzPriceUtils.parseManat(a.priceLabel)),
        );
      case 4:
        list.sort((a, b) => a.id.compareTo(b.id));
      case 5:
        list = list
            .where((p) => p.badgeLabel != null && p.badgeLabel!.isNotEmpty)
            .toList();
      default:
        break;
    }
    return list;
  }

  void _toast(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  void _openProductDetails(TarzProductPreview product) {
    Navigator.of(context).pushNamed(
      AppRoutes.productDetails,
      arguments: ProductDetailsArgs(
        product: product,
        similarProducts: widget.products,
      ),
    );
  }

  Future<void> _openFilters() async {
    setState(() => _activeAction = PlpFilterAction.filters);
    await Navigator.of(context).pushNamed(
      AppRoutes.filter,
      arguments: widget.totalCount ?? widget.products.length,
    );
    if (mounted) setState(() => _activeAction = null);
  }

  Future<void> _openSort() async {
    setState(() => _activeAction = PlpFilterAction.sort);
    final picked = await showPlpSortBottomSheet(
      context,
      selectedIndex: _sortIndex,
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() => _sortIndex = picked);
    }
    setState(() => _activeAction = _sortIndex == 0 ? null : PlpFilterAction.sort);
  }

  Future<void> _openCategories() async {
    setState(() => _activeAction = PlpFilterAction.categories);
    final picked = await showPlpCategoryBottomSheet(
      context,
      categories: TarzMockCatalog.catalogueCategories,
      selected: _selectedCategory ?? widget.title,
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() => _selectedCategory = picked);
      _toast('Kateqoriya: $picked');
    }
    setState(
      () => _activeAction =
          _selectedCategory != null ? PlpFilterAction.categories : null,
    );
  }

  void _toggleFavorite(TarzProductPreview product) {
    _wishlist.toggle(product);
    _toast(
      _wishlist.contains(product.id)
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

  void _resetFilters() {
    setState(() {
      _sortIndex = 0;
      _selectedCategory = null;
      _activeAction = null;
    });
    _toast('Filtrlər sıfırlandı');
  }

  @override
  Widget build(BuildContext context) {
    final products = _displayProducts;
    final showEmpty = !widget.isLoading && products.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: showEmpty
            ? Column(
                children: [
                  PlpHeader(
                    title: widget.title,
                    productCountLabel: _productCountLabel,
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
                  Expanded(child: PlpEmptyState(onResetFilters: _resetFilters)),
                ],
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: PlpHeader(
                      title: widget.title,
                      productCountLabel: _productCountLabel,
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
                            (_sortIndex != 0 ? PlpFilterAction.sort : null),
                        onFilters: _openFilters,
                        onSort: _openSort,
                        onCategories: _openCategories,
                      ),
                    ),
                  ),
                  if (widget.isLoading)
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
  double get minExtent => 62;

  @override
  double get maxExtent => 62;

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

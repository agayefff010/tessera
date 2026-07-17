import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import '../../cart/tarz_price_utils.dart';
import '../../data/category_repository.dart';
import '../../data/plp_sort_mapper.dart';
import '../../data/product_repository.dart';
import '../../data/tarz_mock_catalog.dart';
import '../../models/plp_category_option.dart';
import '../../models/product_filter_state.dart';
import '../../models/tarz_children_catalogue_block.dart';
import '../../models/tarz_product_preview.dart';
import '../../../services/api_exception.dart';
import '../catalogue/children_catalogue_section.dart';
import '../catalogue/gender_selector.dart';
import '../listing/plp_product_card.dart';
import '../listing/plp_shimmer_card.dart';
import '../listing/plp_sort_bottom_sheet.dart';
import '../tarz_flash_message.dart';
import '../../wishlist/tarz_wishlist_controller.dart';

/// Ana səhifədə cins seçildikdə aşağıda göstərilən inline listing.
class HomeGenderListingSection extends StatefulWidget {
  const HomeGenderListingSection({
    super.key,
    required this.genderIndex,
    required this.onBack,
    required this.onProductTap,
    required this.onCategoryTap,
  });

  final int genderIndex;
  final VoidCallback onBack;
  final ValueChanged<TarzProductPreview> onProductTap;
  final ValueChanged<PlpCategoryOption> onCategoryTap;

  static const int kidsGenderIndex = 2;

  @override
  State<HomeGenderListingSection> createState() =>
      _HomeGenderListingSectionState();
}

class _HomeGenderListingSectionState extends State<HomeGenderListingSection> {
  final _productRepo = ProductRepository();
  final _categoryRepo = CategoryRepository.instance;
  final _wishlist = TarzWishlistController.instance;
  final _scrollController = ScrollController();

  ProductFilterState _filter = const ProductFilterState();
  int _sortIndex = 0;

  List<TarzProductPreview> _products = [];
  List<TarzChildrenCatalogueBlock> _kidsBlocks = const [];
  List<PlpCategoryOption> _categoryOptions = [];

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _lastRawPage = 1;

  bool get _isKids => widget.genderIndex == HomeGenderListingSection.kidsGenderIndex;

  String get _title => TarzMockCatalog.categories[widget.genderIndex];

  Color get _accentColor => GenderSelector.colorForIndex(widget.genderIndex);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _bootstrap();
  }

  @override
  void didUpdateWidget(HomeGenderListingSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.genderIndex != widget.genderIndex) {
      _bootstrap();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _productRepo.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
      _products = [];
      _kidsBlocks = const [];
      _filter = const ProductFilterState();
      _sortIndex = 0;
      _lastRawPage = 1;
      _hasMore = true;
    });

    if (_isKids) {
      await _loadKidsBlocks();
      return;
    }

    await Future.wait([
      _loadCategoryOptions(),
      _loadFirstPage(),
    ]);
  }

  Future<void> _loadKidsBlocks() async {
    try {
      final blocks = await _categoryRepo.fetchKidsCatalogueBlocks();
      if (!mounted) return;
      setState(() {
        _kidsBlocks = blocks;
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

  Future<void> _loadCategoryOptions() async {
    try {
      final cats =
          await _categoryRepo.fetchCatalogueCategories(widget.genderIndex);
      if (mounted) setState(() => _categoryOptions = cats);
    } catch (_) {
      // Kateqoriya siyahısı olmadan da listing işləyir.
    }
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
        genderIndex: widget.genderIndex,
        sort: _effectiveSort ?? 'newest',
        minPrice: _filter.minPrice,
        maxPrice: _filter.maxPrice,
      );

      if (!mounted) return;
      final processed = _applyClientProcessing(result.products);
      setState(() {
        _products = processed;
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
    if (_loadingMore || !_hasMore || _loading) return;

    setState(() => _loadingMore = true);
    final nextPage = _lastRawPage + 1;

    try {
      final result = await _productRepo.fetchProducts(
        page: nextPage,
        genderIndex: widget.genderIndex,
        sort: _effectiveSort ?? 'newest',
        minPrice: _filter.minPrice,
        maxPrice: _filter.maxPrice,
      );

      if (!mounted) return;
      final processed = _applyClientProcessing(result.products);
      setState(() {
        _lastRawPage = result.rawPage;
        _products = [..._products, ...processed];
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

    if (PlpSortMapper.needsClientProcessing(_sortIndex, _filter)) {
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

  Future<void> _openFilters() async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.filter,
      arguments: FilterArgs(
        productCount: _products.length,
        initial: _filter,
        categories: _categoryOptions,
      ),
    );
    if (!mounted) return;
    if (result is ProductFilterState) {
      setState(() => _filter = result);
      await _loadFirstPage();
    }
  }

  Future<void> _openSort() async {
    final picked = await showPlpSortBottomSheet(
      context,
      selectedIndex: _sortIndex,
    );
    if (!mounted || picked == null || picked == _sortIndex) return;
    setState(() => _sortIndex = picked);
    await _loadFirstPage();
  }

  Future<void> _toggleFavorite(TarzProductPreview product) async {
    final added = await _wishlist.toggle(product);
    if (!mounted) return;
    TarzFlashMessage.show(
      context,
      added ? 'Seçilmişlərə əlavə edildi' : 'Seçilmişlərdən silindi',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFAFAFA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InlineListingHeader(
            title: _title,
            accentColor: _accentColor,
            onBack: widget.onBack,
          ),
          _InlineListingToolbar(
            onSort: _openSort,
            onFilters: _openFilters,
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
          Expanded(
            child: _isKids ? _buildKidsBody() : _buildProductsBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildKidsBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_kidsBlocks.isEmpty) {
      return const Center(child: Text('Kateqoriya tapılmadı'));
    }

    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ChildrenCatalogueSection(
          blocks: _kidsBlocks,
          onBlockTap: widget.onCategoryTap,
          onSubcategoryTap: widget.onCategoryTap,
        ),
      ],
    );
  }

  Widget _buildProductsBody() {
    if (_loading) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.48,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => const PlpShimmerCard(),
      );
    }

    if (_products.isEmpty) {
      return const Center(child: Text('Məhsul tapılmadı'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.48,
      ),
      itemCount: _products.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _products.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final product = _products[index];
        return PlpProductCard(
          product: product,
          onTap: () => widget.onProductTap(product),
          onFavorite: () => _toggleFavorite(product),
        );
      },
    );
  }
}

class _InlineListingHeader extends StatelessWidget {
  const _InlineListingHeader({
    required this.title,
    required this.accentColor,
    required this.onBack,
  });

  final String title;
  final Color accentColor;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              style: IconButton.styleFrom(foregroundColor: accentColor),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineListingToolbar extends StatelessWidget {
  const _InlineListingToolbar({
    required this.onSort,
    required this.onFilters,
  });

  final VoidCallback onSort;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: _ToolbarButton(
                label: 'Çeşidləmə',
                icon: Icons.keyboard_arrow_down_rounded,
                onTap: onSort,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ToolbarButton(
                label: 'Filtrlər',
                icon: Icons.tune_rounded,
                onTap: onFilters,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

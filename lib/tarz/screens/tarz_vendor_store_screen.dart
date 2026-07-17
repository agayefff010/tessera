import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/api_exception.dart';
import '../data/plp_sort_mapper.dart';
import '../data/product_repository.dart';
import '../data/tarz_mock_catalog.dart';
import '../data/vendor_repository.dart';
import '../models/tarz_product_preview.dart';
import '../models/tarz_vendor.dart';
import '../theme/tarz_colors.dart';
import '../utils/tarz_image_cache.dart';
import '../widgets/listing/plp_product_card.dart';
import '../widgets/listing/plp_sort_bottom_sheet.dart';
import '../widgets/tarz_flash_message.dart';
import '../wishlist/tarz_wishlist_controller.dart';

/// Mağaza səhifəsi — cover, ortaya yaxın loqo, tabs, məhsul grid.
class TarzVendorStoreScreen extends StatefulWidget {
  const TarzVendorStoreScreen({
    super.key,
    required this.slug,
    this.initialName,
  });

  final String slug;
  final String? initialName;

  @override
  State<TarzVendorStoreScreen> createState() => _TarzVendorStoreScreenState();
}

class _TarzVendorStoreScreenState extends State<TarzVendorStoreScreen> {
  final _vendorRepo = VendorRepository();
  final _productRepo = ProductRepository();
  final _wishlist = TarzWishlistController.instance;
  final _scrollController = ScrollController();

  TarzVendor? _vendor;
  List<TarzProductPreview> _products = const [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  int? _totalCount;
  int _tabIndex = 0;
  int _sortIndex = 0;
  String? _error;

  static const double _coverHeight = 168;
  static const double _avatarSize = 88;
  static const double _avatarOverlap = 36;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _vendorRepo.dispose();
    _productRepo.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_tabIndex != 0) return;
    if (!_hasMore || _loadingMore || _loading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 360) {
      _loadMore();
    }
  }

  String? get _apiSort =>
      PlpSortMapper.apiValueForIndex(_sortIndex) ?? 'newest';

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final vendor = await _vendorRepo.fetchBySlug(widget.slug);
      final products = await _productRepo.fetchProducts(
        page: 1,
        vendorId: vendor.id,
        filterByGender: false,
        sort: _apiSort,
      );
      if (!mounted) return;
      setState(() {
        _vendor = vendor;
        _products = products.products;
        _totalCount = products.totalCount;
        _page = 1;
        _hasMore = products.hasMore;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Mağaza yüklənmədi';
        _loading = false;
      });
    }
  }

  Future<void> _reloadProducts() async {
    final vendor = _vendor;
    if (vendor == null) return;
    try {
      final products = await _productRepo.fetchProducts(
        page: 1,
        vendorId: vendor.id,
        filterByGender: false,
        sort: _apiSort,
      );
      if (!mounted) return;
      setState(() {
        _products = products.products;
        _totalCount = products.totalCount ?? products.products.length;
        _page = 1;
        _hasMore = products.hasMore;
      });
    } catch (_) {
      if (!mounted) return;
      TarzFlashMessage.show(context, 'Məhsullar yenilənmədi');
    }
  }

  Future<void> _loadMore() async {
    final vendor = _vendor;
    if (vendor == null || _loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final next = _page + 1;
      final result = await _productRepo.fetchProducts(
        page: next,
        vendorId: vendor.id,
        filterByGender: false,
        sort: _apiSort,
      );
      if (!mounted) return;
      setState(() {
        _products = [..._products, ...result.products];
        _page = next;
        _hasMore = result.hasMore;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  Future<void> _openSort() async {
    final selected = await showPlpSortBottomSheet(
      context,
      selectedIndex: _sortIndex,
    );
    if (selected == null || selected == _sortIndex || !mounted) return;
    setState(() => _sortIndex = selected);
    await _reloadProducts();
  }

  void _openProduct(TarzProductPreview product) {
    Navigator.of(context).pushNamed(
      AppRoutes.productDetails,
      arguments: ProductDetailsArgs(
        product: product,
        similarProducts: TarzMockCatalog.homeNewProductsGrid(),
      ),
    );
  }

  Future<void> _toggleWishlist(TarzProductPreview product) async {
    final added = await _wishlist.toggle(product);
    if (!mounted) return;
    TarzFlashMessage.show(
      context,
      added
          ? '${product.title} — seçilmişlərə əlavə edildi'
          : '${product.title} — seçilmişlərdən silindi',
    );
  }

  int get _displayCount => _totalCount ?? _products.length;

  String get _sortLabel {
    final options = PlpSortOption.options;
    if (_sortIndex < 0 || _sortIndex >= options.length) return 'Ən son';
    final label = options[_sortIndex];
    if (label.startsWith('Ən yenilər')) return 'Ən son';
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          : _error != null
              ? _ErrorBody(message: _error!, onRetry: _load)
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final vendor = _vendor!;
    final topPad = MediaQuery.paddingOf(context).top;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: _StoreHero(
            vendor: vendor,
            topPadding: topPad,
            coverHeight: _coverHeight,
            avatarSize: _avatarSize,
            avatarOverlap: _avatarOverlap,
            productCount: _displayCount,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabsHeaderDelegate(
            tabIndex: _tabIndex,
            productCount: _displayCount,
            onTabChanged: (i) => setState(() => _tabIndex = i),
          ),
        ),
        if (_tabIndex == 0) ..._productSlivers() else _aboutSliver(vendor),
      ],
    );
  }

  List<Widget> _productSlivers() {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$_displayCount məhsul tapıldı',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ),
              Material(
                color: Colors.white,
                shape: StadiumBorder(
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: InkWell(
                  onTap: _openSort,
                  customBorder: const StadiumBorder(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _sortLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: TarzColors.ink,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      if (_products.isEmpty)
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              'Bu mağazada məhsul yoxdur',
              style: TextStyle(color: TarzColors.inkMuted),
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              childAspectRatio: 0.48,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = _products[index];
                return PlpProductCard(
                  product: product,
                  onTap: () => _openProduct(product),
                  onFavorite: () => _toggleWishlist(product),
                );
              },
              childCount: _products.length,
            ),
          ),
        ),
      if (_loadingMore)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ),
    ];
  }

  Widget _aboutSliver(TarzVendor vendor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: _AboutTab(vendor: vendor),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: TarzColors.inkMuted),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Yenilə')),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreHero extends StatelessWidget {
  const _StoreHero({
    required this.vendor,
    required this.topPadding,
    required this.coverHeight,
    required this.avatarSize,
    required this.avatarOverlap,
    required this.productCount,
    required this.onBack,
  });

  final TarzVendor vendor;
  final double topPadding;
  final double coverHeight;
  final double avatarSize;
  final double avatarOverlap;
  final int productCount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final address = vendor.address?.trim();
    final hours = vendor.openHours?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: topPadding + coverHeight + avatarOverlap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topPadding + coverHeight,
                child: _CoverBanner(
                  imageUrl: vendor.profileImageUrl,
                  topPadding: topPadding,
                  onBack: onBack,
                ),
              ),
              // Loqo bannerin altında, horizontal olaraq ortada.
              Positioned(
                left: (MediaQuery.sizeOf(context).width - avatarSize) / 2,
                top: topPadding + coverHeight - avatarOverlap,
                child: _StoreAvatar(
                  url: vendor.profileImageUrl,
                  name: vendor.name,
                  size: avatarSize,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      vendor.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: TarzColors.ink,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const _VerifiedBadge(),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 8,
                children: [
                  _MetaChip(
                    icon: Icons.inventory_2_outlined,
                    text: '$productCount məhsul',
                  ),
                  if (address != null && address.isNotEmpty)
                    _MetaChip(
                      icon: Icons.location_on_outlined,
                      text: address,
                    ),
                  if (hours != null && hours.isNotEmpty)
                    _MetaChip(
                      icon: Icons.access_time_rounded,
                      text: hours,
                    ),
                ],
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverBanner extends StatelessWidget {
  const _CoverBanner({
    required this.imageUrl,
    required this.topPadding,
    required this.onBack,
  });

  final String? imageUrl;
  final double topPadding;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD8D8D8), Color(0xFFBDBDBD)],
            ),
          ),
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? Opacity(
                  opacity: 0.35,
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const Center(
          child: Icon(
            Icons.storefront_outlined,
            size: 72,
            color: Color(0x66FFFFFF),
          ),
        ),
        Positioned(
          top: topPadding + 4,
          left: 4,
          child: Material(
            color: Colors.white.withValues(alpha: 0.9),
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreAvatar extends StatelessWidget {
  const _StoreAvatar({
    required this.url,
    required this.name,
    required this.size,
  });

  final String? url;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: url != null && url!.isNotEmpty
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                cacheWidth: TarzImageCache.px(context, size),
                cacheHeight: TarzImageCache.px(context, size),
                errorBuilder: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return ColoredBox(
      color: const Color(0xFFF0F0EE),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'M',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: TarzColors.inkMuted,
          ),
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: TarzColors.ink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'TƏSDİQLƏNMİŞ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF9E9E9E)),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.42,
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ),
      ],
    );
  }
}

class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabsHeaderDelegate({
    required this.tabIndex,
    required this.productCount,
    required this.onTabChanged,
  });

  final int tabIndex;
  final int productCount;
  final ValueChanged<int> onTabChanged;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _TabItem(
                    label: 'Məhsullar ($productCount)',
                    selected: tabIndex == 0,
                    onTap: () => onTabChanged(0),
                  ),
                ),
                Expanded(
                  child: _TabItem(
                    label: 'Haqqında',
                    selected: tabIndex == 1,
                    onTap: () => onTabChanged(1),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: const Color(0xFFE8E8E8)),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabsHeaderDelegate oldDelegate) {
    return tabIndex != oldDelegate.tabIndex ||
        productCount != oldDelegate.productCount;
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? TarzColors.ink : const Color(0xFF9E9E9E),
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 2.5,
            width: selected ? 72 : 0,
            decoration: BoxDecoration(
              color: selected ? TarzColors.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.vendor});

  final TarzVendor vendor;

  @override
  Widget build(BuildContext context) {
    final description = vendor.description?.trim();
    final phone = vendor.phone?.trim();
    final address = vendor.address?.trim();
    final hours = vendor.openHours?.trim();
    final stores = vendor.storeAddresses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (description != null && description.isNotEmpty) ...[
          const Text(
            'Haqqında',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: TarzColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: TarzColors.ink,
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (hours != null && hours.isNotEmpty)
          _AboutRow(icon: Icons.access_time_rounded, text: hours),
        if (phone != null && phone.isNotEmpty)
          _AboutRow(icon: Icons.phone_outlined, text: phone),
        if (address != null && address.isNotEmpty)
          _AboutRow(icon: Icons.location_on_outlined, text: address),
        if (stores.isNotEmpty)
          _AboutRow(
            icon: Icons.storefront_outlined,
            text: stores.map((e) => '• $e').join('\n'),
          ),
        if (vendor.deliveryAvailable != null) ...[
          const SizedBox(height: 4),
          _AboutRow(
            icon: vendor.deliveryAvailable!
                ? Icons.local_shipping_outlined
                : Icons.store_mall_directory_outlined,
            text: vendor.deliveryAvailable!
                ? 'Çatdırılma mövcuddur'
                : 'Yalnız mağazadan götürmə',
          ),
        ],
      ],
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: TarzColors.inkMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: TarzColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

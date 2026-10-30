import 'package:flutter/material.dart';

import '../bootstrap/app_bootstrap.dart';
import '../routes/app_routes.dart';
import '../services/api_exception.dart';
import 'data/home_repository.dart';

import 'models/plp_category_option.dart';
import 'models/product_filter_state.dart';
import 'models/tarz_home_banner.dart';
import 'models/tarz_product_preview.dart';
import 'models/tarz_store_preview.dart';
import 'theme/tarz_breakpoints.dart';
import 'theme/tarz_colors.dart';
import 'widgets/home/ai_outfit_banner.dart';
import 'widgets/home/brand_banner_section.dart';
import 'widgets/home/category_grid_section.dart';
import 'widgets/home/home_gender_listing_section.dart';
import 'widgets/home/gender_segmented_tabs.dart';
import 'widgets/home/hero_collage_banner.dart';
import 'widgets/home/home_promo_banners_section.dart';
import 'widgets/home/home_search_header.dart';
import 'widgets/home/new_products_section.dart';
import 'widgets/home/store_chips_section.dart';
import 'screens/tarz_catalogue_screen.dart';
import 'screens/tarz_outfits_screen.dart';
import 'screens/tarz_profile_screen.dart';
import 'screens/tarz_wishlist_screen.dart';
import 'wishlist/tarz_wishlist_controller.dart';
import 'widgets/tarz_bottom_navigation.dart';
import 'widgets/tarz_flash_message.dart';
import 'widgets/tarz_home_drawer.dart';


class TarzHomeScreen extends StatefulWidget {
  const TarzHomeScreen({super.key, this.initialNavIndex});

  final int? initialNavIndex;

  @override
  State<TarzHomeScreen> createState() => _TarzHomeScreenState();
}

class _TarzHomeScreenState extends State<TarzHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final HomeRepository _homeRepo = HomeRepository();

  int? _homeGenderIndex;
  int _categoryIndex = 0;
  int _catalogueCategoryIndex = 0;
  late int _navIndex;

  /// Lazy-created tabs stay in [IndexedStack] so revisiting does not remount.
  final Set<int> _mountedTabs = <int>{};

  bool _homeLoading = true;
  String? _homeError;
  List<TarzHomeBanner> _homeBanners = const [];
  List<TarzHomeBanner> _sideTopBanners = const [];
  List<TarzHomeBanner> _sideBottomBanners = const [];
  List<TarzProductPreview> _newProducts = const [];
  List<TarzProductPreview> _discountProducts = const [];
  List<HomeCategoryItem> _homeCategories = CategoryGridSection.mockCategories();
  List<TarzStorePreview> _stores = StoreChipsSection.mockStores();

  @override
  void initState() {
    super.initState();
    _navIndex = widget.initialNavIndex ?? 2;
    _mountedTabs.add(_navIndex);
    _loadHomeData();
  }

  @override
  void dispose() {
    _homeRepo.dispose();
    super.dispose();
  }

  Future<void> _loadHomeData({bool forceRefresh = false}) async {
    setState(() {
      _homeLoading = true;
      _homeError = null;
    });

    if (!forceRefresh) {
      await AppBootstrap.instance.ready;
      final cached = AppBootstrap.instance.homeSnapshot;
      if (cached != null && mounted) {
        _applyHomeSnapshot(cached);
        return;
      }
    }

    try {
      final snapshot = await _homeRepo.loadBootstrapSnapshot();
      if (!mounted) return;
      AppBootstrap.instance.cacheHomeSnapshot(snapshot);
      _applyHomeSnapshot(snapshot);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _homeError = e is ApiException ? e.message : 'Məlumat yüklənmədi';
        _homeLoading = false;
      });
    }
  }

  void _applyHomeSnapshot(HomeBootstrapSnapshot snapshot) {
    setState(() {
      _homeBanners = snapshot.advertisements.mainBanner;
      _sideTopBanners = snapshot.advertisements.sideTop;
      _sideBottomBanners = snapshot.advertisements.sideBottom;
      _newProducts = snapshot.productGrids.newProducts;
      _discountProducts = snapshot.productGrids.discountProducts;
      _homeCategories = snapshot.categories;
      _stores = snapshot.stores;
      _homeLoading = false;
      _homeError = snapshot.error;
    });
  }

  void _onHomeGenderSelected(int index) {
    setState(() {
      _homeGenderIndex = _homeGenderIndex == index ? null : index;
    });
  }

  void _closeHomeGenderListing() {
    setState(() => _homeGenderIndex = null);
  }

  void _onCatalogueGenderChanged(int index) {
    if (index == _categoryIndex) return;
    setState(() => _categoryIndex = index);
  }

  Future<void> _openYenilerListing() async {
    Navigator.of(context).pushNamed(
      AppRoutes.productListing,
      arguments: const ProductListingArgs(
        title: 'Yenilər',
        initialFilter: ProductFilterState(quickFilterIndex: 1),
      ),
    );
  }

  Future<void> _openDiscountListing() async {
    Navigator.of(context).pushNamed(
      AppRoutes.productListing,
      arguments: const ProductListingArgs(
        title: 'Endirimlər',
        initialFilter: ProductFilterState(quickFilterIndex: 0),
      ),
    );
  }

  void _toast(String message) => TarzFlashMessage.show(context, message);

  void _openSearch() => Navigator.of(context).pushNamed(AppRoutes.search);

  void _openCart() => Navigator.of(context).pushNamed(AppRoutes.cart);

  void _openNotifications() =>
      Navigator.of(context).pushNamed(AppRoutes.notifications);

  void _openProductDetails(TarzProductPreview product) {
    Navigator.of(context).pushNamed(
      AppRoutes.productDetails,
      arguments: ProductDetailsArgs(
        product: product,
      ),
    );
  }

  void _openVendorStore(TarzStorePreview store) {
    final slug = store.slug?.trim();
    if (slug == null || slug.isEmpty) {
      _toast('${store.name} — mağaza səhifəsi hazır deyil');
      return;
    }
    Navigator.of(context).pushNamed(
      AppRoutes.vendorStore,
      arguments: VendorStoreArgs(slug: slug, name: store.name),
    );
  }

  void _openVendorStoreFromBanner(TarzHomeBanner banner) {
    final slug = banner.vendorSlug?.trim();
    if (slug == null || slug.isEmpty) return;
    Navigator.of(context).pushNamed(
      AppRoutes.vendorStore,
      arguments: VendorStoreArgs(slug: slug, name: banner.title),
    );
  }

  void _openProductListingApi({
    required String title,
    String? categoryId,
    int? genderIndex,
    ProductFilterState? initialFilter,
  }) {
    Navigator.of(context).pushNamed(
      AppRoutes.productListing,
      arguments: ProductListingArgs(
        title: title,
        categoryId: categoryId,
        genderIndex: genderIndex,
        initialFilter: initialFilter,
      ),
    );
  }

  void _openCatalogueCategory(PlpCategoryOption category) {
    if (category.id == PlpSpecialCategory.discounts) {
      _openProductListingApi(
        title: category.name,
        initialFilter: const ProductFilterState(quickFilterIndex: 0),
      );
      return;
    }
    if (category.id == PlpSpecialCategory.brands) {
      _openProductListingApi(
        title: category.name,
        categoryId: PlpSpecialCategory.brands,
      );
      return;
    }

    _openProductListingApi(
      title: category.name,
      categoryId: category.id,
    );
  }

  Future<void> _openHomeCategory(HomeCategoryItem item) async {
    const genderIndex = 0;
    var categoryId = item.categoryId;

    if (categoryId == null || categoryId.isEmpty) {
      categoryId = await _homeRepo.resolveHomeCategoryId(
        item.label,
        genderIndex: genderIndex,
      );
    }

    if (!mounted) return;

    _openProductListingApi(
      title: item.label,
      categoryId: categoryId,
      genderIndex: genderIndex,
    );
  }

  void _onNavChanged(int index) {
    setState(() {
      _navIndex = index;
      _mountedTabs.add(index);
    });
  }

  Widget _buildNavBody(List<TarzProductPreview> newProducts) {
    return IndexedStack(
      index: _navIndex,
      sizing: StackFit.expand,
      children: [
        _mountedTabs.contains(0)
            ? TarzCatalogueScreen(
                key: const PageStorageKey<String>('tarz_tab_catalogue'),
                genderIndex: _categoryIndex,
                selectedCategoryIndex: _catalogueCategoryIndex,
                onGenderChanged: _onCatalogueGenderChanged,
                onCategoryIndexChanged: (i) =>
                    setState(() => _catalogueCategoryIndex = i),
                onSearchTap: _openSearch,
                onCartTap: _openCart,
                onCategoryTap: _openCatalogueCategory,
              )
            : const SizedBox.shrink(),
        _mountedTabs.contains(1)
            ? const TarzOutfitsScreen(
                key: PageStorageKey<String>('tarz_tab_outfits'),
              )
            : const SizedBox.shrink(),
        KeyedSubtree(
          key: const PageStorageKey<String>('tarz_tab_home'),
          child: _buildHomeBody(newProducts),
        ),
        _mountedTabs.contains(3)
            ? TarzWishlistScreen(
                key: const PageStorageKey<String>('tarz_tab_wishlist'),
                onProductTap: _openProductDetails,
              )
            : const SizedBox.shrink(),
        _mountedTabs.contains(4)
            ? TarzProfileScreen(
                key: const PageStorageKey<String>('tarz_tab_profile'),
                onWishlistTap: () => _onNavChanged(3),
                onOutfitsTap: () => _onNavChanged(1),
                onNotificationsTap: _openNotifications,
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] TarzHomeScreen');
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: TarzHomeDrawer(
        selectedGenderIndex: _categoryIndex,
        onGenderSelected: _onCatalogueGenderChanged,
        onCategoryTap: _openCatalogueCategory,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildNavBody(_newProducts)),
            TarzBottomNavigation(
              currentIndex: _navIndex,
              onChanged: _onNavChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeBody(List<TarzProductPreview> newProducts) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = TarzBreakpoints.contentMaxWidth(constraints.maxWidth);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Column(
              children: [
                ColoredBox(
                  color: Colors.white,
                  child: Column(
                    children: [
                      HomeSearchHeader(
                        onSearchTap: _openSearch,
                        onNotificationTap: _openNotifications,
                        onCartTap: _openCart,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GenderSegmentedTabs(
                          labels: const ['Qadın', 'Kişi', 'Uşaq'],
                          selectedIndex: _homeGenderIndex,
                          onSelected: _onHomeGenderSelected,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _homeGenderIndex != null
                      ? HomeGenderListingSection(
                          key: ValueKey(_homeGenderIndex),
                          genderIndex: _homeGenderIndex!,
                          onBack: _closeHomeGenderListing,
                          onProductTap: _openProductDetails,
                          onCategoryTap: _openCatalogueCategory,
                        )
                      : RefreshIndicator(
                          onRefresh: () => _loadHomeData(forceRefresh: true),
                          child: CustomScrollView(
                            key: const PageStorageKey<String>('tarz_home_scroll'),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            slivers: [
                              if (_homeLoading)
                                const SliverToBoxAdapter(
                                  child:
                                      LinearProgressIndicator(minHeight: 2),
                                ),
                              if (_homeError != null)
                                SliverToBoxAdapter(
                                  child: Material(
                                    color: TarzColors.surface,
                                    child: ListTile(
                                      leading:
                                          const Icon(Icons.cloud_off_outlined),
                                      title: Text(
                                        _homeError!,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      trailing: TextButton(
                                        onPressed: () =>
                                            _loadHomeData(forceRefresh: true),
                                        child: const Text('Yenilə'),
                                      ),
                                    ),
                                  ),
                                ),
                              SliverToBoxAdapter(
                                child: HeroCollageBanner(
                                  banners: _homeBanners,
                                  loading: _homeLoading,
                                  onBannerTap: _openVendorStoreFromBanner,
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: HomePromoBannersSection(
                                  sideTop: _sideTopBanners,
                                  sideBottom: _sideBottomBanners,
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: NewProductsSection(
                                  newProducts: newProducts,
                                  discountProducts: _discountProducts,
                                  onSeeAll: _openYenilerListing,
                                  onDiscountSeeAll: _openDiscountListing,
                                  onProductTap: _openProductDetails,
                                  onWishlist: (p) async {
                                    final added =
                                        await TarzWishlistController.instance
                                            .toggle(p);
                                    _toast(
                                      added
                                          ? '${p.title} — seçilmişlərə əlavə edildi'
                                          : '${p.title} — seçilmişlərdən silindi',
                                    );
                                  },
                                  isFavorite: (p) => TarzWishlistController
                                      .instance
                                      .contains(p.id),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: AiOutfitBanner(
                                  onCreateOutfit: () {
                                    Navigator.of(context).pushNamed(
                                      AppRoutes.aiOutfitGenerate,
                                    );
                                  },
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: CategoryGridSection(
                                  categories: _homeCategories,
                                  onCategoryTap: _openHomeCategory,
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: BrandBannerSection(
                                  onBannerTap: () => _toast('Brendlər'),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: StoreChipsSection(
                                  stores: _stores,
                                  onStoreTap: _openVendorStore,
                                ),
                              ),
                              const SliverToBoxAdapter(
                                  child: SizedBox(height: 8)),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

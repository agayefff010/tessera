import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import 'data/tarz_mock_catalog.dart';
import 'models/tarz_product_preview.dart';
import 'theme/tarz_breakpoints.dart';
import 'widgets/home/ai_outfit_banner.dart';
import 'widgets/home/brand_banner_section.dart';
import 'widgets/home/category_grid_section.dart';
import 'widgets/home/gender_segmented_tabs.dart';
import 'widgets/home/hero_collage_banner.dart';
import 'widgets/home/home_search_header.dart';
import 'widgets/home/new_products_section.dart';
import 'widgets/home/store_chips_section.dart';
import 'screens/tarz_catalogue_screen.dart';
import 'screens/tarz_outfits_screen.dart';
import 'screens/tarz_profile_screen.dart';
import 'screens/tarz_wishlist_screen.dart';
import 'wishlist/tarz_wishlist_controller.dart';
import 'widgets/tarz_bottom_navigation.dart';
import 'widgets/tarz_home_drawer.dart';

/// Tessera əsas (Main) ekran — skrinşot dizaynına uyğun.
class TarzHomeScreen extends StatefulWidget {
  const TarzHomeScreen({super.key, this.initialNavIndex});

  final int? initialNavIndex;

  @override
  State<TarzHomeScreen> createState() => _TarzHomeScreenState();
}

class _TarzHomeScreenState extends State<TarzHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _categoryIndex = 0;
  int _catalogueCategoryIndex = 0;
  late int _navIndex;

  @override
  void initState() {
    super.initState();
    _navIndex = widget.initialNavIndex ?? 2;
  }

  void _toast(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  void _openSearch() => Navigator.of(context).pushNamed(AppRoutes.search);

  void _openCart() => Navigator.of(context).pushNamed(AppRoutes.cart);

  void _openNotifications() =>
      Navigator.of(context).pushNamed(AppRoutes.notifications);

  void _openProductDetails(TarzProductPreview product) {
    Navigator.of(context).pushNamed(
      AppRoutes.productDetails,
      arguments: ProductDetailsArgs(
        product: product,
        similarProducts: TarzMockCatalog.homeNewProductsGrid(),
      ),
    );
  }

  void _openProductListing(String title, List<TarzProductPreview> products) {
    Navigator.of(context).pushNamed(
      AppRoutes.productListing,
      arguments: ProductListingArgs(title: title, products: products),
    );
  }

  void _openCatalogueCategory(String title) {
    final products = switch (title) {
      'Endirimlər' => TarzMockCatalog.endirimListingDemo(),
      'Brendlər' => TarzMockCatalog.homeTrendler(),
      _ => TarzMockCatalog.trendListingDemo(),
    };
    _openProductListing(title, products);
  }

  void _onNavChanged(int index) {
    setState(() => _navIndex = index);
  }

  Widget _buildNavBody(List<TarzProductPreview> newProducts) {
    switch (_navIndex) {
      case 0:
        return TarzCatalogueScreen(
          genderIndex: _categoryIndex,
          selectedCategoryIndex: _catalogueCategoryIndex,
          onGenderChanged: (i) => setState(() => _categoryIndex = i),
          onCategoryIndexChanged: (i) =>
              setState(() => _catalogueCategoryIndex = i),
          onSearchTap: _openSearch,
          onCartTap: _openCart,
          onCategoryTap: _openCatalogueCategory,
        );
      case 1:
        return const TarzOutfitsScreen();
      case 3:
        return TarzWishlistScreen(
          onProductTap: _openProductDetails,
        );
      case 4:
        return TarzProfileScreen(
          onWishlistTap: () => setState(() => _navIndex = 3),
          onOutfitsTap: () => setState(() => _navIndex = 1),
          onNotificationsTap: _openNotifications,
        );
      default:
        return _buildHomeBody(newProducts);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: API — gender tab dəyişəndə məhsul/banner yeniləməsi.
    final newProducts = TarzMockCatalog.homeNewProductsGrid();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: TarzHomeDrawer(
        selectedGenderIndex: _categoryIndex,
        onGenderSelected: (i) => setState(() => _categoryIndex = i),
        onCategoryTap: (label) => _toast(label),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildNavBody(newProducts)),
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
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: HomeSearchHeader(
                    onSearchTap: _openSearch,
                    onNotificationTap: _openNotifications,
                    onCartTap: _openCart,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GenderSegmentedTabs(
                      labels: TarzMockCatalog.categories,
                      selectedIndex: _categoryIndex,
                      onSelected: (i) => setState(() => _categoryIndex = i),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: HeroCollageBanner()),
                SliverToBoxAdapter(
                  child: NewProductsSection(
                    products: newProducts,
                    onSeeAll: () => _openProductListing(
                      'Yenilər',
                      TarzMockCatalog.homeYeniler(),
                    ),
                    onProductTap: _openProductDetails,
                    onWishlist: (p) {
                      TarzWishlistController.instance.toggle(p);
                      final added =
                          TarzWishlistController.instance.contains(p.id);
                      _toast(
                        added
                            ? '${p.title} — seçilmişlərə əlavə edildi'
                            : '${p.title} — seçilmişlərdən silindi',
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: AiOutfitBanner(
                    onCreateOutfit: () {
                      // TODO: AppRoutes.aiOutfit və ya mövcud AI marşrutuna bağla.
                      _toast('Öz obrazını yarat (tezliklə)');
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: CategoryGridSection(
                    categories: CategoryGridSection.mockCategories(),
                    onCategoryTap: (label) => _toast(label),
                  ),
                ),
                SliverToBoxAdapter(
                  child: BrandBannerSection(
                    onBannerTap: () => _toast('Brendlər'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: StoreChipsSection(
                    stores: StoreChipsSection.mockStores(),
                    onStoreTap: (store) => _toast(store.id),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import 'data/tarz_banner_assets.dart';
import 'data/tarz_mock_catalog.dart';
import 'models/tarz_product_preview.dart';
import '../routes/app_routes.dart';
import 'theme/tarz_breakpoints.dart';
import 'widgets/tarz_ai_outfits_section.dart';
import 'widgets/tarz_gender_segment_bar.dart';
import 'widgets/tarz_home_brands_section.dart';
import 'widgets/tarz_home_carousel_section.dart';
import 'widgets/tarz_home_categories_section.dart';
import 'widgets/tarz_home_drawer.dart';
import 'widgets/tarz_home_footer.dart';
import 'widgets/tarz_home_top_bar.dart';
import 'widgets/tarz_image_banner_card.dart';

/// Tessera ana səhifə — splash-dan sonra; dizayn iterasiyası üçün skelet.
class TarzHomeScreen extends StatefulWidget {
  const TarzHomeScreen({super.key});

  @override
  State<TarzHomeScreen> createState() => _TarzHomeScreenState();
}

class _TarzHomeScreenState extends State<TarzHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _categoryIndex = 0;

  void _toast(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  void _openMenuDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openSearch() {
    Navigator.of(context).pushNamed(AppRoutes.search);
  }

  void _openProductListing(String title, List<TarzProductPreview> products) {
    Navigator.of(context).pushNamed(
      AppRoutes.productListing,
      arguments: ProductListingArgs(title: title, products: products),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxW = TarzBreakpoints.contentMaxWidth(constraints.maxWidth);
                  final cardW = constraints.maxWidth >= 520 ? 168.0 : 152.0;
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
                            child: TarzHomeTopBar(
                              onMenu: _openMenuDrawer,
                              onSearch: _openSearch,
                              onWishlist: () => _toast('Seçilmişlər'),
                              onCart: () => _toast('Səbət'),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: TarzGenderSegmentBar(
                                labels: TarzMockCatalog.categories,
                                selectedIndex: _categoryIndex,
                                onSelected: (i) => setState(() => _categoryIndex = i),
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(
                            child: TarzImageBannerCard(
                              assetPath: TarzBannerAssets.winter,
                              caption: 'Qışa hazırlıq',
                            ),
                          ),
                          const SliverToBoxAdapter(
                            child: TarzImageBannerCard(
                              assetPath: TarzBannerAssets.mehman,
                              caption: 'Bayram sviterləri',
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: TarzAiOutfitsSection(
                              tallImageAsset: TarzBannerAssets.yakup,
                              squareImageAsset1: TarzBannerAssets.tomy,
                              squareImageAsset2: TarzBannerAssets.aiTileSquare2,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: TarzHomeCarouselSection(
                              title: 'Endirim',
                              cardWidth: cardW,
                              products: TarzMockCatalog.homeEndirim(),
                              onProductTap: (p) => _toast(p.title),
                              onTitleAction: () => _openProductListing(
                                'Endirim',
                                TarzMockCatalog.homeEndirim(),
                              ),
                              onShowAll: () => _openProductListing(
                                'Endirim',
                                TarzMockCatalog.homeEndirim(),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: TarzHomeCarouselSection(
                              title: 'Yenilər',
                              cardWidth: cardW,
                              products: TarzMockCatalog.homeYeniler(),
                              onProductTap: (p) => _toast(p.title),
                              onTitleAction: () => _openProductListing(
                                'Yenilər',
                                TarzMockCatalog.homeYeniler(),
                              ),
                              onShowAll: () => _openProductListing(
                                'Yenilər',
                                TarzMockCatalog.homeYeniler(),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: TarzHomeCarouselSection(
                              title: 'Trendlər',
                              cardWidth: cardW,
                              products: TarzMockCatalog.homeTrendler(),
                              onProductTap: (p) => _toast(p.title),
                              onTitleAction: () => _openProductListing(
                                'Trend',
                                TarzMockCatalog.homeTrendler(),
                              ),
                              onShowAll: () => _openProductListing(
                                'Trend',
                                TarzMockCatalog.homeTrendler(),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: TarzHomeCategoriesSection(
                              onCategoryTap: (label) => _toast(label),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: TarzHomeBrandsSection(
                              onBannerTap: () => _toast('Brendlər'),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: TarzHomeFooter(
                              onSectionTap: (id) => _toast(id),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 8)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

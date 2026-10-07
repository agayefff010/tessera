import '../../services/api_client.dart';
import '../../config/api_config.dart';
import '../../services/api_exception.dart';
import '../models/tarz_home_banner.dart';
import '../models/tarz_product_preview.dart';
import '../models/tarz_store_preview.dart';
import '../widgets/home/category_grid_section.dart';
import 'banner_mapper.dart';
import 'category_repository.dart';
import 'product_mapper.dart';
import 'tarz_gender_config.dart';
import 'vendor_repository.dart';

/// Main/Home ekranı üçün backend məlumatları.
class HomeRepository {
  HomeRepository({ApiClient? client})
      : _client = client ?? ApiClient(),
        _categoryRepo = CategoryRepository.instance,
        _ownsClient = client == null;

  final ApiClient _client;
  final CategoryRepository _categoryRepo;
  final bool _ownsClient;

  /// Aktiv reklamlar — `/advertisements/active?placement=…`
  Future<List<TarzHomeBanner>> fetchActiveAdvertisements(String placement) async {
    final body = await _client.get(
      ApiConfig.advertisementsActivePath,
      query: {'placement': placement},
    );
    return BannerMapper.listFromResponse(body);
  }

  /// Ana + side promo bannerlər birlikdə.
  Future<HomeAdvertisements> fetchHomeAdvertisements() async {
    final results = await Future.wait([
      fetchActiveAdvertisements(ApiConfig.adPlacementMainBanner),
      fetchActiveAdvertisements(ApiConfig.adPlacementSideTop),
      fetchActiveAdvertisements(ApiConfig.adPlacementSideBottom),
    ]);
    return HomeAdvertisements(
      mainBanner: results[0],
      sideTop: results[1],
      sideBottom: results[2],
    );
  }

  /// Geriyə uyğunluq — yalnız main_banner.
  Future<List<TarzHomeBanner>> fetchHomeBanners() {
    return fetchActiveAdvertisements(ApiConfig.adPlacementMainBanner);
  }

  Future<List<TarzProductPreview>> fetchNewProducts({
    int? genderIndex,
    int limit = 2,
  }) async {
    final query = <String, String>{
      'sort': 'newest',
      'limit': limit.toString(),
    };
    if (genderIndex != null) {
      query['gender'] = TarzGenderConfig.idForIndex(genderIndex);
    }
    final body = await _client.get('/products', query: query);
    return ProductMapper.listFromResponse(body);
  }

  Future<List<TarzProductPreview>> fetchDiscountProducts({
    int? genderIndex,
    int limit = 2,
  }) async {
    final query = <String, String>{
      'hasDiscount': 'true',
      'limit': limit.toString(),
    };
    if (genderIndex != null) {
      query['gender'] = TarzGenderConfig.idForIndex(genderIndex);
    }
    final body = await _client.get('/products', query: query);
    return ProductMapper.listFromResponse(body);
  }

  /// Ana səhifə «Yenilər» + «Endirimlər» — eyni kart təkrarlanmasın deyə
  /// daha çox gətirib bir-birindən ayırırıq.
  Future<HomeProductGrids> fetchHomeProductGrids({
    int? genderIndex,
    int perSection = 2,
  }) async {
    final pool = (perSection * 5).clamp(6, 20);
    final results = await Future.wait([
      fetchNewProducts(genderIndex: genderIndex, limit: pool),
      fetchDiscountProducts(genderIndex: genderIndex, limit: pool),
    ]);
    final newest = results[0];
    final discounted = results[1];

    // Yenilər: əvvəl endirimsiz yenilər, sonra digər yenilər.
    final newPick = <TarzProductPreview>[];
    for (final p in newest) {
      if (_hasDiscountBadge(p)) continue;
      newPick.add(p);
      if (newPick.length >= perSection) break;
    }
    for (final p in newest) {
      if (newPick.length >= perSection) break;
      if (newPick.any((x) => x.id == p.id)) continue;
      newPick.add(p);
    }

    final usedIds = newPick.map((p) => p.id).toSet();
    final discountPick = <TarzProductPreview>[];
    for (final p in discounted) {
      if (usedIds.contains(p.id)) continue;
      discountPick.add(p);
      if (discountPick.length >= perSection) break;
    }
    // Kifayət qədər fərqli endirim yoxdursa — təkrarlara icazə.
    if (discountPick.length < perSection) {
      for (final p in discounted) {
        if (discountPick.length >= perSection) break;
        if (discountPick.any((x) => x.id == p.id)) continue;
        discountPick.add(p);
      }
    }

    return HomeProductGrids(
      newProducts: newPick,
      discountProducts: discountPick,
    );
  }

  static bool _hasDiscountBadge(TarzProductPreview p) {
    final badge = p.badgeLabel;
    return badge != null && badge.startsWith('-');
  }

  Future<List<HomeCategoryItem>> fetchHomeCategories([int? genderIndex]) {
    return _categoryRepo.fetchHomeGridCategories(
      genderIndex: genderIndex ?? 0,
    );
  }

  Future<String?> resolveHomeCategoryId(String label, {int genderIndex = 0}) {
    return _categoryRepo.findCategoryIdForHomeLabel(
      label,
      genderIndex: genderIndex,
    );
  }

  Future<List<TarzStorePreview>> fetchStores({int limit = 12}) async {
    try {
      final stores =
          await VendorRepository(client: _client).fetchStorePreviews(limit: limit);
      if (stores.isNotEmpty) return stores;
    } catch (_) {
      // fallback below
    }
    return StoreChipsSectionFallback.stores;
  }

  /// Ana səhifə startup / refresh — bütün blokları paralel yükləyir.
  Future<HomeBootstrapSnapshot> loadBootstrapSnapshot() async {
    String? loadError;

    Future<T> guard<T>(
      Future<T> future,
      T fallback, {
      bool recordError = false,
    }) async {
      try {
        return await future;
      } on ApiException catch (e) {
        if (recordError) loadError ??= e.message;
        return fallback;
      } catch (_) {
        if (recordError) loadError ??= 'Məlumat yüklənmədi';
        return fallback;
      }
    }

    final results = await Future.wait([
      guard(
        fetchHomeAdvertisements(),
        const HomeAdvertisements(),
      ),
      guard(
        fetchHomeProductGrids(perSection: 2),
        const HomeProductGrids(),
        recordError: true,
      ),
      guard(
        fetchHomeCategories(0),
        CategoryGridSection.mockCategories(),
      ),
      guard(
        fetchStores(limit: 12),
        StoreChipsSectionFallback.stores,
      ),
    ]);

    final ads = results[0] as HomeAdvertisements;
    final grids = results[1] as HomeProductGrids;

    return HomeBootstrapSnapshot(
      advertisements: ads,
      productGrids: grids,
      categories: results[2] as List<HomeCategoryItem>,
      stores: results[3] as List<TarzStorePreview>,
      error: loadError,
    );
  }

  void dispose() {
    if (_ownsClient) _client.dispose();
  }
}

/// Ana səhifə startup snapshot — splash preload və Home reuse.
class HomeBootstrapSnapshot {
  const HomeBootstrapSnapshot({
    required this.advertisements,
    required this.productGrids,
    required this.categories,
    required this.stores,
    this.error,
  });

  final HomeAdvertisements advertisements;
  final HomeProductGrids productGrids;
  final List<HomeCategoryItem> categories;
  final List<TarzStorePreview> stores;
  final String? error;
}

/// Ana səhifə Yenilər / Endirimlər şəbəkələri.
class HomeProductGrids {
  const HomeProductGrids({
    this.newProducts = const [],
    this.discountProducts = const [],
  });

  final List<TarzProductPreview> newProducts;
  final List<TarzProductPreview> discountProducts;
}

/// Ana səhifə reklam placement-ləri.
class HomeAdvertisements {
  const HomeAdvertisements({
    this.mainBanner = const [],
    this.sideTop = const [],
    this.sideBottom = const [],
  });

  final List<TarzHomeBanner> mainBanner;
  final List<TarzHomeBanner> sideTop;
  final List<TarzHomeBanner> sideBottom;
}

/// API boş/qaytarılmadıqda mağaza fallback-i.
abstract final class StoreChipsSectionFallback {
  static const stores = [
    TarzStorePreview(id: 'sterns', name: 'STERNS'),
    TarzStorePreview(id: 'fabiani', name: 'FABIANI'),
    TarzStorePreview(id: 'archive', name: 'ARCHIVE'),
    TarzStorePreview(id: 'bottega', name: 'BOTTEGA VENETA'),
    TarzStorePreview(id: 'gant', name: 'GANT'),
    TarzStorePreview(id: 'the_fix', name: 'THE FIX'),
  ];
}

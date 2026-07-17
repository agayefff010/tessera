import '../../services/api_client.dart';
import '../../config/api_config.dart';
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

  void dispose() {
    if (_ownsClient) _client.dispose();
  }
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

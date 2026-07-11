import '../../services/api_client.dart';
import '../../services/api_exception.dart';
import '../../services/auth_storage.dart';
import '../../config/api_config.dart';
import '../models/tarz_home_banner.dart';
import '../models/tarz_product_preview.dart';
import '../models/tarz_store_preview.dart';
import '../widgets/home/category_grid_section.dart';
import 'banner_mapper.dart';
import 'category_repository.dart';
import 'product_mapper.dart';
import 'tarz_gender_config.dart';

/// Main/Home ekranı üçün backend məlumatları.
class HomeRepository {
  HomeRepository({ApiClient? client})
      : _client = client ?? ApiClient(),
        _categoryRepo = CategoryRepository(client: client);

  final ApiClient _client;
  final CategoryRepository _categoryRepo;

  /// Ana səhifə slider bannerləri — `/banners`, yalnız admin üçün `/admin/banners`.
  Future<List<TarzHomeBanner>> fetchHomeBanners() async {
    final user = await AuthStorage.instance.getUser();
    final token = await AuthStorage.instance.getToken();
    final paths = <String>[ApiConfig.bannersPath];
    if (user?.role?.toUpperCase() == 'ADMIN') {
      paths.add(ApiConfig.adminBannersPath);
    }

    for (final path in paths) {
      try {
        final body = await _client.get(
          path,
          query: const {'active': 'true'},
          bearerToken: path == ApiConfig.adminBannersPath ? token : null,
        );
        final banners = BannerMapper.listFromResponse(body);
        if (banners.isNotEmpty) return banners;
      } on ApiException catch (e) {
        if (e.statusCode == 401 || e.statusCode == 403 || e.statusCode == 404) {
          continue;
        }
        rethrow;
      }
    }

    return const [];
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
    final body = await _client.get(
      '/products',
      query: {
        'hasDiscount': 'true',
        'limit': '48',
      },
    );
    var products = ProductMapper.listFromResponse(body);
    if (genderIndex != null) {
      final genderId = TarzGenderConfig.idForIndex(genderIndex);
      products = products
          .where((p) => ProductCategoryFilter.matchesGender(p, genderId))
          .toList();
    }
    return products.take(limit).toList();
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
    final body = await _client.get(
      '/brands',
      query: {'limit': limit.toString()},
    );
    final data = body['data'];
    if (data is! List) return StoreChipsSectionFallback.stores;

    final stores = <TarzStorePreview>[];
    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;
      final id = item['_id']?.toString();
      final name = item['name']?.toString();
      if (id == null || id.isEmpty || name == null || name.isEmpty) continue;
      final logo = item['logo']?.toString();
      stores.add(
        TarzStorePreview(
          id: id,
          name: name,
          logoUrl: logo != null && logo.isNotEmpty ? logo : null,
        ),
      );
    }

    return stores.isEmpty ? StoreChipsSectionFallback.stores : stores;
  }

  void dispose() {
    _categoryRepo.dispose();
    _client.dispose();
  }
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

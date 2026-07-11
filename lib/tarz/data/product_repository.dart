import '../../services/api_client.dart';
import '../../services/api_exception.dart';
import '../models/tarz_product_detail.dart';
import '../models/tarz_product_preview.dart';
import 'category_repository.dart';
import 'product_mapper.dart';
import 'tarz_gender_config.dart';

class ProductListResult {
  const ProductListResult({
    required this.products,
    required this.pageCount,
    required this.limit,
    required this.rawPage,
  });

  final List<TarzProductPreview> products;
  final int pageCount;
  final int limit;
  final int rawPage;

  bool get hasMore => pageCount >= limit;
}

/// Məhsul siyahısı (PLP) — pagination, filter, sort.
class ProductRepository {
  ProductRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static const int defaultPageSize = 20;
  static const int _maxScanPages = 8;

  Future<ProductListResult> fetchProducts({
    required int page,
    int limit = defaultPageSize,
    String? categoryId,
    int? genderIndex,
    String? search,
    String? sort,
    double? minPrice,
    double? maxPrice,
    Set<String>? categoryScope,
    bool filterByGender = true,
  }) async {
    final genderId =
        genderIndex != null ? TarzGenderConfig.idForIndex(genderIndex) : null;

    if (categoryScope != null && categoryScope.isNotEmpty) {
      return _fetchWithClientCategoryFilter(
        startPage: page,
        limit: limit,
        categoryScope: categoryScope,
        genderId: filterByGender ? genderId : null,
        search: search,
        sort: sort,
        minPrice: minPrice,
        maxPrice: maxPrice,
        categoryId: categoryId,
        genderIndex: genderIndex,
      );
    }

    if (filterByGender && genderId != null) {
      return _fetchWithClientGenderFilter(
        startPage: page,
        limit: limit,
        genderId: genderId,
        search: search,
        sort: sort,
        minPrice: minPrice,
        maxPrice: maxPrice,
        categoryId: categoryId,
      );
    }

    final result = await _fetchRawPage(
      page: page,
      limit: limit,
      categoryId: categoryId,
      genderIndex: genderIndex,
      search: search,
      sort: sort,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );

    var products = result.products;
    if (filterByGender && genderId != null) {
      products = products
          .where((p) => ProductCategoryFilter.matchesGender(p, genderId))
          .toList();
    }

    return ProductListResult(
      products: products,
      pageCount: result.pageCount,
      limit: limit,
      rawPage: page,
    );
  }

  Future<ProductListResult> _fetchWithClientGenderFilter({
    required int startPage,
    required int limit,
    required String genderId,
    String? search,
    String? sort,
    double? minPrice,
    double? maxPrice,
    String? categoryId,
  }) async {
    final matched = <TarzProductPreview>[];
    var rawPage = startPage;
    var scanned = 0;

    while (matched.length < limit && scanned < _maxScanPages) {
      final batch = await _fetchRawPage(
        page: rawPage,
        limit: limit,
        categoryId: categoryId,
        search: search,
        sort: sort,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

      scanned++;

      for (final product in batch.products) {
        if (!ProductCategoryFilter.matchesGender(product, genderId)) {
          continue;
        }
        matched.add(product);
        if (matched.length >= limit) break;
      }

      if (batch.pageCount < limit) break;
      rawPage++;
    }

    return ProductListResult(
      products: matched,
      pageCount: matched.length,
      limit: limit,
      rawPage: rawPage,
    );
  }

  Future<ProductListResult> _fetchWithClientCategoryFilter({
    required int startPage,
    required int limit,
    required Set<String> categoryScope,
    String? genderId,
    String? search,
    String? sort,
    double? minPrice,
    double? maxPrice,
    String? categoryId,
    int? genderIndex,
  }) async {
    final matched = <TarzProductPreview>[];
    var rawPage = startPage;
    var scanned = 0;

    while (matched.length < limit && scanned < _maxScanPages) {
      final batch = await _fetchRawPage(
        page: rawPage,
        limit: limit,
        categoryId: categoryId,
        genderIndex: genderIndex,
        search: search,
        sort: sort,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

      scanned++;

      for (final product in batch.products) {
        if (!ProductCategoryFilter.matchesScope(product, categoryScope)) {
          continue;
        }
        if (genderId != null &&
            !ProductCategoryFilter.matchesGender(product, genderId)) {
          continue;
        }
        matched.add(product);
        if (matched.length >= limit) break;
      }

      if (batch.pageCount < limit) break;
      rawPage++;
    }

    return ProductListResult(
      products: matched,
      pageCount: matched.length,
      limit: limit,
      rawPage: rawPage,
    );
  }

  Future<ProductListResult> _fetchRawPage({
    required int page,
    required int limit,
    String? categoryId,
    int? genderIndex,
    String? search,
    String? sort,
    double? minPrice,
    double? maxPrice,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (categoryId != null && categoryId.isNotEmpty) {
      query['category'] = categoryId;
    }
    if (genderIndex != null) {
      query['gender'] = TarzGenderConfig.idForIndex(genderIndex);
    }
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    if (sort != null && sort.isNotEmpty) {
      query['sort'] = sort;
    }
    if (minPrice != null) {
      query['minPrice'] = minPrice.round().toString();
    }
    if (maxPrice != null) {
      query['maxPrice'] = maxPrice.round().toString();
    }

    final body = await _client.get('/products', query: query);
    final products = ProductMapper.listFromResponse(body);
    final pageCount = body['count'] is int
        ? body['count'] as int
        : products.length;

    return ProductListResult(
      products: products,
      pageCount: pageCount,
      limit: limit,
      rawPage: page,
    );
  }

  Future<TarzProductDetail> fetchProductDetail(String id) async {
    final body = await _client.get('/products/$id');
    final detail = ProductMapper.detailFromResponse(body);
    if (detail == null) {
      throw const ApiException('Məhsul tapılmadı');
    }
    return detail;
  }

  Future<List<TarzProductPreview>> fetchSimilarProducts(String id) async {
    final body = await _client.get('/products/$id/similar');
    return ProductMapper.listFromResponse(body);
  }

  Future<void> recordProductView(String id) async {
    try {
      await _client.post('/products/$id/views', body: const {});
    } catch (_) {
      // Analytics uğursuz olsa da PDP açıq qalsın.
    }
  }

  void dispose() => _client.dispose();
}

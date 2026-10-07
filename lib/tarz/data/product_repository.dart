import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../services/api_client.dart';
import '../../services/api_exception.dart';
import '../../services/auth_storage.dart';
import '../models/plp_category_option.dart';
import '../models/tarz_product_detail.dart';
import '../models/tarz_product_preview.dart';
import '../models/tarz_product_review.dart';
import '../models/tarz_outfit.dart';
import '../widgets/product_details/product_details_write_review_sheet.dart';
import 'category_repository.dart';
import 'outfit_mapper.dart';
import 'product_mapper.dart';
import 'review_mapper.dart';
import 'tarz_gender_config.dart';

class ProductListResult {
  const ProductListResult({
    required this.products,
    required this.pageCount,
    required this.limit,
    required this.rawPage,
    this.totalCount,
  });

  final List<TarzProductPreview> products;
  /// Bu səhifədə gələn məhsul sayı (pagination üçün).
  final int pageCount;
  final int limit;
  final int rawPage;
  /// API `count` — ümumi uyğun məhsul (opsional).
  final int? totalCount;

  bool get hasMore => products.length >= limit;
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
    String? vendorId,
    String? brandId,
    bool hasDiscount = false,
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
        vendorId: vendorId,
        brandId: brandId,
        hasDiscount: hasDiscount,
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
        vendorId: vendorId,
        brandId: brandId,
        hasDiscount: hasDiscount,
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
      vendorId: vendorId,
      brandId: brandId,
      hasDiscount: hasDiscount,
    );

    var products = result.products;
    if (filterByGender && genderId != null) {
      products = products
          .where((p) => ProductCategoryFilter.matchesGender(p, genderId))
          .toList();
    }

    return ProductListResult(
      products: products,
      pageCount: products.length,
      limit: limit,
      rawPage: page,
      totalCount: result.totalCount,
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
    String? vendorId,
    String? brandId,
    bool hasDiscount = false,
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
        vendorId: vendorId,
        brandId: brandId,
        hasDiscount: hasDiscount,
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
      // Client gender filter — API `count` filtrsiz olur; boş→0, dolu→UI siyahı uzunluğu.
      totalCount: matched.isEmpty ? 0 : null,
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
    String? vendorId,
    String? brandId,
    bool hasDiscount = false,
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
        vendorId: vendorId,
        brandId: brandId,
        hasDiscount: hasDiscount,
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
      // Scope filter — API category-ni ignore edib ümumi count (20) qaytara bilir.
      totalCount: matched.isEmpty ? 0 : null,
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
    String? vendorId,
    String? brandId,
    bool hasDiscount = false,
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
    if (vendorId != null && vendorId.isNotEmpty) {
      query['vendorId'] = vendorId;
    }
    if (brandId != null && brandId.isNotEmpty) {
      query['brandId'] = brandId;
    }
    if (hasDiscount) {
      query['hasDiscount'] = 'true';
    }

    final body = await _client.get('/products', query: query);
    final products = ProductMapper.listFromResponse(body);
    final total = body['count'] is int ? body['count'] as int : null;

    return ProductListResult(
      products: products,
      pageCount: products.length,
      limit: limit,
      rawPage: page,
      totalCount: total,
    );
  }

  /// `GET /brands` — brend siyahısı.
  Future<List<PlpCategoryOption>> fetchBrands() async {
    final body = await _client.get('/brands');
    final raw = body['data'] ?? body['brands'] ?? body;
    if (raw is! List) return const [];

    final brands = <PlpCategoryOption>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final id = map['_id']?.toString() ?? map['id']?.toString() ?? '';
      final name = map['name']?.toString() ?? '';
      if (id.isEmpty || name.isEmpty) continue;
      brands.add(PlpCategoryOption(id: id, name: name));
    }
    brands.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return brands;
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

  /// `GET /products/search/autocomplete?q=`
  Future<List<TarzProductPreview>> fetchAutocomplete(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final body = await _client.get(
      '/products/search/autocomplete',
      query: {'q': q},
    );
    return ProductMapper.listFromResponse(body);
  }

  /// `GET /products/:id/reviews?sort=&imagesOnly=`
  Future<TarzProductReviewsResult> fetchProductReviews(
    String id, {
    String? sort,
    bool imagesOnly = false,
  }) async {
    final query = <String, String>{};
    if (sort != null && sort.isNotEmpty) {
      query['sort'] = sort;
    }
    if (imagesOnly) {
      query['imagesOnly'] = 'true';
    }

    final body = await _client.get(
      '/products/$id/reviews',
      query: query.isEmpty ? null : query,
    );
    return ReviewMapper.fromResponse(body);
  }

  /// `POST /products/:id/reviews` — auth tələb olunur.
  Future<void> submitProductReview(
    String id, {
    required int rating,
    required String comment,
    List<TarzReviewImageDraft> images = const [],
  }) async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('Rəy yazmaq üçün daxil olun');
    }

    final trimmed = comment.trim();
    if (rating < 1 || rating > 5) {
      throw const ApiException('Reytinq 1–5 arasında olmalıdır');
    }
    if (trimmed.isEmpty) {
      throw const ApiException('Rəy mətnini yazın');
    }

    // Şəkil yoxdursa JSON — backend multipart gözləməyə bilər.
    if (images.isEmpty) {
      await _client.post(
        '/products/$id/reviews',
        body: {
          'rating': rating,
          'comment': trimmed,
        },
        bearerToken: token,
      );
      return;
    }

    final fields = {
      'rating': rating.toString(),
      'comment': trimmed,
    };

    try {
      await _client.postMultipart(
        '/products/$id/reviews',
        fields: fields,
        files: _reviewFiles(images, fieldName: 'images'),
        bearerToken: token,
      );
    } on ApiException catch (e) {
      // Field adı fərqli ola bilər.
      if (e.statusCode == 400 || e.statusCode == 415 || e.statusCode == 422) {
        await _client.postMultipart(
          '/products/$id/reviews',
          fields: fields,
          files: _reviewFiles(images, fieldName: 'image'),
          bearerToken: token,
        );
        return;
      }
      rethrow;
    }
  }

  List<http.MultipartFile> _reviewFiles(
    List<TarzReviewImageDraft> images, {
    required String fieldName,
  }) {
    final files = <http.MultipartFile>[];
    for (var i = 0; i < images.length; i++) {
      final image = images[i];
      final filename = image.name.trim().isNotEmpty
          ? image.name
          : 'review_$i.jpg';
      final mime =
          lookupMimeType(filename, headerBytes: image.bytes) ?? 'image/jpeg';
      final parts = mime.split('/');
      files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          image.bytes,
          filename: filename,
          contentType: MediaType(
            parts.isNotEmpty ? parts.first : 'image',
            parts.length > 1 ? parts[1] : 'jpeg',
          ),
        ),
      );
    }
    return files;
  }

  Future<void> recordProductView(String id) async {
    try {
      await _client.post('/products/$id/views', body: const {});
    } catch (_) {
      // Analytics uğursuz olsa da PDP açıq qalsın.
    }
  }

  /// `GET /outfits/generate/:slug` — ayaqqabı + üst + çanta.
  Future<TarzGeneratedOutfit> fetchGeneratedOutfit(String slug) async {
    final trimmed = slug.trim();
    if (trimmed.isEmpty) return TarzGeneratedOutfit.empty;
    final body = await _client.get('/outfits/generate/$trimmed');
    return OutfitMapper.fromResponse(body);
  }

  void dispose() => _client.dispose();
}

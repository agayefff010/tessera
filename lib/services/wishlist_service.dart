import '../tarz/data/product_mapper.dart';
import '../tarz/models/tarz_product_preview.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'auth_storage.dart';

/// Backend seçilmişlər — cart API ilə eyni üslub.
class WishlistService {
  WishlistService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Backend hazır deyilsə `null` qaytarır (404).
  Future<List<TarzProductPreview>?> fetchWishlist() async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final body = await _client.get('/wishlist', bearerToken: token);
      return _parseProducts(body);
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 401 || e.statusCode == 403) {
        return null;
      }
      rethrow;
    }
  }

  Future<bool> addProduct(String productId) async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) return false;

    try {
      await _client.post(
        '/wishlist/add',
        body: {'productId': productId},
        bearerToken: token,
      );
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return false;
      rethrow;
    }
  }

  Future<bool> removeProduct(String productId) async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) return false;

    try {
      await _client.delete(
        '/wishlist/item/$productId',
        bearerToken: token,
      );
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return false;
      rethrow;
    }
  }

  List<TarzProductPreview> _parseProducts(Map<String, dynamic> body) {
    final direct = ProductMapper.listFromResponse(body);
    if (direct.isNotEmpty) return direct;

    final data = body['data'];
    if (data is! List) return const [];

    final products = <TarzProductPreview>[];
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        final product = item['product'];
        if (product is Map<String, dynamic>) {
          products.add(ProductMapper.fromJson(product));
        } else {
          products.add(ProductMapper.fromJson(item));
        }
      }
    }
    return products.where((p) => p.id.isNotEmpty).toList();
  }

  void dispose() => _client.dispose();
}

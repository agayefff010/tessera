import '../tarz/data/cart_mapper.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'auth_storage.dart';

/// Backend səbət əməliyyatları.
class CartService {
  CartService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<CartFetchResult?> fetchCart() async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final body = await _client.get('/cart', bearerToken: token);
      return CartMapper.fromResponse(body);
    } on ApiException catch (e) {
      // Token etibarsızdır və ya bu endpoint üçün icazə yoxdur — lokal səbət qalır.
      if (e.statusCode == 401 || e.statusCode == 403) return null;
      rethrow;
    }
  }

  Future<bool> addProduct({
    required String productId,
    int quantity = 1,
  }) async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) return false;

    await _client.post(
      '/cart/add',
      body: {
        'productId': productId,
        'quantity': quantity,
      },
      bearerToken: token,
    );
    return true;
  }

  Future<bool> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) return false;

    await _client.put(
      '/cart/item/$productId',
      body: {'quantity': quantity},
      bearerToken: token,
    );
    return true;
  }

  Future<bool> removeProduct(String productId) async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) return false;

    await _client.delete(
      '/cart/item/$productId',
      bearerToken: token,
    );
    return true;
  }

  Future<bool> clearCart() async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) return false;

    await _client.delete('/cart', bearerToken: token);
    return true;
  }

  void dispose() => _client.dispose();
}

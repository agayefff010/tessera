import '../config/api_config.dart';
import '../tarz/models/tarz_order.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'auth_storage.dart';
import 'order_storage.dart';

/// Checkout və sifarişlər API.
class OrderService {
  OrderService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<TarzOrder?> checkout({
    required TarzCheckoutRequest request,
    required double totalManat,
    required int itemCount,
  }) async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) return null;

    final body = <String, dynamic>{
      'paymentMethod': 'CASH',
    };

    if (request.deliveryMethod == TarzDeliveryMethod.delivery) {
      body['shippingAddress'] = {
        'address': request.address ?? '',
        'city': 'Bakı',
        'postalCode': request.postalCode ?? '',
        'country': 'Azerbaijan',
      };
      if (request.phone != null && request.phone!.isNotEmpty) {
        body['phone'] = request.phone;
      }
    } else {
      body['shippingAddress'] = {
        'address': 'Yerdən götürmə',
        'city': 'Bakı',
        'country': 'Azerbaijan',
      };
    }

    try {
      final result = await _client.post(
        ApiConfig.checkoutPath,
        body: body,
        bearerToken: token,
      );
      return _parseCheckoutResponse(
        result.data,
        request: request,
        totalManat: totalManat,
        itemCount: itemCount,
      );
    } on ApiException {
      return null;
    }
  }

  Future<List<TarzOrder>> fetchRemoteOrders() async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) return const [];

    try {
      final body = await _client.get(ApiConfig.ordersPath, bearerToken: token);
      return _parseOrdersList(body);
    } on ApiException {
      return const [];
    }
  }

  TarzOrder createLocalOrder({
    required TarzCheckoutRequest request,
    required double totalManat,
    required int itemCount,
  }) {
    return TarzOrder(
      id: OrderStorage.generateLocalId(),
      status: TarzOrderStatus.preparing,
      deliveryMethod: request.deliveryMethod,
      totalManat: totalManat,
      itemCount: itemCount,
      createdAt: DateTime.now(),
      address: request.address,
      postalCode: request.postalCode,
      phone: request.phone,
      fromBackend: false,
    );
  }

  TarzOrder? _parseCheckoutResponse(
    Map<String, dynamic> body, {
    required TarzCheckoutRequest request,
    required double totalManat,
    required int itemCount,
  }) {
    final orderJson = body['order'] is Map<String, dynamic>
        ? body['order'] as Map<String, dynamic>
        : body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

    final id = orderJson['_id']?.toString() ??
        orderJson['id']?.toString() ??
        orderJson['orderId']?.toString() ??
        body['orderId']?.toString();

    if (id == null || id.isEmpty) return null;

    final statusRaw = orderJson['status']?.toString() ??
        orderJson['orderStatus']?.toString();

    final total = (orderJson['total'] as num?)?.toDouble() ??
        (orderJson['totalAmount'] as num?)?.toDouble() ??
        totalManat;

    return TarzOrder(
      id: id,
      status: TarzOrderStatusX.fromApi(statusRaw),
      deliveryMethod: request.deliveryMethod,
      totalManat: total,
      itemCount: itemCount,
      createdAt: DateTime.tryParse(orderJson['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      address: request.address,
      postalCode: request.postalCode,
      phone: request.phone,
      fromBackend: true,
    );
  }

  List<TarzOrder> _parseOrdersList(Map<String, dynamic> body) {
    dynamic list = body['orders'] ?? body['data'] ?? body['items'];
    if (list is Map<String, dynamic>) {
      list = list['orders'] ?? list['items'];
    }
    if (list is! List) return const [];

    final orders = <TarzOrder>[];
    for (final item in list) {
      if (item is! Map<String, dynamic>) continue;
      final id = item['_id']?.toString() ?? item['id']?.toString();
      if (id == null || id.isEmpty) continue;

      final items = item['items'];
      var count = (item['itemCount'] as num?)?.toInt() ?? 0;
      if (count == 0 && items is List) count = items.length;

      orders.add(
        TarzOrder(
          id: id,
          status: TarzOrderStatusX.fromApi(item['status']?.toString()),
          deliveryMethod: _deliveryFromJson(item),
          totalManat: (item['total'] as num?)?.toDouble() ??
              (item['totalAmount'] as num?)?.toDouble() ??
              0,
          itemCount: count,
          createdAt: DateTime.tryParse(item['createdAt']?.toString() ?? '') ??
              DateTime.now(),
          address: _readAddress(item),
          postalCode: _readPostalCode(item),
          phone: item['phone']?.toString(),
          fromBackend: true,
        ),
      );
    }
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  TarzDeliveryMethod _deliveryFromJson(Map<String, dynamic> item) {
    final address = _readAddress(item)?.toLowerCase() ?? '';
    if (address.contains('götürmə') || address.contains('goturme')) {
      return TarzDeliveryMethod.pickup;
    }
    return TarzDeliveryMethod.delivery;
  }

  String? _readAddress(Map<String, dynamic> item) {
    final shipping = item['shippingAddress'];
    if (shipping is Map<String, dynamic>) {
      return shipping['address']?.toString();
    }
    return item['address']?.toString();
  }

  String? _readPostalCode(Map<String, dynamic> item) {
    final shipping = item['shippingAddress'];
    if (shipping is Map<String, dynamic>) {
      return shipping['postalCode']?.toString();
    }
    return item['postalCode']?.toString();
  }

  void dispose() => _client.dispose();
}

import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../tarz/models/tarz_order.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'auth_storage.dart';

/// Epoint ödəniş başlatma cavabı.
class EpointInitResult {
  const EpointInitResult({
    required this.orderId,
    required this.redirectUrl,
    required this.totalAmount,
    required this.transaction,
  });

  final String orderId;
  final String redirectUrl;
  final double totalAmount;
  final String transaction;
}

/// Epoint ödəniş doğrulama cavabı.
class EpointVerifyResult {
  const EpointVerifyResult({
    required this.success,
    required this.orderId,
    this.message,
  });

  final bool success;
  final String orderId;
  final String? message;
}

/// Backend sifariş və ödəniş əməliyyatları.
class OrderService {
  OrderService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  // ---------------------------------------------------------------------------
  // Epoint card payment
  // ---------------------------------------------------------------------------

  /// POST /checkout/epoint/init — sifariş yaradır və Epoint ödəniş URL-i qaytarır.
  ///
  /// Bu metod özü sifarişi yaradır — əvvəlcədən ayrı bir sifariş yaratmayın.
  /// Init timeout-dan sonra retry etməyin: backend artıq sifariş yaratmış ola bilər.
  Future<EpointInitResult> initEpointPayment({
    required String deliveryType,
    Map<String, String>? shippingAddress,
    String? pickupBranch,
    required bool isGiftWrapped,
    required String clientOrigin,
  }) async {
    final token = await _requireToken();

    final body = <String, dynamic>{
      'deliveryType': deliveryType,
      'isGiftWrapped': isGiftWrapped,
      'clientOrigin': clientOrigin,
    };

    if (deliveryType == 'DELIVERY' && shippingAddress != null) {
      body['shippingAddress'] = shippingAddress;
    }
    if (deliveryType == 'PICKUP' && pickupBranch != null) {
      body['pickupBranch'] = pickupBranch;
    }

    final result = await _client.post(
      '/checkout/epoint/init',
      body: body,
      bearerToken: token,
    );

    final data = result.data['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Ödəniş cavabı gözlənilən formatda deyil');
    }

    final orderId = data['orderId']?.toString();
    if (orderId == null || orderId.isEmpty) {
      throw const ApiException('Sifariş ID-si qaytarılmadı');
    }

    final epointPayment = data['epointPayment'];
    if (epointPayment is! Map<String, dynamic>) {
      throw const ApiException('Epoint ödəniş məlumatı tapılmadı');
    }

    final redirectUrl = epointPayment['redirect_url']?.toString();
    if (redirectUrl == null || redirectUrl.isEmpty) {
      throw const ApiException('Ödəniş URL-i qaytarılmadı');
    }

    // Təhlükəsizlik: yalnız HTTPS URL-lər qəbul olunur.
    final uri = Uri.tryParse(redirectUrl);
    if (uri == null || uri.scheme != 'https') {
      throw const ApiException('Etibarsız ödəniş URL-i');
    }

    final totalAmount =
        (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final transaction =
        epointPayment['transaction']?.toString() ?? '';

    return EpointInitResult(
      orderId: orderId,
      redirectUrl: redirectUrl,
      totalAmount: totalAmount,
      transaction: transaction,
    );
  }

  /// POST /checkout/epoint/verify-order — ödənişin backend tərəfindən təsdiqlənməsini yoxlayır.
  Future<EpointVerifyResult> verifyEpointPayment({
    required String orderId,
  }) async {
    final token = await _requireToken();

    final result = await _client.post(
      '/checkout/epoint/verify-order',
      body: {'orderId': orderId},
      bearerToken: token,
    );

    final success = result.data['success'] == true;
    final message = result.data['message']?.toString();
    final dataMap = result.data['data'];
    final resolvedId =
        (dataMap is Map<String, dynamic> ? dataMap['orderId'] : null)
                ?.toString() ??
            orderId;

    return EpointVerifyResult(
      success: success,
      orderId: resolvedId,
      message: message,
    );
  }

  /// GET /orders/:id — bir sifarişin tam detallarını oxuyur (paymentStatus daxil).
  Future<TarzOrder?> fetchOrderById(String orderId) async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final body = await _client.get(
        '${ApiConfig.ordersPath}/$orderId',
        bearerToken: token,
      );
      return _parseOrderDetail(body);
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403 || e.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Existing order operations
  // ---------------------------------------------------------------------------

  /// GET /orders — sifariş tarixçəsi.
  Future<List<TarzOrder>?> fetchRemoteOrders() async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final body = await _client.get(
        ApiConfig.ordersPath,
        bearerToken: token,
      );
      return _parseOrderList(body);
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) return null;
      rethrow;
    }
  }

  /// POST /checkout — köhnə CASH ödəniş (saxlanır, amma Epoint axınında istifadə olunmur).
  Future<TarzOrder?> checkout({
    required TarzCheckoutRequest request,
    required double totalManat,
    required int itemCount,
  }) async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final body = <String, dynamic>{
        'paymentMethod': 'CASH',
        'deliveryType': request.deliveryMethod == TarzDeliveryMethod.delivery
            ? 'DELIVERY'
            : 'PICKUP',
      };
      if (request.address != null) {
        body['shippingAddress'] = {'street': request.address};
      }

      final result = await _client.post(
        ApiConfig.checkoutPath,
        body: body,
        bearerToken: token,
      );

      final data = result.data['data'];
      if (data is Map<String, dynamic>) {
        final order = data['order'] ?? data;
        if (order is Map<String, dynamic>) {
          return _mapRemoteOrder(order);
        }
      }
      return null;
    } on ApiException {
      return null;
    }
  }

  void dispose() => _client.dispose();

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<String> _requireToken() async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('Daxil olmalısınız');
    }
    return token;
  }

  List<TarzOrder> _parseOrderList(Map<String, dynamic> body) {
    final raw = body['data'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(_mapRemoteOrder)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  TarzOrder? _parseOrderDetail(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is! Map<String, dynamic>) return null;
    final order = data['order'];
    if (order is Map<String, dynamic>) return _mapRemoteOrder(order);
    return _mapRemoteOrder(data);
  }

  static TarzOrder _mapRemoteOrder(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';

    // deliveryType: backend "DELIVERY" / "PICKUP" → enum
    final rawDelivery = json['deliveryType']?.toString().toUpperCase() ?? '';
    final deliveryMethod = rawDelivery.contains('DELIVERY')
        ? TarzDeliveryMethod.delivery
        : TarzDeliveryMethod.pickup;

    // status: backend PENDING / PROCESSING / DELIVERED / CANCELLED
    final status = TarzOrderStatusX.fromApi(json['status']?.toString());

    final totalAmount = (json['totalAmount'] as num?)?.toDouble() ?? 0;

    // shippingAddress parsing
    String? street;
    String? city;
    String? zipCode;
    final addr = json['shippingAddress'];
    if (addr is Map<String, dynamic>) {
      street = addr['street']?.toString();
      city = addr['city']?.toString();
      zipCode = addr['zipCode']?.toString();
    }

    // Legacy: ünvan birbaşa string ola bilər
    street ??= json['address']?.toString();

    final paymentStatus = json['paymentStatus']?.toString();

    final createdAt = DateTime.tryParse(
          json['createdAt']?.toString() ?? '',
        ) ??
        DateTime.now();

    // subOrders-dan item sayını təxmini hesabla
    final subOrders = json['subOrders'];
    int itemCount = 0;
    if (subOrders is List) {
      itemCount = subOrders.length;
    }

    return TarzOrder(
      id: id,
      status: status,
      deliveryMethod: deliveryMethod,
      totalManat: totalAmount,
      itemCount: itemCount,
      createdAt: createdAt,
      paymentStatus: paymentStatus,
      address: street,
      city: city,
      postalCode: zipCode,
      fromBackend: true,
    );
  }
}
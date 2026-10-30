/// Sifariş çatdırılma üsulu.
enum TarzDeliveryMethod {
  pickup,
  delivery,
}

/// Sifariş statusu.
enum TarzOrderStatus {
  preparing,
  ready,
  delivered,
  cancelled,
}

/// Ödəniş statusu — backend paymentStatus.
enum TarzPaymentStatus {
  pending,
  success,
  failed,
}

extension TarzPaymentStatusX on TarzPaymentStatus {
  String get labelAz {
    switch (this) {
      case TarzPaymentStatus.pending:
        return 'Gözləyir';
      case TarzPaymentStatus.success:
        return 'Ödənilib';
      case TarzPaymentStatus.failed:
        return 'Uğursuz';
    }
  }

  static TarzPaymentStatus fromApi(String? raw) {
    final v = raw?.toUpperCase().trim() ?? '';
    if (v == 'SUCCESS') return TarzPaymentStatus.success;
    if (v == 'FAILED') return TarzPaymentStatus.failed;
    return TarzPaymentStatus.pending;
  }
}

extension TarzOrderStatusX on TarzOrderStatus {
  String get labelAz {
    switch (this) {
      case TarzOrderStatus.preparing:
        return 'Hazırlanır';
      case TarzOrderStatus.ready:
        return 'Hazırdır';
      case TarzOrderStatus.delivered:
        return 'Çatdırılıb';
      case TarzOrderStatus.cancelled:
        return 'Ləğv edilib';
    }
  }

  static TarzOrderStatus fromApi(String? raw) {
    final v = raw?.toLowerCase().trim() ?? '';
    if (v.contains('ready') || v.contains('hazir')) {
      return TarzOrderStatus.ready;
    }
    if (v.contains('deliver') || v.contains('catdir') || v.contains('complete')) {
      return TarzOrderStatus.delivered;
    }
    if (v.contains('cancel') || v.contains('legv')) {
      return TarzOrderStatus.cancelled;
    }
    return TarzOrderStatus.preparing;
  }
}

extension TarzDeliveryMethodX on TarzDeliveryMethod {
  String get labelAz {
    switch (this) {
      case TarzDeliveryMethod.pickup:
        return 'Yerdən götürmə';
      case TarzDeliveryMethod.delivery:
        return 'Çatdırılma';
    }
  }
}

/// Sifariş — backend və ya lokal.
class TarzOrder {
  const TarzOrder({
    required this.id,
    required this.status,
    required this.deliveryMethod,
    required this.totalManat,
    required this.itemCount,
    required this.createdAt,
    this.userId,
    this.paymentStatus,
    this.address,
    this.city,
    this.postalCode,
    this.phone,
    this.fromBackend = false,
  });

  final String id;
  final TarzOrderStatus status;
  final TarzDeliveryMethod deliveryMethod;
  final double totalManat;
  final int itemCount;
  final DateTime createdAt;
  final String? userId;
  final String? paymentStatus;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? phone;
  final bool fromBackend;

  String get displayId {
    if (id.length <= 12) return id.toUpperCase();
    return id.substring(0, 8).toUpperCase();
  }

  /// paymentStatus-u TarzPaymentStatus enum-a çevirir.
  TarzPaymentStatus get paymentStatusEnum =>
      TarzPaymentStatusX.fromApi(paymentStatus);

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status.name,
        'deliveryMethod': deliveryMethod.name,
        'totalManat': totalManat,
        'itemCount': itemCount,
        'createdAt': createdAt.toIso8601String(),
        'userId': userId,
        'paymentStatus': paymentStatus,
        'address': address,
        'city': city,
        'postalCode': postalCode,
        'phone': phone,
        'fromBackend': fromBackend,
      };

  factory TarzOrder.fromJson(Map<String, dynamic> json) {
    return TarzOrder(
      id: json['id']?.toString() ?? '',
      status: TarzOrderStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => TarzOrderStatus.preparing,
      ),
      deliveryMethod: TarzDeliveryMethod.values.firstWhere(
        (m) => m.name == json['deliveryMethod'],
        orElse: () => TarzDeliveryMethod.pickup,
      ),
      totalManat: (json['totalManat'] as num?)?.toDouble() ?? 0,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      userId: json['userId']?.toString(),
      paymentStatus: json['paymentStatus']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      postalCode: json['postalCode']?.toString(),
      phone: json['phone']?.toString(),
      fromBackend: json['fromBackend'] == true,
    );
  }
}

/// Checkout form nəticəsi.
class TarzCheckoutRequest {
  const TarzCheckoutRequest({
    required this.deliveryMethod,
    this.address,
    this.city,
    this.postalCode,
    this.phone,
    this.pickupBranch,
    this.isGiftWrapped = false,
  });

  final TarzDeliveryMethod deliveryMethod;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? phone;
  final String? pickupBranch;
  final bool isGiftWrapped;
}

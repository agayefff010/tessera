import 'package:flutter/foundation.dart';

import '../../services/auth_storage.dart';
import '../../services/order_service.dart';
import '../../services/order_storage.dart';
import '../models/tarz_order.dart';

/// Sifarişlər — cari istifadəçiyə uyğun, API əsas mənbə + lokal optimistik.
class TarzOrdersController extends ChangeNotifier {
  TarzOrdersController._();

  static final TarzOrdersController instance = TarzOrdersController._();

  final OrderService _service = OrderService();
  final OrderStorage _storage = OrderStorage.instance;

  final List<TarzOrder> _orders = [];
  bool _initialized = false;
  bool _loading = false;
  String? _currentUserId;

  List<TarzOrder> get orders => List.unmodifiable(_orders);
  bool get isLoading => _loading;

  Future<String?> _resolveUserId() async {
    final loggedIn = await AuthStorage.instance.isLoggedIn();
    if (!loggedIn) return null;
    final user = await AuthStorage.instance.getUser();
    return user?.id;
  }

  Future<void> ensureLoaded() async {
    final userId = await _resolveUserId();
    // İstifadəçi dəyişibsə və ya hələ yüklənməyibsə — yenidən yüklə.
    if (_initialized && userId == _currentUserId) return;
    await _reloadFor(userId);
  }

  Future<void> reload() async {
    final userId = await _resolveUserId();
    await _reloadFor(userId);
  }

  Future<void> _reloadFor(String? userId) async {
    _loading = true;
    if (userId != _currentUserId) {
      _orders.clear();
      _currentUserId = userId;
    }
    notifyListeners();

    try {
      // Qonaq (login olmayıb) — sifariş göstərmirik.
      if (userId == null) {
        _orders.clear();
        _initialized = true;
        return;
      }

      final local = await _storage.load(userId: userId);
      _orders
        ..clear()
        ..addAll(local);

      final remote = await _service.fetchRemoteOrders();
      if (remote != null) {
        // API cari istifadəçinin sifarişlərinin əsas mənbəyidir.
        _mergeRemote(remote);
        await _persist(userId);
      }

      _initialized = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// API sifarişləri + hələ backend-ə düşməmiş lokal optimistik sifarişlər.
  void _mergeRemote(List<TarzOrder> remote) {
    final byId = <String, TarzOrder>{};
    for (final o in _orders) {
      if (!o.fromBackend) byId[o.id] = o;
    }
    for (final order in remote) {
      byId[order.id] = order;
    }
    _orders
      ..clear()
      ..addAll(byId.values)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _persist(String? userId) async {
    try {
      await _storage.saveAll(_orders, userId: userId);
    } catch (_) {
      // Saxlama uğursuz olsa da yaddaşdakı state qalır.
    }
  }

  Future<TarzOrder> placeOrder({
    required TarzCheckoutRequest request,
    required double totalManat,
    required int itemCount,
  }) async {
    final userId = _currentUserId ?? await _resolveUserId();
    _currentUserId = userId;

    var order = await _service.checkout(
      request: request,
      totalManat: totalManat,
      itemCount: itemCount,
    );

    order ??= _service.createLocalOrder(
      request: request,
      totalManat: totalManat,
      itemCount: itemCount,
    );

    await _storage.addOrder(order, userId: userId);
    _orders.removeWhere((o) => o.id == order!.id);
    _orders.insert(0, order);
    _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
    return order;
  }

  /// Çıxışda çağırılır — yaddaşdakı sifarişləri təmizləyir.
  void clearSession() {
    _orders.clear();
    _initialized = false;
    _currentUserId = null;
    notifyListeners();
  }
}

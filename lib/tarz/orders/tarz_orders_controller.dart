import 'package:flutter/foundation.dart';

import '../../services/order_service.dart';
import '../../services/order_storage.dart';
import '../models/tarz_order.dart';

/// Sifarişlər — API + lokal sinxron.
class TarzOrdersController extends ChangeNotifier {
  TarzOrdersController._();

  static final TarzOrdersController instance = TarzOrdersController._();

  final OrderService _service = OrderService();
  final OrderStorage _storage = OrderStorage.instance;

  final List<TarzOrder> _orders = [];
  bool _initialized = false;
  bool _loading = false;

  List<TarzOrder> get orders => List.unmodifiable(_orders);
  bool get isLoading => _loading;

  Future<void> ensureLoaded() async {
    if (_initialized) return;
    await reload();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();

    try {
      final local = await _storage.load();
      _orders
        ..clear()
        ..addAll(local);

      final remote = await _service.fetchRemoteOrders();
      if (remote.isNotEmpty) {
        _mergeRemote(remote);
      }

      _initialized = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _mergeRemote(List<TarzOrder> remote) {
    final byId = {for (final o in _orders) o.id: o};
    for (final order in remote) {
      byId[order.id] = order;
    }
    _orders
      ..clear()
      ..addAll(byId.values)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<TarzOrder> placeOrder({
    required TarzCheckoutRequest request,
    required double totalManat,
    required int itemCount,
  }) async {
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

    await _storage.addOrder(order);
    _orders.removeWhere((o) => o.id == order!.id);
    _orders.insert(0, order);
    notifyListeners();
    return order;
  }
}

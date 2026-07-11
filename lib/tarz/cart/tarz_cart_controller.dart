import 'package:flutter/foundation.dart';

import '../../services/auth_storage.dart';
import '../../services/cart_service.dart';
import '../../services/cart_storage.dart';
import '../data/cart_mapper.dart';
import '../data/tarz_product_assets.dart';
import '../models/tarz_cart_item.dart';
import '../models/tarz_product_preview.dart';
import 'tarz_price_utils.dart';

/// Səbət — lokal saxlama + API sinxronizasiya (login olduqda).
class TarzCartController extends ChangeNotifier {
  TarzCartController._();

  static final TarzCartController instance = TarzCartController._();

  static const double giftWrapFeeManat = 10;

  final CartStorage _storage = CartStorage.instance;
  final CartService _service = CartService();

  final List<TarzCartItem> _items = [];
  CartServerTotals? _serverTotals;

  bool _initialized = false;
  bool _loading = false;

  List<TarzCartItem> get items => List.unmodifiable(_items);

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => _items.isEmpty;

  bool get isLoading => _loading;

  String get itemCountLabel {
    final n = totalQuantity;
    if (n == 0) return '0 məhsul';
    if (n == 1) return '1 məhsul';
    return '$n məhsul';
  }

  Future<void> ensureLoaded() async {
    if (_initialized) return;
    await reload();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();

    try {
      final local = await _storage.load();
      _items
        ..clear()
        ..addAll(local);
      _serverTotals = null;

      final remote = await _service.fetchCart();
      if (remote != null) {
        _items
          ..clear()
          ..addAll(remote.items);
        _serverTotals = remote.totals;
        await _storage.save(_items);
      }

      _initialized = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addFromProduct(
    TarzProductPreview product, {
    required String size,
    String? color,
    String? vendor,
  }) async {
    await ensureLoaded();

    final productId = product.id;
    final lineId = CartMapper.lineId(
      productId: productId,
      size: size,
      color: color,
    );

    final price = TarzPriceUtils.parseManat(product.priceLabel);
    final original = product.originalPriceLabel != null
        ? TarzPriceUtils.parseManat(product.originalPriceLabel!)
        : null;

    final index = _items.indexWhere((e) => e.id == lineId);
    if (index >= 0) {
      final existing = _items[index];
      await updateQuantity(lineId, existing.quantity + 1);
      return;
    }

    _items.add(
      TarzCartItem(
        id: lineId,
        productId: productId,
        title: product.title,
        brand: product.brand ?? 'Tessera',
        priceLabel: product.priceLabel,
        imageAsset: product.imageAsset ?? TarzProductAssets.nikeV5Rnr,
        imageUrl: product.imageUrl,
        originalPriceLabel: product.originalPriceLabel,
        badgeLabel: product.badgeLabel,
        quantity: 1,
        priceManat: price,
        originalPriceManat: original,
        size: size,
        color: color,
        vendor: vendor,
      ),
    );
    _serverTotals = null;
    notifyListeners();

    await _persistLocal();
    await _syncAdd(productId);
  }

  Future<void> updateQuantity(String id, int quantity) async {
    if (quantity < 1) return;
    final index = _items.indexWhere((e) => e.id == id);
    if (index < 0) return;

    final existing = _items[index];
    _items[index] = TarzCartItem(
      id: existing.id,
      productId: existing.productId,
      title: existing.title,
      brand: existing.brand,
      priceLabel: existing.priceLabel,
      imageAsset: existing.imageAsset,
      imageUrl: existing.imageUrl,
      originalPriceLabel: existing.originalPriceLabel,
      badgeLabel: existing.badgeLabel,
      quantity: quantity,
      priceManat: existing.priceManat,
      originalPriceManat: existing.originalPriceManat,
      size: existing.size,
      color: existing.color,
      vendor: existing.vendor,
    );
    _serverTotals = null;
    notifyListeners();

    await _persistLocal();
    try {
      if (await AuthStorage.instance.isLoggedIn()) {
        await _service.updateQuantity(
          productId: existing.productId,
          quantity: quantity,
        );
        await _refreshFromApi();
      }
    } catch (_) {}
  }

  Future<void> incrementQuantity(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index < 0) return;
    await updateQuantity(id, _items[index].quantity + 1);
  }

  Future<void> decrementQuantity(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index < 0) return;
    final qty = _items[index].quantity;
    if (qty <= 1) {
      await removeItem(id);
      return;
    }
    await updateQuantity(id, qty - 1);
  }

  Future<void> removeItem(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index < 0) return;
    final productId = _items[index].productId;

    _items.removeAt(index);
    _serverTotals = null;
    notifyListeners();

    await _persistLocal();
    try {
      if (await AuthStorage.instance.isLoggedIn()) {
        await _service.removeProduct(productId);
        await _refreshFromApi();
      }
    } catch (_) {}
  }

  Future<void> clear() async {
    _items.clear();
    _serverTotals = null;
    notifyListeners();

    await _storage.clear();
    try {
      if (await AuthStorage.instance.isLoggedIn()) {
        await _service.clearCart();
      }
    } catch (_) {}
  }

  TarzCartSummary buildSummary({bool includeGiftWrap = true}) {
    if (_items.isEmpty) {
      return const TarzCartSummary(
        itemCountLabel: '0 məhsul',
        subtotalLabel: '0₼',
        discountLabel: '0₼',
        giftWrapLabel: '+0₼',
        totalLabel: '0₼',
        strikethroughTotalLabel: '0₼',
        discountManat: 0,
        giftWrapManat: 0,
        totalManat: 0,
        subtotalManat: 0,
        itemsSubtotalManat: 0,
        shippingManat: 0,
      );
    }

    final server = _serverTotals;
    if (server?.total != null) {
      final gift = includeGiftWrap ? giftWrapFeeManat : 0.0;
      final shipping = server!.shipping ?? 0;
      final itemsSubtotal = server.subtotal ?? _calcItemsSubtotal();
      final discount = server.discount ?? _calcDiscount();
      final baseTotal = server.total ?? (itemsSubtotal - discount + shipping);
      final total = baseTotal + gift;

      return TarzCartSummary(
        itemCountLabel: itemCountLabel,
        subtotalLabel: TarzPriceUtils.formatManat(itemsSubtotal + discount),
        discountLabel: discount > 0
            ? '-${TarzPriceUtils.formatManat(discount).replaceAll('₼', '')}₼'
            : '0₼',
        giftWrapLabel:
            '+${TarzPriceUtils.formatManat(gift).replaceAll('₼', '')}₼',
        totalLabel: TarzPriceUtils.formatManat(total),
        strikethroughTotalLabel:
            TarzPriceUtils.formatManat(itemsSubtotal + discount),
        discountManat: discount,
        giftWrapManat: gift,
        totalManat: total,
        subtotalManat: itemsSubtotal + discount,
        itemsSubtotalManat: itemsSubtotal,
        shippingManat: shipping,
      );
    }

    return _buildLocalSummary(includeGiftWrap: includeGiftWrap);
  }

  TarzCartSummary _buildLocalSummary({required bool includeGiftWrap}) {
    var subtotalOriginal = 0.0;
    var itemsCurrent = 0.0;

    for (final item in _items) {
      final unitOriginal = item.originalPriceManat ?? item.priceManat;
      subtotalOriginal += unitOriginal * item.quantity;
      itemsCurrent += item.priceManat * item.quantity;
    }

    const shipping = 0.0;
    final discountAmount = subtotalOriginal - itemsCurrent;
    final gift = includeGiftWrap ? giftWrapFeeManat : 0.0;
    final total = itemsCurrent + gift + shipping;

    return TarzCartSummary(
      itemCountLabel: itemCountLabel,
      subtotalLabel: TarzPriceUtils.formatManat(subtotalOriginal),
      discountLabel: discountAmount > 0
          ? '-${TarzPriceUtils.formatManat(discountAmount).replaceAll('₼', '')}₼'
          : '0₼',
      giftWrapLabel:
          '+${TarzPriceUtils.formatManat(gift).replaceAll('₼', '')}₼',
      totalLabel: TarzPriceUtils.formatManat(total),
      strikethroughTotalLabel: TarzPriceUtils.formatManat(subtotalOriginal),
      discountManat: discountAmount,
      giftWrapManat: gift,
      totalManat: total,
      subtotalManat: subtotalOriginal,
      itemsSubtotalManat: itemsCurrent,
      shippingManat: shipping,
    );
  }

  double _calcItemsSubtotal() {
    return _items.fold(0.0, (sum, i) => sum + i.priceManat * i.quantity);
  }

  double _calcDiscount() {
    var original = 0.0;
    var current = 0.0;
    for (final item in _items) {
      final unitOriginal = item.originalPriceManat ?? item.priceManat;
      original += unitOriginal * item.quantity;
      current += item.priceManat * item.quantity;
    }
    return original - current;
  }

  Future<void> _persistLocal() => _storage.save(_items);

  Future<void> _syncAdd(String productId) async {
    try {
      if (await AuthStorage.instance.isLoggedIn()) {
        await _service.addProduct(productId: productId);
        await _refreshFromApi();
      }
    } catch (_) {}
  }

  Future<void> _refreshFromApi() async {
    final remote = await _service.fetchCart();
    if (remote == null) return;
    _items
      ..clear()
      ..addAll(remote.items);
    _serverTotals = remote.totals;
    await _storage.save(_items);
    notifyListeners();
  }

  @visibleForTesting
  void resetForTest() {
    _items.clear();
    _serverTotals = null;
    _initialized = false;
    _loading = false;
  }
}

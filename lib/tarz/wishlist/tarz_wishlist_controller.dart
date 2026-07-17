import 'package:flutter/foundation.dart';

import '../../services/wishlist_service.dart';
import '../../services/wishlist_storage.dart';
import '../models/tarz_product_preview.dart';

/// Seçilmişlər — lokal saxlama + API sinxronizasiya (login olduqda).
class TarzWishlistController extends ChangeNotifier {
  TarzWishlistController._();

  static final TarzWishlistController instance = TarzWishlistController._();

  final WishlistStorage _storage = WishlistStorage.instance;
  final WishlistService _service = WishlistService();

  final List<TarzProductPreview> _items = [];
  final Map<String, ValueNotifier<bool>> _favoriteFlags = {};

  bool _initialized = false;
  bool _loading = false;

  List<TarzProductPreview> get items => List.unmodifiable(_items);

  int get count => _items.length;

  bool get isEmpty => _items.isEmpty;

  bool get isLoading => _loading;

  bool contains(String productId) =>
      _items.any((item) => item.id == productId);

  /// Per-product favorite flag — only listeners for this id rebuild on toggle.
  ValueListenable<bool> favoriteListenable(String productId) {
    return _favoriteFlags.putIfAbsent(
      productId,
      () => ValueNotifier<bool>(contains(productId)),
    );
  }

  void _syncFavoriteFlag(String productId) {
    final flag = _favoriteFlags[productId];
    if (flag == null) return;
    final next = contains(productId);
    if (flag.value != next) flag.value = next;
  }

  void _syncAllFavoriteFlags() {
    for (final entry in _favoriteFlags.entries) {
      final next = contains(entry.key);
      if (entry.value.value != next) entry.value.value = next;
    }
  }

  /// İlk açılışda lokal + API yükləməsi.
  Future<void> ensureLoaded() async {
    if (_initialized) return;
    await reload();
  }

  /// Siyahını yenidən yükləyir (ekran refresh / login sonrası).
  Future<void> reload() async {
    _loading = true;
    notifyListeners();

    try {
      final local = await _storage.load();
      _items
        ..clear()
        ..addAll(local);

      final remote = await _service.fetchWishlist();
      if (remote != null) {
        _items
          ..clear()
          ..addAll(remote);
        await _storage.save(_items);
      }

      _initialized = true;
      _syncAllFavoriteFlags();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Favoriyə əlavə et — optimistic UI.
  Future<void> add(TarzProductPreview product) async {
    await ensureLoaded();
    if (contains(product.id)) return;

    _items.add(product);
    _syncFavoriteFlag(product.id);
    notifyListeners();

    await _storage.save(_items);
    try {
      await _service.addProduct(product.id);
    } catch (_) {
      // Lokal state saxlanılıb.
    }
  }

  /// Favoridən sil — optimistic UI.
  Future<void> remove(String productId) async {
    await ensureLoaded();
    _items.removeWhere((item) => item.id == productId);
    _syncFavoriteFlag(productId);
    notifyListeners();

    await _storage.save(_items);
    try {
      await _service.removeProduct(productId);
    } catch (_) {
      // Lokal state saxlanılıb.
    }
  }

  /// Toggle — `true` = əlavə edildi, `false` = silindi.
  Future<bool> toggle(TarzProductPreview product) async {
    if (contains(product.id)) {
      await remove(product.id);
      return false;
    }
    await add(product);
    return true;
  }

  Future<void> clear() async {
    _items.clear();
    _syncAllFavoriteFlags();
    notifyListeners();
    await _storage.clear();
  }

  @visibleForTesting
  void resetForTest() {
    _items.clear();
    for (final flag in _favoriteFlags.values) {
      flag.dispose();
    }
    _favoriteFlags.clear();
    _initialized = false;
    _loading = false;
  }
}

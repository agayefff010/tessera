import 'package:flutter/foundation.dart';

import '../data/tarz_mock_catalog.dart';
import '../models/tarz_product_preview.dart';

/// Seçilmişlər vəziyyəti — əlavə/silmə, real-time UI yeniləməsi.
class TarzWishlistController extends ChangeNotifier {
  TarzWishlistController._();

  static final TarzWishlistController instance = TarzWishlistController._();

  final List<TarzProductPreview> _items = [];

  bool _initialized = false;

  List<TarzProductPreview> get items => List.unmodifiable(_items);

  int get count => _items.length;

  bool get isEmpty => _items.isEmpty;

  void _ensureSeedData() {
    if (_initialized) return;
    _initialized = true;
    // TODO: API-dən seçilmişlər siyahısı ilə əvəz et.
    _items.addAll(TarzMockCatalog.homeNewProductsGrid().take(4));
    notifyListeners();
  }

  void ensureLoaded() => _ensureSeedData();

  bool contains(String productId) =>
      _items.any((item) => item.id == productId);

  void add(TarzProductPreview product) {
    _ensureSeedData();
    if (contains(product.id)) return;
    _items.add(product);
    notifyListeners();
  }

  void remove(String productId) {
    _ensureSeedData();
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  void toggle(TarzProductPreview product) {
    if (contains(product.id)) {
      remove(product.id);
    } else {
      add(product);
    }
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../tarz/models/tarz_cart_item.dart';
import '../tarz/data/cart_mapper.dart';

/// Qonaq/offline səbət saxlanması.
class CartStorage {
  CartStorage._();

  static final CartStorage instance = CartStorage._();

  static const _key = 'cart_items';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String? _memoryJson;

  Future<List<TarzCartItem>> load() async {
    String? raw;
    try {
      raw = await _storage.read(key: _key);
    } catch (_) {}
    raw ??= _memoryJson;
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CartMapper.itemFromJson)
          .where((i) => i.productId.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<TarzCartItem> items) async {
    final json = jsonEncode(items.map(CartMapper.itemToJson).toList());
    try {
      await _storage.write(key: _key, value: json);
      _memoryJson = null;
    } catch (e) {
      if (kDebugMode) {
        _memoryJson = json;
      } else {
        rethrow;
      }
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } catch (_) {}
    _memoryJson = null;
  }
}

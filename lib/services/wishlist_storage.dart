import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../tarz/models/tarz_product_preview.dart';

/// Seçilmişlər siyahısının cihazda saxlanması (qonaq + offline).
class WishlistStorage {
  WishlistStorage._();

  static final WishlistStorage instance = WishlistStorage._();

  static const _key = 'wishlist_products';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String? _memoryJson;

  Future<List<TarzProductPreview>> load() async {
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
          .map(_productFromJson)
          .where((p) => p.id.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<TarzProductPreview> items) async {
    final json = jsonEncode(items.map(_productToJson).toList());
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

  static Map<String, dynamic> _productToJson(TarzProductPreview p) => {
        'id': p.id,
        'title': p.title,
        'priceLabel': p.priceLabel,
        if (p.brand != null) 'brand': p.brand,
        if (p.imageUrl != null) 'imageUrl': p.imageUrl,
        if (p.imageAsset != null) 'imageAsset': p.imageAsset,
        if (p.badgeLabel != null) 'badgeLabel': p.badgeLabel,
        if (p.originalPriceLabel != null) 'originalPriceLabel': p.originalPriceLabel,
        if (p.subtitle != null) 'subtitle': p.subtitle,
      };

  static TarzProductPreview _productFromJson(Map<String, dynamic> json) {
    return TarzProductPreview(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      priceLabel: json['priceLabel']?.toString() ?? '',
      brand: json['brand']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      imageAsset: json['imageAsset']?.toString(),
      badgeLabel: json['badgeLabel']?.toString(),
      originalPriceLabel: json['originalPriceLabel']?.toString(),
      subtitle: json['subtitle']?.toString(),
    );
  }
}

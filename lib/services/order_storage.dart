import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../tarz/models/tarz_order.dart';

/// Lokal sifarişlər saxlanması.
class OrderStorage {
  OrderStorage._();

  static final OrderStorage instance = OrderStorage._();

  static const _key = 'tarz_orders';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Sifarişlər istifadəçiyə görə ayrılır — hesablar arası sızma olmasın.
  static String _keyFor(String? userId) =>
      (userId == null || userId.isEmpty) ? _key : '${_key}_$userId';

  final Map<String, String> _memoryJson = {};

  Future<List<TarzOrder>> load({String? userId}) async {
    final key = _keyFor(userId);
    String? raw;
    try {
      raw = await _storage.read(key: key);
    } catch (_) {}
    raw ??= _memoryJson[key];
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(TarzOrder.fromJson)
          .where((o) => o.id.isNotEmpty)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveAll(List<TarzOrder> orders, {String? userId}) async {
    final key = _keyFor(userId);
    final sorted = List<TarzOrder>.from(orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final json = jsonEncode(sorted.map((o) => o.toJson()).toList());
    try {
      await _storage.write(key: key, value: json);
      _memoryJson.remove(key);
    } catch (e) {
      if (kDebugMode) {
        _memoryJson[key] = json;
      } else {
        rethrow;
      }
    }
  }

  Future<void> addOrder(TarzOrder order, {String? userId}) async {
    final existing = await load(userId: userId);
    final withoutDup =
        existing.where((o) => o.id != order.id).toList(growable: true);
    withoutDup.insert(0, order);
    await saveAll(withoutDup, userId: userId);
  }

  Future<void> clear({String? userId}) async {
    final key = _keyFor(userId);
    try {
      await _storage.delete(key: key);
    } catch (_) {}
    _memoryJson.remove(key);
  }

  static String generateLocalId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final suffix = Random().nextInt(9000) + 1000;
    return 'TES-$ts-$suffix';
  }
}

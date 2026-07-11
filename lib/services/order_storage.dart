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

  String? _memoryJson;

  Future<List<TarzOrder>> load() async {
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
          .map(TarzOrder.fromJson)
          .where((o) => o.id.isNotEmpty)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveAll(List<TarzOrder> orders) async {
    final sorted = List<TarzOrder>.from(orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final json = jsonEncode(sorted.map((o) => o.toJson()).toList());
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

  Future<void> addOrder(TarzOrder order) async {
    final existing = await load();
    final withoutDup =
        existing.where((o) => o.id != order.id).toList(growable: true);
    withoutDup.insert(0, order);
    await saveAll(withoutDup);
  }

  static String generateLocalId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final suffix = Random().nextInt(9000) + 1000;
    return 'TES-$ts-$suffix';
  }
}

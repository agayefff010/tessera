import '../../config/api_config.dart';
import '../../services/api_client.dart';
import '../../services/api_exception.dart';
import '../models/tarz_store_preview.dart';
import '../models/tarz_vendor.dart';

/// Vendor / mağaza API.
class VendorRepository {
  VendorRepository({ApiClient? client})
      : _client = client ?? ApiClient(),
        _ownsClient = client == null;

  final ApiClient _client;
  final bool _ownsClient;

  /// `GET /vendors/slug/:slug`
  Future<TarzVendor> fetchBySlug(String slug) async {
    final trimmed = slug.trim();
    if (trimmed.isEmpty) {
      throw const ApiException('Mağaza tapılmadı');
    }
    final body = await _client.get('${ApiConfig.vendorsSlugPath}/$trimmed');
    final vendor = _fromResponse(body);
    if (vendor == null) {
      throw const ApiException('Mağaza tapılmadı');
    }
    return vendor;
  }

  /// Publika açıq vendor siyahısı yoxdur — məhsullardan unikal mağazalar.
  Future<List<TarzStorePreview>> fetchStorePreviews({int limit = 12}) async {
    final byId = <String, TarzStorePreview>{};

    for (var page = 1; page <= 5 && byId.length < limit * 2; page++) {
      final body = await _client.get(
        '/products',
        query: {
          'page': page.toString(),
          'limit': '50',
        },
      );
      final data = body['data'];
      if (data is! List || data.isEmpty) break;

      for (final item in data) {
        if (item is! Map) continue;
        final vendor = item['vendorId'];
        if (vendor is! Map) continue;
        final id = vendor['_id']?.toString() ?? vendor['id']?.toString();
        final name = vendor['name']?.toString();
        final slug = vendor['slug']?.toString();
        if (id == null || id.isEmpty || name == null || name.isEmpty) continue;
        if (slug == null || slug.isEmpty) continue;
        byId.putIfAbsent(
          id,
          () => TarzStorePreview(
            id: id,
            name: name,
            slug: slug,
          ),
        );
      }

      if (data.length < 50) break;
    }

    return byId.values.take(limit).toList();
  }

  static TarzVendor? _fromResponse(Map<String, dynamic> body) {
    final raw = body['data'];
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);

    final id = json['_id']?.toString() ?? json['id']?.toString();
    final name = json['name']?.toString();
    final slug = json['slug']?.toString();
    if (id == null || id.isEmpty || name == null || name.isEmpty) return null;
    if (slug == null || slug.isEmpty) return null;

    final addresses = <String>[];
    final rawAddresses = json['storeAddresses'];
    if (rawAddresses is List) {
      for (final a in rawAddresses) {
        final s = a?.toString().trim();
        if (s != null && s.isNotEmpty) addresses.add(s);
      }
    }

    final delivery = json['deliveryAvailable'];

    return TarzVendor(
      id: id,
      name: name,
      slug: slug,
      profileImageUrl: _nonEmpty(json['profileImage'] ?? json['logo']),
      description: _nonEmpty(json['description']),
      address: _nonEmpty(json['address']),
      openHours: _nonEmpty(json['openHours']),
      phone: _nonEmpty(json['phone']),
      storeAddresses: addresses,
      deliveryAvailable: delivery is bool ? delivery : null,
      companyName: _nonEmpty(json['companyName']),
    );
  }

  static String? _nonEmpty(dynamic value) {
    final s = value?.toString().trim();
    if (s == null || s.isEmpty) return null;
    return s;
  }

  void dispose() {
    if (_ownsClient) _client.dispose();
  }
}

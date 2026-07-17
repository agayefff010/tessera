import '../models/tarz_home_banner.dart';

/// Backend advertisement / banner JSON → UI modeli.
abstract final class BannerMapper {
  static List<TarzHomeBanner> listFromResponse(Map<String, dynamic> body) {
    final raw = body['data'] ?? body['banners'] ?? body['items'];
    if (raw is! List) return const [];

    final banners = <TarzHomeBanner>[];
    for (final item in raw) {
      final map = _asMap(item);
      if (map == null) continue;
      final banner = fromJson(map);
      if (banner != null) banners.add(banner);
    }

    return banners;
  }

  static TarzHomeBanner? fromJson(Map<String, dynamic> json) {
    final imageUrl = _imageUrl(json);
    if (imageUrl == null || imageUrl.isEmpty) return null;

    if (!_isActive(json)) return null;

    final vendor = _asMap(json['vendorId']);
    final vendorName = vendor?['name']?.toString();
    final vendorId = vendor?['_id']?.toString() ?? vendor?['id']?.toString();
    final vendorSlug = vendor?['slug']?.toString();

    final id = json['_id']?.toString() ??
        json['id']?.toString() ??
        imageUrl;

    return TarzHomeBanner(
      id: id,
      imageUrl: imageUrl,
      title: json['title']?.toString() ??
          json['name']?.toString() ??
          vendorName,
      link: json['link']?.toString() ?? json['url']?.toString(),
      vendorId: vendorId,
      vendorSlug: vendorSlug,
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String? _imageUrl(Map<String, dynamic> json) {
    final direct = json['imageUrl'] ??
        json['image'] ??
        json['bannerImage'] ??
        json['photo'] ??
        json['cover'];
    if (direct is String && direct.isNotEmpty) return direct;

    final images = json['images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is String && first.isNotEmpty) return first;
    }

    return null;
  }

  static bool _isActive(Map<String, dynamic> json) {
    final status = json['status']?.toString().toLowerCase();
    if (status != null && status.isNotEmpty) {
      return status == 'active';
    }
    final active = json['isActive'] ?? json['active'] ?? json['enabled'];
    if (active is bool) return active;
    if (active is num) return active != 0;
    return true;
  }
}

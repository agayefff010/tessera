import '../models/tarz_home_banner.dart';

/// Backend banner JSON → UI modeli.
abstract final class BannerMapper {
  static List<TarzHomeBanner> listFromResponse(Map<String, dynamic> body) {
    final raw = body['data'] ?? body['banners'] ?? body['items'];
    if (raw is! List) return const [];

    final banners = <TarzHomeBanner>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      final banner = fromJson(item);
      if (banner != null) banners.add(banner);
    }

    banners.sort((a, b) => a.id.compareTo(b.id));
    return banners;
  }

  static TarzHomeBanner? fromJson(Map<String, dynamic> json) {
    final imageUrl = _imageUrl(json);
    if (imageUrl == null || imageUrl.isEmpty) return null;

    if (!_isActive(json)) return null;

    final id = json['_id']?.toString() ??
        json['id']?.toString() ??
        imageUrl;

    return TarzHomeBanner(
      id: id,
      imageUrl: imageUrl,
      title: json['title']?.toString() ?? json['name']?.toString(),
      link: json['link']?.toString() ?? json['url']?.toString(),
    );
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
    final active = json['isActive'] ?? json['active'] ?? json['enabled'];
    if (active is bool) return active;
    if (active is num) return active != 0;
    return true;
  }
}

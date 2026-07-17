import 'package:flutter/foundation.dart';

@immutable
class TarzStorePreview {
  const TarzStorePreview({
    required this.id,
    required this.name,
    this.slug,
    this.logoAsset,
    this.logoUrl,
  });

  final String id;
  final String name;

  /// Vendor slug — mağaza səhifəsi üçün (`/vendors/slug/:slug`).
  final String? slug;

  /// Tam enlikli loqo kartı; boşdursa mətn kartı göstərilir.
  final String? logoAsset;

  /// Backend-dən gələn loqo URL-i.
  final String? logoUrl;
}

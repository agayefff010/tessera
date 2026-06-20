import 'package:flutter/foundation.dart';

@immutable
class TarzStorePreview {
  const TarzStorePreview({
    required this.id,
    required this.name,
    this.logoAsset,
  });

  final String id;
  final String name;

  /// Tam enlikli loqo kartı; boşdursa mətn kartı göstərilir.
  final String? logoAsset;
}

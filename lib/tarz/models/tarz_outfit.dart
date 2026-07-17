import 'package:flutter/foundation.dart';

import 'tarz_product_preview.dart';

/// Outfit generate-dəki bir element (ayaqqabı / üst / çanta / anchor).
@immutable
class TarzOutfitItem {
  const TarzOutfitItem({
    required this.role,
    required this.product,
  });

  /// Backend role: `shoes`, `bag`, `outerwear`, `full-body`, …
  final String role;
  final TarzProductPreview product;

  bool get isShoes => role == 'shoes';
  bool get isBag => role == 'bag';
  bool get isOuterwear =>
      role == 'outerwear' || role == 'jacket' || role == 'tops' || role == 'top';
  bool get isAnchorBody =>
      role == 'full-body' || role == 'dress' || role == 'bottoms' || role == 'pants';
}

@immutable
class TarzGeneratedOutfit {
  const TarzGeneratedOutfit({
    required this.items,
    this.anchorProduct,
    this.anchorRole,
  });

  /// Yalnız `items[]` (anchor yoxdur).
  final List<TarzOutfitItem> items;
  final TarzProductPreview? anchorProduct;
  final String? anchorRole;

  static const empty = TarzGeneratedOutfit(items: []);

  /// Tam obraz: anchor + companions, UI sırası ilə.
  List<TarzOutfitItem> get displayItems {
    final combined = <TarzOutfitItem>[
      ...items,
      if (anchorProduct != null &&
          !items.any((e) => e.product.id == anchorProduct!.id))
        TarzOutfitItem(
          role: anchorRole ?? 'full-body',
          product: anchorProduct!,
        ),
    ];

    TarzOutfitItem? shoes;
    TarzOutfitItem? outerwear;
    TarzOutfitItem? bag;
    TarzOutfitItem? body;
    final rest = <TarzOutfitItem>[];

    for (final item in combined) {
      if (item.isShoes && shoes == null) {
        shoes = item;
      } else if (item.isOuterwear && outerwear == null) {
        outerwear = item;
      } else if (item.isBag && bag == null) {
        bag = item;
      } else if (item.isAnchorBody && body == null) {
        body = item;
      } else {
        rest.add(item);
      }
    }

    return [
      if (shoes != null) shoes,
      if (outerwear != null) outerwear,
      if (bag != null) bag,
      if (body != null) body,
      ...rest,
    ];
  }

  List<TarzOutfitItem> get largeItems {
    final all = displayItems;
    final preferred = <TarzOutfitItem>[
      ...all.where((e) => e.isShoes),
      ...all.where((e) => e.isOuterwear),
    ];
    if (preferred.isNotEmpty) {
      return preferred.take(2).toList();
    }
    return all.take(2).toList();
  }

  List<TarzOutfitItem> get smallItems {
    final largeIds = largeItems.map((e) => e.product.id).toSet();
    return displayItems
        .where((e) => !largeIds.contains(e.product.id))
        .toList();
  }

  String get suggestedName {
    final anchor = anchorProduct?.title.trim();
    if (anchor != null && anchor.isNotEmpty) return '$anchor kombin';
    if (displayItems.isNotEmpty) {
      return '${displayItems.first.product.title} kombin';
    }
    return 'Kombin';
  }

  /// Eyni rolu saxlayaraq məhsulu dəyişir.
  TarzGeneratedOutfit replaceProduct(
    String productId,
    TarzProductPreview replacement,
  ) {
    if (productId.isEmpty || replacement.id.isEmpty) return this;

    final newItems = items
        .map(
          (e) => e.product.id == productId
              ? TarzOutfitItem(role: e.role, product: replacement)
              : e,
        )
        .toList();

    final newAnchor = anchorProduct?.id == productId
        ? replacement
        : anchorProduct;

    return TarzGeneratedOutfit(
      items: newItems,
      anchorProduct: newAnchor,
      anchorRole: anchorRole,
    );
  }
}

/// Outfit role → UI başlığı.
abstract final class TarzOutfitRoleLabels {
  static String titleAz(String role) {
    switch (role) {
      case 'shoes':
        return 'Ayaqqabı seç';
      case 'bag':
        return 'Çanta seç';
      case 'outerwear':
      case 'jacket':
      case 'tops':
      case 'top':
        return 'Üst geyim seç';
      case 'full-body':
      case 'dress':
        return 'Geyim seç';
      case 'bottoms':
      case 'pants':
        return 'Alt geyim seç';
      default:
        return 'Məhsul seç';
    }
  }
}

/// `GET /outfits/me` — yadda saxlanmış kombin.
@immutable
class TarzSavedOutfit {
  const TarzSavedOutfit({
    required this.id,
    required this.items,
    this.name,
    this.createdAt,
    this.aiImageUrl,
    this.aiImageStatus,
    this.aiModel,
    this.aiProvider,
  });

  final String id;
  final String? name;
  final List<TarzOutfitItem> items;
  final DateTime? createdAt;
  final String? aiImageUrl;
  final String? aiImageStatus;
  final String? aiModel;
  final String? aiProvider;

  String get title {
    final n = name?.trim();
    if (n != null && n.isNotEmpty) return n;
    if (items.isNotEmpty) return items.first.product.title;
    return 'Kombin';
  }

  List<String> get imageUrls => items
      .map((e) => e.product.imageUrl)
      .whereType<String>()
      .where((u) => u.isNotEmpty)
      .toList();

  bool get hasAiImage => aiImageUrl != null && aiImageUrl!.trim().isNotEmpty;

  TarzSavedOutfit copyWith({
    String? id,
    String? name,
    List<TarzOutfitItem>? items,
    DateTime? createdAt,
    String? aiImageUrl,
    String? aiImageStatus,
    String? aiModel,
    String? aiProvider,
  }) {
    return TarzSavedOutfit(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      aiImageUrl: aiImageUrl ?? this.aiImageUrl,
      aiImageStatus: aiImageStatus ?? this.aiImageStatus,
      aiModel: aiModel ?? this.aiModel,
      aiProvider: aiProvider ?? this.aiProvider,
    );
  }
}

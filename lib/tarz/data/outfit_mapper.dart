import '../models/tarz_outfit.dart';
import '../models/tarz_product_preview.dart';
import 'product_mapper.dart';

/// Outfit API JSON → UI modeli.
abstract final class OutfitMapper {
  static TarzGeneratedOutfit fromResponse(Map<String, dynamic> body) {
    TarzProductPreview? anchorProduct;
    String? anchorRole;
    final anchor = body['anchor'];
    if (anchor is Map<String, dynamic>) {
      anchorRole = anchor['role']?.toString();
      final product = anchor['product'];
      if (product is Map<String, dynamic>) {
        final preview = ProductMapper.fromJson(product);
        if (preview.id.isNotEmpty) anchorProduct = preview;
      }
    }

    final items = parseItems(body['items']);
    if (anchorProduct != null) {
      items.removeWhere((e) => e.product.id == anchorProduct!.id);
    }

    return TarzGeneratedOutfit(
      items: items,
      anchorProduct: anchorProduct,
      anchorRole: anchorRole,
    );
  }

  static List<TarzSavedOutfit> savedListFromResponse(Map<String, dynamic> body) {
    final raw = body['data'] ?? body['outfits'] ?? body['items'];
    if (raw is! List) return const [];
    final result = <TarzSavedOutfit>[];
    for (final entry in raw) {
      if (entry is! Map<String, dynamic>) continue;
      final outfit = savedFromJson(entry);
      if (outfit != null) result.add(outfit);
    }
    return result;
  }

  static TarzSavedOutfit? savedFromJson(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    if (id.isEmpty) return null;

    final items = parseItems(json['items'] ?? json['products']);

    // Anchor ayrıca gələ bilər — siyahıya əlavə et.
    final anchorItem = _parseAnchorItem(json);
    if (anchorItem != null &&
        !items.any((e) => e.product.id == anchorItem.product.id)) {
      items.add(anchorItem);
    }

    final ids = json['productIds'];
    if (ids is List) {
      for (final idRaw in ids) {
        final product = _productFromAny(idRaw);
        if (product == null || product.id.isEmpty) continue;
        if (items.any((e) => e.product.id == product.id)) continue;
        items.add(TarzOutfitItem(role: 'item', product: product));
      }
    }

    return TarzSavedOutfit(
      id: id,
      name: json['name']?.toString() ?? json['title']?.toString(),
      items: items,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      aiImageUrl: json['aiImageUrl']?.toString(),
      aiImageStatus: json['aiImageStatus']?.toString(),
      aiModel: json['aiModel']?.toString(),
      aiProvider: json['aiProvider']?.toString(),
    );
  }

  static TarzOutfitItem? _parseAnchorItem(Map<String, dynamic> json) {
    final anchor = json['anchor'];
    if (anchor is Map<String, dynamic>) {
      final role = anchor['role']?.toString() ?? 'full-body';
      final productJson = anchor['product'];
      if (productJson is Map<String, dynamic>) {
        final product = ProductMapper.fromJson(productJson);
        if (product.id.isNotEmpty) {
          return TarzOutfitItem(role: role, product: product);
        }
      }
      final productId = anchor['product']?.toString() ??
          anchor['productId']?.toString() ??
          '';
      if (productId.isNotEmpty) {
        return TarzOutfitItem(
          role: role,
          product: TarzProductPreview(
            id: productId,
            title: 'Məhsul',
            priceLabel: '0₼',
          ),
        );
      }
    }

    final anchorProduct = json['anchorProduct'];
    final role = json['anchorRole']?.toString() ?? 'full-body';
    if (anchorProduct is Map<String, dynamic>) {
      final product = ProductMapper.fromJson(anchorProduct);
      if (product.id.isNotEmpty) {
        return TarzOutfitItem(role: role, product: product);
      }
    }
    if (anchorProduct is String && anchorProduct.isNotEmpty) {
      return TarzOutfitItem(
        role: role,
        product: TarzProductPreview(
          id: anchorProduct,
          title: 'Məhsul',
          priceLabel: '0₼',
        ),
      );
    }

    final anchorProductId = json['anchorProductId']?.toString();
    if (anchorProductId != null && anchorProductId.isNotEmpty) {
      return TarzOutfitItem(
        role: role,
        product: TarzProductPreview(
          id: anchorProductId,
          title: 'Məhsul',
          priceLabel: '0₼',
        ),
      );
    }

    return null;
  }

  static List<TarzOutfitItem> parseItems(dynamic raw) {
    final items = <TarzOutfitItem>[];
    if (raw is! List) return items;

    for (final entry in raw) {
      if (entry is String) {
        if (entry.isEmpty) continue;
        items.add(
          TarzOutfitItem(
            role: 'item',
            product: TarzProductPreview(
              id: entry,
              title: 'Məhsul',
              priceLabel: '0₼',
            ),
          ),
        );
        continue;
      }
      if (entry is! Map<String, dynamic>) continue;

      final role = entry['role']?.toString() ?? 'item';
      final product = _productFromAny(entry['product']) ??
          _productFromAny(entry['productId']) ??
          _productFromAny(entry['_id']);
      if (product != null && product.id.isNotEmpty) {
        items.add(TarzOutfitItem(role: role, product: product));
        continue;
      }

      final productId = _idFromAny(entry['product']) ??
          _idFromAny(entry['productId']) ??
          _idFromAny(entry['_id']) ??
          '';
      if (productId.isEmpty) continue;
      items.add(
        TarzOutfitItem(
          role: role,
          product: TarzProductPreview(
            id: productId,
            title: entry['name']?.toString() ?? 'Məhsul',
            priceLabel: '0₼',
            imageUrl:
                entry['image']?.toString() ?? entry['imageUrl']?.toString(),
          ),
        ),
      );
    }
    return items;
  }

  static TarzProductPreview? _productFromAny(dynamic value) {
    if (value is Map<String, dynamic>) {
      final product = ProductMapper.fromJson(value);
      return product.id.isEmpty ? null : product;
    }
    final id = _idFromAny(value);
    if (id == null || id.isEmpty) return null;
    return TarzProductPreview(
      id: id,
      title: 'Məhsul',
      priceLabel: '0₼',
    );
  }

  static String? _idFromAny(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return value['_id']?.toString() ?? value['id']?.toString();
    }
    final s = value.toString();
    return s.isEmpty ? null : s;
  }

  /// `POST /outfits` body.
  /// Anchor ayrıca göndərilir; `items` yalnız companion-lardır (shoes/bag/…).
  /// Backend: item role == anchorRole (məs. full-body) → xəta.
  static Map<String, dynamic> toSaveBody(
    TarzGeneratedOutfit outfit, {
    String? name,
  }) {
    final anchorId = outfit.anchorProduct?.id;
    final anchorRole = outfit.anchorRole;

    final allProductIds = outfit.displayItems
        .map((e) => e.product.id)
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    final payloadItems = outfit.displayItems
        .where((e) => e.product.id.isNotEmpty)
        .where((e) => anchorId == null || e.product.id != anchorId)
        .where((e) {
          if (anchorRole == null || anchorRole.isEmpty) {
            if (anchorId != null) return !e.isAnchorBody;
            return true;
          }
          return e.role != anchorRole && !e.isAnchorBody;
        })
        .map(
          (e) => <String, dynamic>{
            'productId': e.product.id,
            'product': e.product.id,
            'role': e.role,
          },
        )
        .toList();

    return <String, dynamic>{
      'name': (name ?? outfit.suggestedName).trim(),
      'items': payloadItems,
      'productIds': allProductIds,
      if (anchorId != null && anchorId.isNotEmpty) ...{
        'anchorProductId': anchorId,
        'anchorProduct': anchorId,
      },
      if (anchorRole != null && anchorRole.isNotEmpty) 'anchorRole': anchorRole,
    };
  }
}

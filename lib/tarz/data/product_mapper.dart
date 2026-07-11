import '../cart/tarz_price_utils.dart';
import '../models/tarz_product_detail.dart';
import '../models/tarz_product_preview.dart';

/// Backend məhsul JSON → UI modeli.
abstract final class ProductMapper {  static TarzProductPreview fromJson(Map<String, dynamic> json) {
    final price = (json['price'] as num?)?.toDouble() ?? 0;
    final discount = (json['discountPercent'] as num?)?.toDouble() ?? 0;
    final salePrice = price * (1 - discount / 100);

    String? originalPriceLabel;
    final priceLabel = discount > 0
        ? TarzPriceUtils.formatManatSpaced(salePrice)
        : TarzPriceUtils.formatManatSpaced(price);
    if (discount > 0) {
      originalPriceLabel = TarzPriceUtils.formatManatSpaced(price);
    }

    String? imageUrl;
    final images = json['images'];
    if (images is List && images.isNotEmpty) {
      imageUrl = images.first?.toString();
    }

    String? brand;
    final brandId = json['brandId'];
    if (brandId is Map<String, dynamic>) {
      brand = brandId['name']?.toString();
    }

    String? badgeLabel;
    if (discount > 0) {
      badgeLabel = '-${discount.round()}%';
    }

    return TarzProductPreview(
      id: json['_id']?.toString() ?? '',
      title: json['name']?.toString() ?? '',
      priceLabel: priceLabel,
      originalPriceLabel: originalPriceLabel,
      brand: brand,
      imageUrl: imageUrl,
      badgeLabel: badgeLabel,
      subtitle: json['styleTag']?.toString(),
      categoryId: json['category']?.toString(),
      subcategoryId: json['subcategory']?.toString(),
      genderId: json['gender']?.toString(),
    );
  }

  static List<TarzProductPreview> listFromResponse(Map<String, dynamic> body) {
    final items = body['data'];
    if (items is! List) return const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .where((p) => p.id.isNotEmpty)
        .toList();
  }

  static TarzProductDetail detailFromJson(Map<String, dynamic> json) {
    final preview = fromJson(json);

    final images = json['images'];
    final imageUrls = <String>[];
    if (images is List) {
      for (final img in images) {
        final url = img?.toString();
        if (url != null && url.isNotEmpty) imageUrls.add(url);
      }
    }
    if (imageUrls.isEmpty && preview.imageUrl != null) {
      imageUrls.add(preview.imageUrl!);
    }

    final sizesRaw = json['sizes'];
    final sizes = <TarzProductSizeOption>[];
    if (sizesRaw is List) {
      for (final entry in sizesRaw) {
        if (entry is! Map<String, dynamic>) continue;
        final size = entry['size']?.toString();
        if (size == null || size.isEmpty) continue;
        sizes.add(
          TarzProductSizeOption(
            size: size,
            stock: (entry['stock'] as num?)?.toInt() ?? 0,
            color: entry['color']?.toString(),
          ),
        );
      }
    }

    final colors = sizes
        .map((s) => s.color)
        .whereType<String>()
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

    String? vendorName;
    final vendorId = json['vendorId'];
    if (vendorId is Map<String, dynamic>) {
      vendorName = vendorId['name']?.toString();
    }

    return TarzProductDetail(
      id: preview.id,
      title: preview.title,
      brand: preview.brand,
      priceLabel: preview.priceLabel,
      originalPriceLabel: preview.originalPriceLabel,
      badgeLabel: preview.badgeLabel,
      imageUrls: imageUrls,
      sizes: sizes,
      colors: colors,
      description: json['description']?.toString(),
      materials: json['materials']?.toString(),
      details: json['details']?.toString(),
      careInstructions: json['careInstructions']?.toString(),
      vendorName: vendorName,
      styleTag: json['styleTag']?.toString(),
      season: json['season']?.toString(),
      preview: preview,
    );
  }

  static TarzProductDetail? detailFromResponse(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is! Map<String, dynamic>) return null;
    return detailFromJson(data);
  }
}

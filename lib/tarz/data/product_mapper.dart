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
      subtitle: _categoryLabel(json) ?? json['styleTag']?.toString(),
      categoryId: _idOrString(json['category']),
      subcategoryId: _idOrString(json['subcategory']),
      genderId: _idOrString(json['gender']),
      slug: json['slug']?.toString(),
    );
  }

  static String? _categoryLabel(Map<String, dynamic> json) {
    final sub = json['subcategory'];
    final cat = json['category'];
    final subName = sub is Map ? sub['name']?.toString() : null;
    final catName = cat is Map ? cat['name']?.toString() : null;
    if (subName != null &&
        subName.isNotEmpty &&
        catName != null &&
        catName.isNotEmpty &&
        subName != catName) {
      return '$catName / $subName';
    }
    if (subName != null && subName.isNotEmpty) return subName;
    if (catName != null && catName.isNotEmpty) return catName;
    return null;
  }

  static String? _idOrString(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return value['_id']?.toString() ?? value['id']?.toString();
    }
    final s = value.toString();
    return s.isEmpty ? null : s;
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
    String? vendorSlug;
    bool? vendorDeliveryAvailable;
    String? vendorAddress;
    String? vendorOpenHours;
    final storeAddresses = <String>[];
    final vendorRaw = json['vendorId'];
    if (vendorRaw is Map) {
      final vendorId = Map<String, dynamic>.from(vendorRaw);
      vendorName = vendorId['name']?.toString();
      vendorSlug = vendorId['slug']?.toString();
      vendorAddress = vendorId['address']?.toString();
      vendorOpenHours = vendorId['openHours']?.toString();
      final delivery = vendorId['deliveryAvailable'];
      if (delivery is bool) {
        vendorDeliveryAvailable = delivery;
      }
      final rawAddresses = vendorId['storeAddresses'];
      if (rawAddresses is List) {
        for (final addr in rawAddresses) {
          final text = addr?.toString().trim();
          if (text != null && text.isNotEmpty) storeAddresses.add(text);
        }
      }
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
      vendorSlug: vendorSlug,
      vendorDeliveryAvailable: vendorDeliveryAvailable,
      vendorAddress: vendorAddress,
      vendorOpenHours: vendorOpenHours,
      vendorStoreAddresses: storeAddresses,
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

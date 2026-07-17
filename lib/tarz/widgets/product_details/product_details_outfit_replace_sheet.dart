import 'package:flutter/material.dart';

import '../../data/category_repository.dart';
import '../../data/product_repository.dart';
import '../../data/tarz_gender_config.dart';
import '../../models/tarz_outfit.dart';
import '../../models/tarz_product_preview.dart';
import '../../theme/tarz_colors.dart';
import '../../utils/tarz_image_cache.dart';

/// Kombin elementini dəyişmək — eyni role üçün alternativ məhsullar.
Future<TarzProductPreview?> showOutfitReplaceSheet(
  BuildContext context, {
  required TarzOutfitItem item,
  String? genderId,
  ProductRepository? productRepo,
}) {
  return showModalBottomSheet<TarzProductPreview>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _OutfitReplaceSheet(
      item: item,
      genderId: genderId,
      productRepo: productRepo ?? ProductRepository(),
      ownsRepo: productRepo == null,
    ),
  );
}

class _OutfitReplaceSheet extends StatefulWidget {
  const _OutfitReplaceSheet({
    required this.item,
    required this.productRepo,
    required this.ownsRepo,
    this.genderId,
  });

  final TarzOutfitItem item;
  final String? genderId;
  final ProductRepository productRepo;
  final bool ownsRepo;

  @override
  State<_OutfitReplaceSheet> createState() => _OutfitReplaceSheetState();
}

class _OutfitReplaceSheetState extends State<_OutfitReplaceSheet> {
  final _categories = CategoryRepository.instance;

  List<TarzProductPreview> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    if (widget.ownsRepo) widget.productRepo.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      var current = widget.item.product;
      var genderId = widget.genderId ?? current.genderId;
      var categoryId = _preferredCatalogId(current);

      // Outfit cavabında kateqoriya boş ola bilər — tam məhsulu çək.
      if (categoryId == null || categoryId.isEmpty || genderId == null) {
        current = await _resolveProduct(current);
        categoryId = _preferredCatalogId(current);
        genderId ??= current.genderId ?? widget.genderId;
      }

      final genderIndex = _genderIndex(genderId);

      // Məhsulun kateqoriyası yoxdursa — role üzrə kataloq (Ayaqqabılar, Çantalar…).
      if (categoryId == null || categoryId.isEmpty) {
        categoryId = await _categories.findCategoryIdForOutfitRole(
          widget.item.role,
          genderId: genderId,
          genderIndex: genderIndex ?? 0,
        );
      }

      Set<String>? categoryScope;
      if (categoryId != null && categoryId.isNotEmpty) {
        try {
          categoryScope = await _categories.collectCategoryScope(categoryId);
        } catch (_) {
          categoryScope = {categoryId};
        }
        if (categoryScope.isEmpty) categoryScope = {categoryId};
      }

      final result = await widget.productRepo.fetchProducts(
        page: 1,
        limit: 40,
        categoryId: categoryId,
        categoryScope: categoryScope,
        genderIndex: genderIndex,
        filterByGender: genderIndex != null,
      );

      if (!mounted) return;

      final filtered = result.products
          .where((p) => p.id != current.id && p.id.isNotEmpty)
          .toList();

      setState(() {
        _products = filtered;
        _loading = false;
        if (filtered.isEmpty) {
          _error = 'Alternativ məhsul tapılmadı';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Məhsullar yüklənmədi';
      });
    }
  }

  /// Əvvəl parent kateqoriya (kataloq bölməsi), sonra alt kateqoriya.
  String? _preferredCatalogId(TarzProductPreview product) {
    final category = product.categoryId?.trim();
    if (category != null && category.isNotEmpty) return category;
    final sub = product.subcategoryId?.trim();
    if (sub != null && sub.isNotEmpty) return sub;
    return null;
  }

  Future<TarzProductPreview> _resolveProduct(TarzProductPreview product) async {
    if (product.id.isEmpty) return product;
    try {
      final detail = await widget.productRepo.fetchProductDetail(product.id);
      return detail.preview;
    } catch (_) {
      return product;
    }
  }

  int? _genderIndex(String? genderId) {
    if (genderId == null || genderId.isEmpty) return null;
    final i = TarzGenderConfig.genderIds.indexOf(genderId);
    return i < 0 ? null : i;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.72;
    final title = TarzOutfitRoleLabels.titleAz(widget.item.role);

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TarzColors.ink,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'İndi: ${widget.item.product.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: TarzColors.inkMuted.withValues(alpha: 0.95),
              ),
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_error != null && _products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: TarzColors.inkMuted.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _load,
                child: const Text('Yenidən cəhd et'),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _ReplaceProductTile(
          product: product,
          onTap: () => Navigator.of(context).pop(product),
        );
      },
    );
  }
}

class _ReplaceProductTile extends StatelessWidget {
  const _ReplaceProductTile({
    required this.product,
    required this.onTap,
  });

  final TarzProductPreview product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl;
    final cache = TarzImageCache.px(context, 180);

    return Material(
      color: const Color(0xFFF7F7F7),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: url == null || url.isEmpty
                  ? const ColoredBox(color: Color(0xFFECECEC))
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      cacheWidth: cache,
                      cacheHeight: cache,
                      errorBuilder: (_, __, ___) =>
                          const ColoredBox(color: Color(0xFFECECEC)),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: TarzColors.ink,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.priceLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: TarzColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

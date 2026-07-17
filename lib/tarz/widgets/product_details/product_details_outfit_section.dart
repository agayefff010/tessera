import 'package:flutter/material.dart';

import '../../cart/tarz_price_utils.dart';
import '../../models/tarz_outfit.dart';
import '../../models/tarz_product_preview.dart';
import '../../theme/tarz_colors.dart';
import '../../theme/tarz_spacing.dart';
import '../../utils/tarz_image_cache.dart';
import '../../wishlist/tarz_wishlist_controller.dart';

const double _kOutfitThumbSize = 78;
const double _kOutfitThumbGap = 8;

/// PDP «Tam obraz» — 2 böyük şəkil + qalanlar kiçik thumbnail.
class ProductDetailsOutfitSection extends StatefulWidget {
  const ProductDetailsOutfitSection({
    super.key,
    required this.outfit,
    this.loading = false,
    this.onRefresh,
    this.onReplaceItem,
    this.onFavorite,
    this.onAddToOutfits,
    this.onAddToCart,
  });

  final TarzGeneratedOutfit outfit;
  final bool loading;
  final VoidCallback? onRefresh;
  /// Məhsula basanda — eyni role üçün alternativ seçmək.
  final ValueChanged<TarzOutfitItem>? onReplaceItem;
  final ValueChanged<TarzProductPreview>? onFavorite;
  final VoidCallback? onAddToOutfits;
  final VoidCallback? onAddToCart;

  @override
  State<ProductDetailsOutfitSection> createState() =>
      _ProductDetailsOutfitSectionState();
}

class _ProductDetailsOutfitSectionState
    extends State<ProductDetailsOutfitSection> {
  int _selectedIndex = 0;

  List<TarzOutfitItem> get _items => widget.outfit.displayItems;

  List<TarzOutfitItem> get _largeItems => widget.outfit.largeItems;

  List<TarzOutfitItem> get _smallItems => widget.outfit.smallItems;

  bool get _showThumbs => _smallItems.isNotEmpty;

  TarzProductPreview get _featured {
    if (_items.isEmpty) {
      return const TarzProductPreview(
        id: '',
        title: '',
        priceLabel: '0₼',
      );
    }
    final i = _selectedIndex.clamp(0, _items.length - 1);
    return _items[i].product;
  }

  int _indexOfProduct(String id) {
    final i = _items.indexWhere((e) => e.product.id == id);
    return i < 0 ? 0 : i;
  }

  String get _totalLabel {
    var sum = 0.0;
    for (final item in _items) {
      sum += TarzPriceUtils.parseManat(item.product.priceLabel);
    }
    return TarzPriceUtils.formatManatSpaced(sum);
  }

  @override
  void didUpdateWidget(covariant ProductDetailsOutfitSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.outfit, widget.outfit)) {
      _selectedIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            TarzSpacing.md,
            TarzSpacing.md,
            TarzSpacing.md,
            TarzSpacing.sm,
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Tam obraz',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: TarzColors.ink,
                  ),
                ),
              ),
              if (widget.onRefresh != null)
                TextButton.icon(
                  onPressed: widget.loading ? null : widget.onRefresh,
                  icon: widget.loading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Yenilə',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: TarzColors.ink,
                    backgroundColor: const Color(0xFFF2F2F2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.loading && items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (!widget.loading && items.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TarzSpacing.md,
              8,
              TarzSpacing.md,
              TarzSpacing.lg,
            ),
            child: Text(
              'Bu məhsul üçün kombin tapılmadı',
              style: TextStyle(
                fontSize: 13,
                color: TarzColors.inkMuted.withValues(alpha: 0.9),
              ),
            ),
          )
        else ...[
          ..._largeItems.map((item) {
            return _LargeOutfitImage(
              product: item.product,
              onTap: () {
                setState(
                  () => _selectedIndex = _indexOfProduct(item.product.id),
                );
                widget.onReplaceItem?.call(item);
              },
              onFavorite: widget.onFavorite == null
                  ? null
                  : () => widget.onFavorite!(item.product),
            );
          }),
          if (_showThumbs) ...[
            const SizedBox(height: TarzSpacing.sm),
            SizedBox(
              height: _kOutfitThumbSize,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
                itemCount: _smallItems.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: _kOutfitThumbGap),
                itemBuilder: (context, i) {
                  final item = _smallItems[i];
                  final globalIndex = _indexOfProduct(item.product.id);
                  return _SmallOutfitThumb(
                    product: item.product,
                    selected: _selectedIndex == globalIndex,
                    onTap: () {
                      setState(() => _selectedIndex = globalIndex);
                      widget.onReplaceItem?.call(item);
                    },
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: TarzSpacing.md),
          _OutfitSummaryCard(
            product: _featured,
            totalLabel: _totalLabel,
            loading: widget.loading,
            onAddToOutfits: widget.onAddToOutfits,
            onAddToCart: widget.onAddToCart,
          ),
        ],
      ],
    );
  }
}

class _LargeOutfitImage extends StatelessWidget {
  const _LargeOutfitImage({
    required this.product,
    this.onTap,
    this.onFavorite,
  });

  final TarzProductPreview product;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl;
    final width = MediaQuery.sizeOf(context).width;
    final height = width * 5 / 4;
    final cacheW = TarzImageCache.px(context, width);
    final cacheH = TarzImageCache.px(context, height);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Material(
              color: const Color(0xFFF5F5F5),
              child: InkWell(
                onTap: onTap,
                child: url == null || url.isEmpty
                    ? const ColoredBox(color: Color(0xFFF0F0F0))
                    : Image.network(
                        url,
                        fit: BoxFit.cover,
                        cacheWidth: cacheW,
                        cacheHeight: cacheH,
                        errorBuilder: (_, __, ___) =>
                            const ColoredBox(color: Color(0xFFF0F0F0)),
                      ),
              ),
            ),
            if (onTap != null)
              Positioned(
                left: 12,
                bottom: 12,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.swap_horiz_rounded, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Dəyiş',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: TarzColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (onFavorite != null)
              Positioned(
                top: 12,
                right: 12,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.95),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onFavorite,
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: TarzWishlistController.instance
                            .favoriteListenable(product.id),
                        builder: (context, isFav, _) {
                          return Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 22,
                            color: isFav
                                ? const Color(0xFFE53935)
                                : TarzColors.ink,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SmallOutfitThumb extends StatelessWidget {
  const _SmallOutfitThumb({
    required this.product,
    required this.selected,
    this.onTap,
  });

  final TarzProductPreview product;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl;
    final cache = TarzImageCache.px(context, _kOutfitThumbSize);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _kOutfitThumbSize,
        height: _kOutfitThumbSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? TarzColors.ink : const Color(0xFFE0E0E0),
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            url == null || url.isEmpty
                ? const ColoredBox(color: Color(0xFFF0F0F0))
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    cacheWidth: cache,
                    cacheHeight: cache,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: Color(0xFFF0F0F0)),
                  ),
            Positioned(
              right: 4,
              bottom: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(3),
                  child: Icon(Icons.swap_horiz_rounded, size: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutfitSummaryCard extends StatelessWidget {
  const _OutfitSummaryCard({
    required this.product,
    required this.totalLabel,
    this.loading = false,
    this.onAddToOutfits,
    this.onAddToCart,
  });

  final TarzProductPreview product;
  final String totalLabel;
  final bool loading;
  final VoidCallback? onAddToOutfits;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    if (product.id.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TarzSpacing.md,
        0,
        TarzSpacing.md,
        TarzSpacing.md,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFECECEC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.brand != null &&
                            product.brand!.trim().isNotEmpty)
                          Text(
                            product.brand!,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  TarzColors.inkMuted.withValues(alpha: 0.95),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: TarzColors.ink,
                          ),
                        ),
                        if (product.subtitle != null &&
                            product.subtitle!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            product.subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  TarzColors.inkMuted.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Ümumi',
                        style: TextStyle(
                          fontSize: 12,
                          color: TarzColors.inkMuted.withValues(alpha: 0.95),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalLabel,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: TarzColors.ink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: loading ? null : onAddToOutfits,
                  style: FilledButton.styleFrom(
                    backgroundColor: TarzColors.ink,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFBDBDBD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kombinlərimə əlavə et',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (onAddToCart != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: loading ? null : onAddToCart,
                    icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                    label: const Text(
                      'Səbətə əlavə et',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TarzColors.ink,
                      side: const BorderSide(color: TarzColors.ink, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

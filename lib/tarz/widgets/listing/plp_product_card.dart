import 'package:flutter/material.dart';

import '../../models/tarz_product_preview.dart';
import '../../theme/tarz_colors.dart';
import '../../utils/tarz_image_cache.dart';
import '../../wishlist/tarz_wishlist_controller.dart';

/// PLP məhsul kartı — 4:5 şəkil, reytinq, brend, qiymət, endirim.
class PlpProductCard extends StatelessWidget {
  const PlpProductCard({
    super.key,
    required this.product,
    this.isFavorite,
    this.onTap,
    this.onFavorite,
    this.onLongPress,
  });

  final TarzProductPreview product;

  /// Optional static override. When null, heart listens per-product.
  final bool? isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onLongPress;

  static const Color _discountRed = Color(0xFFE53935);

  double get _rating => product.rating ?? _demoRating(product.id);

  int get _reviewCount => product.reviewCount ?? _demoReviewCount(product.id);

  static double _demoRating(String id) =>
      3.8 + (id.hashCode.abs() % 12) / 10;

  static int _demoReviewCount(String id) => 8 + (id.hashCode.abs() % 40);

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] PlpProductCard(${product.id})');
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Mətn bloku üçün yer saxla — dar kartlarda bottom overflow olmasın.
            const infoReserve = 130.0;
            final idealImage = constraints.maxWidth * 5 / 4;
            final maxImage =
                (constraints.maxHeight - infoReserve).clamp(80.0, idealImage);
            final imageHeight =
                idealImage > maxImage ? maxImage : idealImage;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _ProductImage(
                        product: product,
                        cacheWidth: TarzImageCache.px(
                          context,
                          constraints.maxWidth,
                        ),
                        cacheHeight: TarzImageCache.px(context, imageHeight),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: onFavorite,
                            customBorder: const CircleBorder(),
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: _FavoriteIcon(
                                productId: product.id,
                                isFavorite: isFavorite,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _priceSection(),
                        if (product.badgeLabel != null) ...[
                          const SizedBox(height: 4),
                          _discountBadge(product.badgeLabel!),
                        ],
                        const SizedBox(height: 6),
                        _ratingRow(),
                        if (product.brand != null &&
                            product.brand!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            product.brand!.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color:
                                  TarzColors.inkMuted.withValues(alpha: 0.95),
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Flexible(
                          child: Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: TarzColors.ink,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _priceSection() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        if (product.originalPriceLabel != null)
          Text(
            product.originalPriceLabel!,
            style: TextStyle(
              fontSize: 12,
              color: TarzColors.inkMuted.withValues(alpha: 0.9),
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text(
          product.priceLabel,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: TarzColors.ink,
          ),
        ),
      ],
    );
  }

  Widget _discountBadge(String label) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _discountRed,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _ratingRow() {
    final fullStars = _rating.floor().clamp(0, 5);
    final hasHalf = (_rating - fullStars) >= 0.3;

    return Row(
      children: [
        ...List.generate(5, (i) {
          IconData icon;
          if (i < fullStars) {
            icon = Icons.star_rounded;
          } else if (i == fullStars && hasHalf) {
            icon = Icons.star_half_rounded;
          } else {
            icon = Icons.star_outline_rounded;
          }
          return Icon(icon, size: 14, color: const Color(0xFFFFB300));
        }),
        const SizedBox(width: 4),
        Text(
          '${_rating.toStringAsFixed(1)} ($_reviewCount)',
          style: TextStyle(
            fontSize: 11,
            color: TarzColors.inkMuted.withValues(alpha: 0.95),
          ),
        ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.product,
    required this.cacheWidth,
    required this.cacheHeight,
  });

  final TarzProductPreview product;
  final int cacheWidth;
  final int cacheHeight;

  @override
  Widget build(BuildContext context) {
    if (product.imageAsset != null && product.imageAsset!.isNotEmpty) {
      return Image.asset(
        product.imageAsset!,
        fit: BoxFit.cover,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return Image.network(
        product.imageUrl!,
        fit: BoxFit.cover,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return const ColoredBox(
      color: Color(0xFFF0EFEC),
      child: Center(
        child: Icon(Icons.checkroom_rounded, size: 40, color: Colors.black26),
      ),
    );
  }
}

class _FavoriteIcon extends StatelessWidget {
  const _FavoriteIcon({
    required this.productId,
    this.isFavorite,
  });

  final String productId;
  final bool? isFavorite;

  @override
  Widget build(BuildContext context) {
    if (isFavorite != null) {
      return _icon(isFavorite!);
    }

    return ValueListenableBuilder<bool>(
      valueListenable:
          TarzWishlistController.instance.favoriteListenable(productId),
      builder: (context, favorite, _) => _icon(favorite),
    );
  }

  Widget _icon(bool favorite) {
    return Icon(
      favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      size: 20,
      color: favorite ? PlpProductCard._discountRed : TarzColors.ink,
    );
  }
}

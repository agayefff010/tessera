import 'package:flutter/material.dart';

import '../../models/tarz_product_preview.dart';
import '../../theme/tarz_colors.dart';
import '../../utils/tarz_image_cache.dart';
import '../../wishlist/tarz_wishlist_controller.dart';

/// Ana səhifə 2 sütunlu məhsul kartı.
class HomeProductCard extends StatelessWidget {
  const HomeProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onWishlist,
    this.isFavorite = false,
  });

  final TarzProductPreview product;
  final VoidCallback? onTap;
  final VoidCallback? onWishlist;
  final bool isFavorite;

  static const Color _badgeRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: const Color(0xFFF7F7F5)),
                  _image(),
                  if (onWishlist != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: onWishlist,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: ValueListenableBuilder<bool>(
                              valueListenable: TarzWishlistController.instance
                                  .favoriteListenable(product.id),
                              builder: (context, favorite, _) {
                                return Icon(
                                  favorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 18,
                                  color: favorite ? _badgeRed : TarzColors.ink,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (product.originalPriceLabel != null) ...[
                        Text(
                          product.originalPriceLabel!,
                          style: TextStyle(
                            fontSize: 11,
                            color: TarzColors.inkMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        product.priceLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: TarzColors.ink,
                        ),
                      ),
                      if (product.badgeLabel != null) ...[
                        const Spacer(),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: _badgeRed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Text(
                              product.badgeLabel!.startsWith('-')
                                  ? product.badgeLabel!
                                  : '-30%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: TarzColors.ink,
                      height: 1.25,
                    ),
                  ),
                  if (product.brand != null || product.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      (product.brand ?? product.subtitle ?? '').toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.4,
                        color: TarzColors.inkMuted.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cacheW = TarzImageCache.px(context, constraints.maxWidth);
        final cacheH = TarzImageCache.px(context, constraints.maxHeight);

        if (product.imageAsset != null && product.imageAsset!.isNotEmpty) {
          return Image.asset(
            product.imageAsset!,
            fit: BoxFit.cover,
            cacheWidth: cacheW,
            cacheHeight: cacheH,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.checkroom_outlined, color: Colors.black26),
            ),
          );
        }
        if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
          return Image.network(
            product.imageUrl!,
            fit: BoxFit.cover,
            cacheWidth: cacheW,
            cacheHeight: cacheH,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.checkroom_outlined, color: Colors.black26),
            ),
          );
        }
        return const Center(
          child: Icon(Icons.checkroom_outlined, color: Colors.black26),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../models/tarz_product_preview.dart';
import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';

/// 2 sütunlu şəbəkə üçün məhsul kartı (karusel kartı ilə eyni məzmun quruluşu).
class TarzListingProductTile extends StatelessWidget {
  const TarzListingProductTile({
    super.key,
    required this.product,
    this.onTap,
  });

  final TarzProductPreview product;
  final VoidCallback? onTap;

  static const Color _discountBadgeBg = Color(0xFF3A3A3A);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TarzColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: _TileImage(product: product),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TarzSpacing.xs,
                TarzSpacing.sm,
                TarzSpacing.xs,
                TarzSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (product.originalPriceLabel != null) ...[
                        Text(
                          product.originalPriceLabel!,
                          style: TextStyle(
                            fontSize: 11,
                            color: TarzColors.inkMuted,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: TarzColors.inkMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        product.priceLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: TarzColors.ink,
                        ),
                      ),
                      if (product.badgeLabel != null) ...[
                        const Spacer(),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: _discountBadgeBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            child: Text(
                              product.badgeLabel!,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: TarzColors.ink,
                      height: 1.2,
                    ),
                  ),
                  if (product.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: TarzColors.inkMuted.withValues(alpha: 0.95),
                        height: 1.2,
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
}

class _TileImage extends StatelessWidget {
  const _TileImage({required this.product});

  final TarzProductPreview product;

  @override
  Widget build(BuildContext context) {
    if (product.imageAsset != null && product.imageAsset!.isNotEmpty) {
      return Image.asset(
        product.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return Image.network(
        product.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return const ColoredBox(
      color: Color(0xFFECEBE8),
      child: Center(
        child: Icon(Icons.checkroom_rounded, size: 36, color: Colors.black26),
      ),
    );
  }
}

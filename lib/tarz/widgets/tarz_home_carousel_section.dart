import 'package:flutter/material.dart';

import '../models/tarz_product_preview.dart';
import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';
import '../theme/tarz_text_styles.dart';
import '../utils/tarz_image_cache.dart';

/// Ana səhifə «Trend» tipli horizontal məhsul bloku + «Hamısını göstər».
class TarzHomeCarouselSection extends StatelessWidget {
  const TarzHomeCarouselSection({
    super.key,
    required this.title,
    required this.products,
    this.cardWidth = 152,
    this.onProductTap,
    this.onTitleAction,
    this.onShowAll,
  });

  final String title;
  final List<TarzProductPreview> products;
  final double cardWidth;
  final ValueChanged<TarzProductPreview>? onProductTap;
  final VoidCallback? onTitleAction;
  final VoidCallback? onShowAll;

  static const Color _discountBadgeBg = Color(0xFF3A3A3A);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            TarzSpacing.md,
            TarzSpacing.lg,
            TarzSpacing.sm,
            TarzSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                title,
                style: TarzTextStyles.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onTitleAction,
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: TarzColors.ink.withValues(alpha: 0.55),
                ),
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 292,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: TarzSpacing.sm),
            itemBuilder: (context, index) {
              final p = products[index];
              return SizedBox(
                width: cardWidth,
                child: _CarouselProductCard(
                  product: p,
                  badgeBg: _discountBadgeBg,
                  onTap: onProductTap == null ? null : () => onProductTap!(p),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            TarzSpacing.md,
            TarzSpacing.md,
            TarzSpacing.md,
            TarzSpacing.xl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: onShowAll,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Hamısını göstər'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CarouselProductCard extends StatelessWidget {
  const _CarouselProductCard({
    required this.product,
    required this.badgeBg,
    this.onTap,
  });

  final TarzProductPreview product;
  final Color badgeBg;
  final VoidCallback? onTap;

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
              child: _CarouselImage(product: product),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
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
                            color: badgeBg,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: TarzColors.ink,
                    ),
                  ),
                  if (product.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: TarzColors.inkMuted.withValues(alpha: 0.95),
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

class _CarouselImage extends StatelessWidget {
  const _CarouselImage({required this.product});

  final TarzProductPreview product;

  @override
  Widget build(BuildContext context) {
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
            errorBuilder: (_, __, ___) => _fallback(),
          );
        }
        if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
          return Image.network(
            product.imageUrl!,
            fit: BoxFit.cover,
            cacheWidth: cacheW,
            cacheHeight: cacheH,
            errorBuilder: (_, __, ___) => _fallback(),
          );
        }
        return _fallback();
      },
    );
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

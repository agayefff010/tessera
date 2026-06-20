import 'package:flutter/material.dart';

import '../../models/tarz_product_preview.dart';
import '../../theme/tarz_colors.dart';

/// «Oxşar məhsullar» şəbəkə kartı — əsas məhsulla eyni qiymət düzümü.
class ProductDetailsRelatedCard extends StatelessWidget {
  const ProductDetailsRelatedCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final TarzProductPreview product;
  final VoidCallback? onTap;

  static const Color _badgeBg = Color(0xFF3A3A3A);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: _image(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.brand != null) ...[
                    Text(
                      product.brand!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: TarzColors.inkMuted.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Row(
                    children: [
                      if (product.originalPriceLabel != null) ...[
                        Text(
                          product.originalPriceLabel!,
                          style: TextStyle(
                            fontSize: 10,
                            color: TarzColors.inkMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        product.priceLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: TarzColors.ink,
                        ),
                      ),
                      if (product.badgeLabel != null) ...[
                        const Spacer(),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: _badgeBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            child: Text(
                              product.badgeLabel!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
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
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: TarzColors.ink,
                      height: 1.25,
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

  Widget _image() {
    if (product.imageAsset != null && product.imageAsset!.isNotEmpty) {
      return Image.asset(
        product.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return const ColoredBox(
      color: Color(0xFFF0EFEC),
      child: Center(
        child: Icon(Icons.checkroom_outlined, color: Colors.black26, size: 28),
      ),
    );
  }
}

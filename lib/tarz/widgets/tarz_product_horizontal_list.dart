import 'package:flutter/material.dart';

import '../models/tarz_product_preview.dart';
import '../theme/tarz_spacing.dart';
import 'tarz_product_card.dart';

class TarzProductHorizontalList extends StatelessWidget {
  const TarzProductHorizontalList({
    super.key,
    required this.products,
    this.cardWidth = 168,
    this.onProductTap,
  });

  final List<TarzProductPreview> products;
  final double cardWidth;
  final ValueChanged<TarzProductPreview>? onProductTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: TarzSpacing.sm),
        itemBuilder: (context, index) {
          final p = products[index];
          return SizedBox(
            width: cardWidth,
            child: TarzProductCard(
              product: p,
              onTap: onProductTap == null ? null : () => onProductTap!(p),
            ),
          );
        },
      ),
    );
  }
}

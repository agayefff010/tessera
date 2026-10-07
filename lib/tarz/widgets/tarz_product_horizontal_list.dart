import 'package:flutter/material.dart';

import '../models/tarz_product_preview.dart';
import '../theme/tarz_spacing.dart';
import 'tarz_product_card.dart';

/// Məhsul kartları — soldan sağa üfüqi scroll; ekranda tam 2 kart.
class TarzProductHorizontalList extends StatelessWidget {
  const TarzProductHorizontalList({
    super.key,
    required this.products,
    this.onProductTap,
  });

  final List<TarzProductPreview> products;
  final ValueChanged<TarzProductPreview>? onProductTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        const horizontalPadding = TarzSpacing.md;
        const gap = TarzSpacing.sm;

        // 2 kart + 1 aralıq = məzmun eni; 3-cü kartın kənarı görünməsin.
        final contentWidth = viewportWidth - horizontalPadding * 2;
        final cardWidth = (contentWidth - gap) / 2;

        final imageHeight = cardWidth * 4 / 3;
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final textBlockHeight = (84 * scale).clamp(84.0, 104.0);
        final listHeight = imageHeight + textBlockHeight;

        return ClipRect(
          child: SizedBox(
            height: listHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.hardEdge,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: gap),
              itemBuilder: (context, index) {
                final p = products[index];
                return SizedBox(
                  width: cardWidth,
                  child: TarzProductCard(
                    product: p,
                    onTap:
                        onProductTap == null ? null : () => onProductTap!(p),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

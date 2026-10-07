import 'package:flutter/material.dart';

import '../models/tarz_product_preview.dart';
import '../theme/tarz_breakpoints.dart';
import '../theme/tarz_spacing.dart';
import 'tarz_product_card.dart';

class TarzProductGrid extends StatelessWidget {
  const TarzProductGrid({
    super.key,
    required this.products,
    this.onProductTap,
  });

  final List<TarzProductPreview> products;
  final ValueChanged<TarzProductPreview>? onProductTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width <= 0) return const SizedBox.shrink();

        const horizontalInset = TarzSpacing.md;
        const spacing = TarzSpacing.sm;
        final columns = TarzBreakpoints.productGridColumns(width);
        // Padding daxilində qalan en — tileWidth tam enə görə hesablanmamalıdır.
        final contentWidth = width - horizontalInset * 2;
        final usable = contentWidth - (columns - 1) * spacing;
        final tileWidth = usable / columns;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalInset),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: products
                .map(
                  (p) => SizedBox(
                    width: tileWidth,
                    child: TarzProductCard(
                      product: p,
                      onTap:
                          onProductTap == null ? null : () => onProductTap!(p),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        );
      },
    );
  }
}

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
        final columns = TarzBreakpoints.productGridColumns(width);
        final spacing = TarzSpacing.sm;
        final usable = width - (columns - 1) * spacing;
        final tileWidth = usable / columns;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: products
                .map(
                  (p) => SizedBox(
                    width: tileWidth,
                    child: TarzProductCard(
                      product: p,
                      onTap: onProductTap == null ? null : () => onProductTap!(p),
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

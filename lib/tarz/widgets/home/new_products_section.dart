import 'package:flutter/material.dart';

import '../../models/tarz_product_preview.dart';
import '../../theme/tarz_colors.dart';
import 'home_product_card.dart';

/// «Yenilər» + «Endirimlər» — 2×2 şəbəkə (üst yenilər, alt endirimlər).
class NewProductsSection extends StatelessWidget {
  const NewProductsSection({
    super.key,
    required this.newProducts,
    required this.discountProducts,
    this.onSeeAll,
    this.onDiscountSeeAll,
    this.onProductTap,
    this.onWishlist,
    this.isFavorite,
  });

  final List<TarzProductPreview> newProducts;
  final List<TarzProductPreview> discountProducts;
  final VoidCallback? onSeeAll;
  final VoidCallback? onDiscountSeeAll;
  final ValueChanged<TarzProductPreview>? onProductTap;
  final ValueChanged<TarzProductPreview>? onWishlist;
  final bool Function(TarzProductPreview product)? isFavorite;

  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 16,
    crossAxisSpacing: 14,
    childAspectRatio: 0.52,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(title: 'Yenilər', onSeeAll: onSeeAll),
          const SizedBox(height: 12),
          if (newProducts.isNotEmpty)
            _ProductGrid(
              products: newProducts.take(2).toList(),
              gridDelegate: _gridDelegate,
              onProductTap: onProductTap,
              onWishlist: onWishlist,
              isFavorite: isFavorite,
            ),
          if (discountProducts.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionHeader(title: 'Endirimlər', onSeeAll: onDiscountSeeAll),
            const SizedBox(height: 12),
            _ProductGrid(
              products: discountProducts.take(2).toList(),
              gridDelegate: _gridDelegate,
              onProductTap: onProductTap,
              onWishlist: onWishlist,
              isFavorite: isFavorite,
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.onSeeAll,
  });

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: TarzColors.ink,
          ),
        ),
        const Spacer(),
        if (onSeeAll != null)
          IconButton(
            onPressed: onSeeAll,
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: TarzColors.ink.withValues(alpha: 0.5),
            ),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.products,
    required this.gridDelegate,
    this.onProductTap,
    this.onWishlist,
    this.isFavorite,
  });

  final List<TarzProductPreview> products;
  final SliverGridDelegate gridDelegate;
  final ValueChanged<TarzProductPreview>? onProductTap;
  final ValueChanged<TarzProductPreview>? onWishlist;
  final bool Function(TarzProductPreview product)? isFavorite;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: gridDelegate,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return HomeProductCard(
          product: p,
          isFavorite: isFavorite?.call(p) ?? false,
          onTap: onProductTap == null ? null : () => onProductTap!(p),
          onWishlist: onWishlist == null ? null : () => onWishlist!(p),
        );
      },
    );
  }
}

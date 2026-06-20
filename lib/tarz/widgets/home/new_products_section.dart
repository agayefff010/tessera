import 'package:flutter/material.dart';

import '../../models/tarz_product_preview.dart';
import '../../theme/tarz_colors.dart';
import 'home_product_card.dart';

/// «Yenilər» — 2 sütunlu şəbəkə.
class NewProductsSection extends StatelessWidget {
  const NewProductsSection({
    super.key,
    required this.products,
    this.onSeeAll,
    this.onProductTap,
    this.onWishlist,
  });

  final List<TarzProductPreview> products;
  final VoidCallback? onSeeAll;
  final ValueChanged<TarzProductPreview>? onProductTap;
  final ValueChanged<TarzProductPreview>? onWishlist;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Yenilər',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TarzColors.ink,
                ),
              ),
              const Spacer(),
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
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 14,
              childAspectRatio: 0.52,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return HomeProductCard(
                product: p,
                onTap: onProductTap == null ? null : () => onProductTap!(p),
                onWishlist: onWishlist == null ? null : () => onWishlist!(p),
              );
            },
          ),
        ],
      ),
    );
  }
}

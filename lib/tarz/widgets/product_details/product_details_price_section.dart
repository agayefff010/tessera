import 'package:flutter/material.dart';

import '../../theme/tarz_colors.dart';
import '../../theme/tarz_spacing.dart';

/// Brend, başlıq, qiymət və endirim nişanı.
class ProductDetailsPriceSection extends StatelessWidget {
  const ProductDetailsPriceSection({
    super.key,
    required this.brand,
    required this.title,
    required this.priceLabel,
    this.originalPriceLabel,
    this.badgeLabel,
    this.sizeSelector,
  });

  final String brand;
  final String title;
  final String priceLabel;
  final String? originalPriceLabel;
  final String? badgeLabel;
  final Widget? sizeSelector;

  static const Color _badgeBg = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            brand,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: TarzColors.ink.withValues(alpha: 0.9),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: TarzColors.ink.withValues(alpha: 0.75),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (originalPriceLabel != null)
                      Text(
                        originalPriceLabel!,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: TarzColors.inkMuted.withValues(alpha: 0.9),
                          decoration: TextDecoration.lineThrough,
                          decorationColor: TarzColors.inkMuted,
                        ),
                      ),
                    Text(
                      priceLabel,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D2D2D),
                        height: 1.15,
                      ),
                    ),
                    if (badgeLabel != null)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: _badgeBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            badgeLabel!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (sizeSelector != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: sizeSelector!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

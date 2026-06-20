import 'package:flutter/material.dart';

import '../../cart/tarz_price_utils.dart';
import '../../models/tarz_cart_item.dart';
import '../../theme/tarz_colors.dart';

/// «Sifariş xülasəsi» kartı.
class TarzCartSummarySection extends StatelessWidget {
  const TarzCartSummarySection({
    super.key,
    required this.summary,
    this.giftWrapSelected = false,
    this.onGiftWrapChanged,
  });

  final TarzCartSummary summary;
  final bool giftWrapSelected;
  final ValueChanged<bool>? onGiftWrapChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Sifariş xülasəsi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: TarzColors.ink,
                ),
              ),
              const SizedBox(height: 14),
              _row(
                'Məhsulların məbləği',
                TarzPriceUtils.formatManatSpaced(summary.subtotalManat),
              ),
              if (summary.discountManat > 0) ...[
                const SizedBox(height: 8),
                _row(
                  'Endirim',
                  '-${TarzPriceUtils.formatManatSpaced(summary.discountManat).trim()}',
                  valueColor: const Color(0xFFC62828),
                ),
              ],
              const SizedBox(height: 8),
              _row(
                'Çatdırılma',
                TarzPriceUtils.formatManatSpaced(summary.shippingManat),
              ),
              if (onGiftWrapChanged != null) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => onGiftWrapChanged?.call(!giftWrapSelected),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: giftWrapSelected,
                            onChanged: (v) =>
                                onGiftWrapChanged?.call(v ?? false),
                            activeColor: TarzColors.ink,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Hədiyyə qablaşdırılması',
                            style: TextStyle(
                              fontSize: 13,
                              color: TarzColors.ink,
                            ),
                          ),
                        ),
                        if (giftWrapSelected)
                          Text(
                            '+${TarzPriceUtils.formatManatSpaced(summary.giftWrapManat).trim()}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: TarzColors.ink,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: Color(0xFFEEEEEE)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Yekun məbləğ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: TarzColors.ink,
                    ),
                  ),
                  Text(
                    TarzPriceUtils.formatManatSpaced(summary.totalManat),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: TarzColors.ink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: TarzColors.inkMuted.withValues(alpha: 0.95),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor ?? TarzColors.ink,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../cart/tarz_price_utils.dart';
import '../../models/tarz_cart_item.dart';
import '../../theme/tarz_colors.dart';

/// «Sifarişin məbləği» bloku — Figma Cart layout.
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

  static const Color _discountRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] TarzCartSummarySection');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sifarişin məbləği',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: TarzColors.ink,
                ),
              ),
              Text(
                TarzPriceUtils.formatManatSpaced(summary.totalManat),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: TarzColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _row(
            summary.itemCountLabel,
            summary.discountManat > 0
                ? '-${TarzPriceUtils.formatManatSpaced(summary.discountManat).trim()}'
                : TarzPriceUtils.formatManatSpaced(summary.itemsSubtotalManat),
            valueColor:
                summary.discountManat > 0 ? _discountRed : TarzColors.ink,
          ),
          if (onGiftWrapChanged != null) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () => onGiftWrapChanged?.call(!giftWrapSelected),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: giftWrapSelected,
                        onChanged: (v) =>
                            onGiftWrapChanged?.call(v ?? false),
                        activeColor: TarzColors.ink,
                        side: const BorderSide(color: Color(0xFFBDBDBD)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Hədiyyəlik paketləmə',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: TarzColors.ink,
                        ),
                      ),
                    ),
                    Text(
                      TarzPriceUtils.formatManatSpaced(summary.giftWrapManat),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: TarzColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: TarzColors.ink,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ?? TarzColors.ink,
          ),
        ),
      ],
    );
  }
}

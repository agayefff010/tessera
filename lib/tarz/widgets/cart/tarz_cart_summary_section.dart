import 'package:flutter/material.dart';

import '../../models/tarz_cart_item.dart';
import '../../theme/tarz_colors.dart';

/// «Sifariş məbləği», «Endirim» və «Ümumi məbləğ» xülasə bölməsi.
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

  static const Color _discountGreen = Color(0xFF2E7D32);

  static String _formatPrice(double value) =>
      '${value.toStringAsFixed(2)} ₼';

  static String _formatDiscount(double value) {
    if (value <= 0) return '0.00 ₼';
    return '\u2212${value.toStringAsFixed(2)} ₼';
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] TarzCartSummarySection');
    final subtotal = summary.subtotalManat;
    final discount = summary.discountManat;
    final finalTotal = summary.totalManat;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          // 1. "Sifariş məbləği"
          _row(
            'Sifariş məbləği',
            _formatPrice(subtotal),
          ),
          const SizedBox(height: 12),
          // 2. "Endirim"
          _row(
            'Endirim',
            _formatDiscount(discount),
            valueColor: _discountGreen,
          ),
          if (summary.shippingManat > 0) ...[
            const SizedBox(height: 12),
            _row(
              'Çatdırılma',
              _formatPrice(summary.shippingManat),
            ),
          ],
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
                      _formatPrice(summary.giftWrapManat),
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
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          // 3. "Ümumi məbləğ"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ümumi məbləğ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: TarzColors.ink,
                ),
              ),
              Text(
                _formatPrice(finalTotal),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TarzColors.ink,
                ),
              ),
            ],
          ),
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

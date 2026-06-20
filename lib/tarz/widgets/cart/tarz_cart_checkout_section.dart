import 'package:flutter/material.dart';

import '../../theme/tarz_colors.dart';
import '../../theme/tarz_spacing.dart';

/// Promokod sətiri + «Ödənişə keç» düyməsi.
class TarzCartCheckoutSection extends StatelessWidget {
  const TarzCartCheckoutSection({
    super.key,
    required this.itemCountLabel,
    required this.totalLabel,
    required this.strikethroughLabel,
    this.promoExpanded = false,
    this.onPromoToggle,
    this.onCheckout,
  });

  final String itemCountLabel;
  final String totalLabel;
  final String strikethroughLabel;
  final bool promoExpanded;
  final VoidCallback? onPromoToggle;
  final VoidCallback? onCheckout;

  static const Color _divider = Color(0xFFEEEEEE);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 1, thickness: 1, color: _divider),
          InkWell(
            onTap: onPromoToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TarzSpacing.md,
                TarzSpacing.md,
                TarzSpacing.md,
                TarzSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_box_outline_blank_rounded,
                    size: 20,
                    color: TarzColors.ink.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Promokodlar və sertifikatlar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: TarzColors.ink,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: promoExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: TarzColors.ink.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TarzSpacing.md,
              0,
              TarzSpacing.md,
              TarzSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: onCheckout,
                    style: FilledButton.styleFrom(
                      backgroundColor: TarzColors.ink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Ödənişə keç',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: TarzColors.inkMuted.withValues(alpha: 0.9),
                    ),
                    children: [
                      TextSpan(text: '$itemCountLabel — $totalLabel '),
                      TextSpan(
                        text: strikethroughLabel,
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          decorationColor: TarzColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

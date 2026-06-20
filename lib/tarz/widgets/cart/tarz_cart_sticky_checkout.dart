import 'package:flutter/material.dart';

import '../../cart/tarz_price_utils.dart';
import '../../theme/tarz_colors.dart';

/// Yapışqan ödəniş paneli.
class TarzCartStickyCheckout extends StatelessWidget {
  const TarzCartStickyCheckout({
    super.key,
    required this.totalManat,
    this.onCheckout,
  });

  final double totalManat;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Yekun:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: TarzColors.ink,
                    ),
                  ),
                  Text(
                    TarzPriceUtils.formatManatSpaced(totalManat),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TarzColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                width: double.infinity,
                child: FilledButton(
                  onPressed: onCheckout,
                  style: FilledButton.styleFrom(
                    backgroundColor: TarzColors.ink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Ödənişə keç',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

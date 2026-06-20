import 'package:flutter/material.dart';

import '../../theme/tarz_colors.dart';

/// Boş səbət vəziyyəti.
class TarzCartEmptyState extends StatelessWidget {
  const TarzCartEmptyState({
    super.key,
    required this.onShop,
  });

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 56,
              color: TarzColors.inkMuted.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Səbətiniz boşdur',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: TarzColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bəyəndiyiniz məhsulları səbətə əlavə edin',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: TarzColors.inkMuted.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: onShop,
              style: FilledButton.styleFrom(
                backgroundColor: TarzColors.ink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Alış-verişə başla',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

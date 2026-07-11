import 'package:flutter/material.dart';

import '../../theme/tarz_colors.dart';

/// Alt «Ödənişə keç» düyməsi — Figma Cart layout.
class TarzCartStickyCheckout extends StatelessWidget {
  const TarzCartStickyCheckout({
    super.key,
    this.onCheckout,
  });

  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: FilledButton(
              onPressed: onCheckout,
              style: FilledButton.styleFrom(
                backgroundColor: TarzColors.ink,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
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
        ),
      ),
    );
  }
}

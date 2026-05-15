import 'package:flutter/material.dart';

import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';
import '../theme/tarz_text_styles.dart';

class TarzPromoStrip extends StatelessWidget {
  const TarzPromoStrip({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TarzColors.promoBar,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: TarzSpacing.sm,
          horizontal: TarzSpacing.md,
        ),
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TarzTextStyles.promo,
          ),
        ),
      ),
    );
  }
}

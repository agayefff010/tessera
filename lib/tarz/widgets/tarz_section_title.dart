import 'package:flutter/material.dart';

import '../theme/tarz_spacing.dart';
import '../theme/tarz_text_styles.dart';

class TarzSectionTitle extends StatelessWidget {
  const TarzSectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TarzSpacing.md,
        TarzSpacing.lg,
        TarzSpacing.md,
        TarzSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TarzTextStyles.titleMd)),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!, style: TarzTextStyles.label.copyWith(color: Colors.black)),
            ),
        ],
      ),
    );
  }
}

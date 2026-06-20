import 'package:flutter/material.dart';

import '../../theme/tarz_colors.dart';
import '../../theme/tarz_spacing.dart';

/// Açılan/bağlanan filtr bölməsi (Kateqoriyalar, Rənglər, Ölçü).
class TarzFilterExpandableSection extends StatelessWidget {
  const TarzFilterExpandableSection({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
    this.trailing,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: TarzColors.ink,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: TarzColors.ink.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          child,
          const SizedBox(height: TarzSpacing.sm),
        ],
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme/tarz_colors.dart';

class TarzFilterColorOption {
  const TarzFilterColorOption({
    required this.id,
    required this.label,
    required this.color,
  });

  final String id;
  final String label;
  final Color color;
}

/// Dairəvi rəng seçicisi — halqa + işarə.
class TarzFilterColorDot extends StatelessWidget {
  const TarzFilterColorDot({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final TarzFilterColorOption option;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  static const Duration _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final isLight = option.color.computeLuminance() > 0.82;
    final dotSize = compact ? 32.0 : 36.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: _duration,
            curve: Curves.easeOutCubic,
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: option.color,
              border: Border.all(
                color: selected
                    ? TarzColors.ink
                    : (isLight ? const Color(0xFFD8D8D8) : option.color),
                width: selected ? 2.5 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: TarzColors.ink.withValues(alpha: 0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: selected
                ? Icon(
                    Icons.check_rounded,
                    size: compact ? 16 : 18,
                    color: isLight ? TarzColors.ink : Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            option.label,
            style: TextStyle(
              fontSize: compact ? 13 : 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? TarzColors.ink : TarzColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

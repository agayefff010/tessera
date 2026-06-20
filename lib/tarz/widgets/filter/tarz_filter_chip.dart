import 'package:flutter/material.dart';

import '../../theme/tarz_colors.dart';

/// Kompakt filtr çipi — seçili: tünd fon, ağ mətn.
class TarzFilterChip extends StatelessWidget {
  const TarzFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  static const Color _chipBg = Color(0xFFF0F0F0);
  static const Duration _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final hPad = compact ? 12.0 : 14.0;
    final vPad = compact ? 7.0 : 8.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: _duration,
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            color: selected ? TarzColors.ink : _chipBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedDefaultTextStyle(
            duration: _duration,
            curve: Curves.easeOutCubic,
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : TarzColors.ink,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

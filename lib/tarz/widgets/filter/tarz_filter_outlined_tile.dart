import 'package:flutter/material.dart';

import '../../theme/tarz_colors.dart';

/// Ölçü çipi — kompakt şəbəkə elementi.
class TarzFilterOutlinedTile extends StatelessWidget {
  const TarzFilterOutlinedTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const Color _bg = Color(0xFFF0F0F0);
  static const Duration _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: _duration,
          curve: Curves.easeOutCubic,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? TarzColors.ink : _bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedDefaultTextStyle(
            duration: _duration,
            style: TextStyle(
              fontSize: 13,
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

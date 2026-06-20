import 'package:flutter/material.dart';

/// Fəsil düyməsi — Figma: 32px hündürlük, incə kontur, sol ikon.
class TarzFilterSeasonButton extends StatelessWidget {
  const TarzFilterSeasonButton({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  static const double height = 32;
  static const double radius = 2;
  static const Color inactiveBg = Color(0xFFF5F5F5);
  static const Color activeBg = Colors.white;
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color borderActive = Color(0xFF121212);
  static const Color textInactive = Color(0xFF6B6B6B);
  static const Color textActive = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            color: selected ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: selected ? borderActive : borderColor,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: selected ? textActive : textInactive,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      color: selected ? textActive : textInactive,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

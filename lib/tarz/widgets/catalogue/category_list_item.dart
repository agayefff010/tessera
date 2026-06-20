import 'package:flutter/material.dart';

import '../../theme/tarz_text_styles.dart';

/// Kataloq kateqoriya sətiri — böyük tipografiya, minimal dizayn.
class CategoryListItem extends StatelessWidget {
  const CategoryListItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.textKey,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Key? textKey;

  static const Color _defaultTextColor = Color(0xFF111111);
  static const Color _endirimSelectedColor = Color(0xFFFF315F);

  bool get _isEndirimler => label == 'Endirimlər';

  Color get _resolvedTextColor => isSelected && _isEndirimler
      ? _endirimSelectedColor
      : _defaultTextColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 58,
          width: double.infinity,
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                label,
                key: textKey,
                textAlign: TextAlign.center,
                style: TarzTextStyles.catalogueCategory.copyWith(
                  color: _resolvedTextColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

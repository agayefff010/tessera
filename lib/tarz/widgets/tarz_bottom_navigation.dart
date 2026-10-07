import 'package:flutter/material.dart';

import '../data/tarz_nav_assets.dart';

/// 5 ikonlu alt naviqasiya — kataloq, kombinlərim, ana səhifə, seçilmişlər, profil.
class TarzBottomNavigation extends StatelessWidget {
  const TarzBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const Color _inactive = Color(0xFFB0B0B0);
  static const Color _active = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] TarzBottomNavigation');
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _assetItem(0, TarzNavAssets.catalog),
              _assetItem(1, TarzNavAssets.hanger),
              _homeItem(2),
              _item(3, Icons.favorite_border_rounded),
              _item(4, Icons.person_outline_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon) {
    final sel = currentIndex == index;
    return IconButton(
      onPressed: () => onChanged(index),
      icon: Icon(
        icon,
        size: 24,
        color: sel ? _active : _inactive,
      ),
    );
  }

  Widget _assetItem(int index, String asset) {
    final sel = currentIndex == index;
    return IconButton(
      onPressed: () => onChanged(index),
      icon: _tintedAsset(
        asset,
        color: sel ? _active : _inactive,
        size: 24,
      ),
    );
  }

  Widget _homeItem(int index) {
    final sel = currentIndex == index;
    return GestureDetector(
      onTap: () => onChanged(index),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: sel ? _active : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: _tintedAsset(
            TarzNavAssets.home,
            color: sel ? Colors.white : _inactive,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _tintedAsset(
    String asset, {
    required Color color,
    required double size,
  }) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (_, __, ___) => Icon(
        Icons.image_not_supported_outlined,
        size: size,
        color: color,
      ),
    );
  }
}

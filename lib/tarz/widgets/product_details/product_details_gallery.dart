import 'package:flutter/material.dart';

import '../../data/tarz_product_assets.dart';
import '../../theme/tarz_spacing.dart';
import '../../utils/tarz_image_cache.dart';
import '../../wishlist/tarz_wishlist_controller.dart';

/// Böyük portret şəkil + thumbnail sırası, «Geriyə» və favorit düymələri.
///
/// Yalnız status-bar hündürlüyü üçün SafeArea tətbiq olunur —
/// şəkil status-bar-ın altından başlayır, tam ekran səthə uzanmır.
class ProductDetailsGallery extends StatelessWidget {
  const ProductDetailsGallery({
    super.key,
    this.imageAssets = const [],
    this.imageUrls = const [],
    required this.selectedIndex,
    required this.onThumbnailTap,
    required this.onBack,
    this.onFavorite,
    this.isFavorite = false,
    this.favoriteProductId,
    this.mainImageAsset,
    this.showBackButton = true,
  });

  final List<String> imageAssets;
  final List<String> imageUrls;
  final int selectedIndex;
  final ValueChanged<int> onThumbnailTap;
  final VoidCallback onBack;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final String? favoriteProductId;
  final String? mainImageAsset;
  final bool showBackButton;

  static const double _hPad = 26;
  static const double thumbnailSize = 78;
  static const double thumbnailGap = 8;

  bool get _useNetwork => imageUrls.isNotEmpty;

  List<int> get _indices =>
      List.generate(_useNetwork ? imageUrls.length : imageAssets.length, (i) => i);

  @override
  Widget build(BuildContext context) {
    final safeIndex =
        _indices.isEmpty ? 0 : selectedIndex.clamp(0, _indices.length - 1);

    // Status-bar hündürlüyü — şəkil status bar və kamera kəsiyindən ~10px aşağıdan başlayır.
    final statusBarH = MediaQuery.paddingOf(context).top;
    final imageTop = statusBarH + 10.0;

    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Əsas şəkil bölməsi ──────────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final imageWidth = constraints.maxWidth - _hPad * 2;

              return Stack(
                children: [
                  // Şəkil: 26dp sol/sağ margin + status bar altından 10dp yuxarı boşluq
                  Padding(
                    padding: EdgeInsets.only(
                      left: _hPad,
                      right: _hPad,
                      top: imageTop,
                    ),
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: SizedBox(
                        width: imageWidth,
                        child: ClipRRect(
                          child: _buildMainImage(safeIndex),
                        ),
                      ),
                    ),
                  ),

                  // ── Geri düyməsi (əgər daxildən göstərilirsə) ───────────────
                  if (showBackButton)
                    Positioned(
                      top: imageTop + 10,
                      left: _hPad + 10,
                      child: _BackButton(onBack: onBack),
                    ),

                  // ── Favorit düyməsi (sağ üst, şəkil içində) ────────────
                  if (onFavorite != null)
                    Positioned(
                      top: imageTop + 4,
                      right: _hPad + 4,
                      child: _FavoriteButton(
                        onTap: onFavorite!,
                        productId: favoriteProductId,
                        isFavorite: isFavorite,
                      ),
                    ),
                ],
              );
            },
          ),

          // ── Thumbnails (eyni 26dp horizontal padding) ───────────────────
          if (_indices.length > 1)
            Padding(
              padding: const EdgeInsets.only(
                left: _hPad,
                right: _hPad,
                top: TarzSpacing.md,
                bottom: TarzSpacing.lg,
              ),
              child: SizedBox(
                height: thumbnailSize,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _indices.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: thumbnailGap),
                  itemBuilder: (context, index) {
                    final selected = index == safeIndex;
                    return GestureDetector(
                      onTap: () => onThumbnailTap(index),
                      child: Container(
                        width: thumbnailSize,
                        height: thumbnailSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF121212)
                                : const Color(0xFFE0E0E0),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          child: _buildThumb(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Köməkçi metodlar ─────────────────────────────────────────────────────

  Widget _buildMainImage(int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cacheW = TarzImageCache.px(context, constraints.maxWidth);
        final cacheH = TarzImageCache.px(context, constraints.maxHeight);

        if (_useNetwork) {
          return Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
            alignment: Alignment.center,
            cacheWidth: cacheW,
            cacheHeight: cacheH,
            errorBuilder: (_, __, ___) => _placeholder(),
          );
        }

        final asset = mainImageAsset ??
            (imageAssets.isNotEmpty
                ? imageAssets[index]
                : TarzProductAssets.nikeV5Rnr);

        return Image.asset(
          asset,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          cacheWidth: cacheW,
          cacheHeight: cacheH,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      },
    );
  }

  Widget _buildThumb(int index) {
    return Builder(
      builder: (context) {
        final cache = TarzImageCache.px(context, thumbnailSize);
        if (_useNetwork) {
          return Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
            cacheWidth: cache,
            cacheHeight: cache,
            errorBuilder: (_, __, ___) => _placeholder(),
          );
        }

        return Image.asset(
          imageAssets[index],
          fit: BoxFit.cover,
          cacheWidth: cache,
          cacheHeight: cache,
          errorBuilder: (_, __, ___) =>
              const ColoredBox(color: Color(0xFFF5F5F5)),
        );
      },
    );
  }

  Widget _placeholder() {
    return const ColoredBox(
      color: Color(0xFFF0F0F0),
      child: Center(child: Icon(Icons.image_not_supported_outlined)),
    );
  }
}

// ── Geri düyməsi widget-i ────────────────────────────────────────────────────
//
// • Yarı şəffaf tünd dairəvi arxa fon — hər şəkil üzərində oxunur.
// • Ağ ox ikonu.
// • 44×44dp minimum toxunma sahəsi (iOS HIG + Material guideline).
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.38),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Favorit düyməsi widget-i ─────────────────────────────────────────────────
class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.onTap,
    this.productId,
    this.isFavorite = false,
  });

  final VoidCallback onTap;
  final String? productId;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: productId != null
            ? ValueListenableBuilder<bool>(
                valueListenable: TarzWishlistController.instance
                    .favoriteListenable(productId!),
                builder: (context, fav, _) {
                  return Icon(
                    fav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 24,
                    color: fav
                        ? const Color(0xFFE53935)
                        : const Color(0xFF121212),
                  );
                },
              )
            : Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 24,
                color: isFavorite
                    ? const Color(0xFFE53935)
                    : const Color(0xFF121212),
              ),
      ),
    );
  }
}


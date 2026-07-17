import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../models/tarz_product_preview.dart';
import '../theme/tarz_breakpoints.dart';
import '../theme/tarz_colors.dart';
import '../wishlist/tarz_wishlist_controller.dart';
import '../widgets/listing/plp_product_card.dart';

/// Seçilmişlər səhifəsi — lokal + API sinxron.
class TarzWishlistScreen extends StatefulWidget {
  const TarzWishlistScreen({
    super.key,
    required this.onProductTap,
  });

  final ValueChanged<TarzProductPreview> onProductTap;

  @override
  State<TarzWishlistScreen> createState() => _TarzWishlistScreenState();
}

class _TarzWishlistScreenState extends State<TarzWishlistScreen> {
  final _wishlist = TarzWishlistController.instance;

  @override
  void initState() {
    super.initState();
    _wishlist.ensureLoaded();
  }

  Future<void> _remove(TarzProductPreview product) async {
    await _wishlist.remove(product.id);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = TarzBreakpoints.contentMaxWidth(constraints.maxWidth);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: ListenableBuilder(
              listenable: _wishlist,
              builder: (context, _) {
                final items = _wishlist.items;
                final loading = _wishlist.isLoading && items.isEmpty;

                if (loading) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                if (items.isEmpty) {
                  return _EmptyState(onShop: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.home,
                      (route) => false,
                    );
                  });
                }

                return RefreshIndicator(
                  onRefresh: _wishlist.reload,
                  child: CustomScrollView(
                    key: const PageStorageKey<String>('tarz_wishlist_scroll'),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      _WishlistHeader(count: items.length),
                      _WishlistGrid(
                        items: items,
                        onProductTap: widget.onProductTap,
                        onRemove: _remove,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _WishlistHeader extends StatelessWidget {
  const _WishlistHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seçilmişlər',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: TarzColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count məhsul',
              style: TextStyle(
                fontSize: 13,
                color: TarzColors.inkMuted.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistGrid extends StatelessWidget {
  const _WishlistGrid({
    required this.items,
    required this.onProductTap,
    required this.onRemove,
  });

  final List<TarzProductPreview> items;
  final ValueChanged<TarzProductPreview> onProductTap;
  final Future<void> Function(TarzProductPreview product) onRemove;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.48,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = items[index];
            return PlpProductCard(
              key: ValueKey(product.id),
              product: product,
              isFavorite: true,
              onTap: () => onProductTap(product),
              onFavorite: () => onRemove(product),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onShop});

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 64,
              color: TarzColors.inkMuted.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 20),
            const Text(
              'Seçilmişləriniz boşdur',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TarzColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bəyəndiyiniz məhsulları seçilmişlərə əlavə edin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: TarzColors.inkMuted.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onShop,
              style: FilledButton.styleFrom(
                backgroundColor: TarzColors.ink,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Alış-verişə başla'),
            ),
          ],
        ),
      ),
    );
  }
}

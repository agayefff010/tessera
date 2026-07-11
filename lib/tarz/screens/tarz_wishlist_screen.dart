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
    _wishlist.addListener(_rebuild);
  }

  @override
  void dispose() {
    _wishlist.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _remove(TarzProductPreview product) async {
    await _wishlist.remove(product.id);
  }

  @override
  Widget build(BuildContext context) {
    final items = _wishlist.items;
    final loading = _wishlist.isLoading && items.isEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = TarzBreakpoints.contentMaxWidth(constraints.maxWidth);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : items.isEmpty
                    ? _EmptyState(onShop: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.home,
                          (route) => false,
                        );
                      })
                    : RefreshIndicator(
                        onRefresh: _wishlist.reload,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                                      '${items.length} məhsul',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: TarzColors.inkMuted
                                            .withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 8, 14, 24),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: 0.48,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final product = items[index];
                                    return PlpProductCard(
                                      product: product,
                                      isFavorite: true,
                                      onTap: () =>
                                          widget.onProductTap(product),
                                      onFavorite: () => _remove(product),
                                    );
                                  },
                                  childCount: items.length,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        );
      },
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

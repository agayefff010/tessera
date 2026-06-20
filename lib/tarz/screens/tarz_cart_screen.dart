import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../cart/tarz_cart_controller.dart';
import '../cart/tarz_price_utils.dart';
import '../models/tarz_product_preview.dart';
import '../wishlist/tarz_wishlist_controller.dart';
import '../theme/tarz_colors.dart';
import '../widgets/cart/tarz_cart_empty_state.dart';
import '../widgets/cart/tarz_cart_item_tile.dart';
import '../widgets/cart/tarz_cart_promo_section.dart';
import '../widgets/cart/tarz_cart_sticky_checkout.dart';
import '../widgets/cart/tarz_cart_summary_section.dart';

/// Səbət səhifəsi — `TarzCartController` ilə sinxron hesablama.
class TarzCartScreen extends StatefulWidget {
  const TarzCartScreen({super.key});

  @override
  State<TarzCartScreen> createState() => _TarzCartScreenState();
}

class _TarzCartScreenState extends State<TarzCartScreen> {
  final _cart = TarzCartController.instance;

  static const Color _pageBg = Color(0xFFF7F7F7);

  bool _promoExpanded = false;
  bool _giftWrapSelected = false;

  @override
  void initState() {
    super.initState();
    _cart.addListener(_rebuild);
  }

  @override
  void dispose() {
    _cart.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _toast(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  void _goHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _cart.items;
    final summary = _cart.buildSummary(includeGiftWrap: _giftWrapSelected);
    final isEmpty = items.isEmpty;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(canPop, _cart.itemCountLabel),
            Expanded(
              child: isEmpty
                  ? TarzCartEmptyState(onShop: _goHome)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          ...items.map((item) {
                            return TarzCartItemTile(
                              item: item,
                              onIncrement: () =>
                                  _cart.incrementQuantity(item.id),
                              onDecrement: () =>
                                  _cart.decrementQuantity(item.id),
                              onFavorite: () {
                                final product = TarzProductPreview(
                                  id: item.id,
                                  title: item.title,
                                  brand: item.brand,
                                  priceLabel: item.priceLabel,
                                  imageAsset: item.imageAsset,
                                  originalPriceLabel: item.originalPriceLabel,
                                  badgeLabel: item.badgeLabel,
                                );
                                TarzWishlistController.instance.add(product);
                                _toast('Favorilərə köçürüldü');
                              },
                              onRemove: () {
                                _cart.removeItem(item.id);
                                _toast('Məhsul silindi');
                              },
                            );
                          }),
                          const SizedBox(height: 4),
                          TarzCartSummarySection(
                            summary: summary,
                            giftWrapSelected: _giftWrapSelected,
                            onGiftWrapChanged: (v) =>
                                setState(() => _giftWrapSelected = v),
                          ),
                          TarzCartPromoSection(
                            expanded: _promoExpanded,
                            onToggle: () => setState(
                              () => _promoExpanded = !_promoExpanded,
                            ),
                            onApply: () => _toast('Promokod tətbiq edildi'),
                          ),
                        ],
                      ),
                    ),
            ),
            if (!isEmpty)
              TarzCartStickyCheckout(
                totalManat: summary.totalManat,
                onCheckout: () => _toast(
                  'Ödənişə keç — ${TarzPriceUtils.formatManatSpaced(summary.totalManat)}',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool canPop, String itemCountLabel) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(canPop ? 4 : 16, 8, 16, 0),
            child: Row(
              children: [
                if (canPop)
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    style: IconButton.styleFrom(
                      foregroundColor: TarzColors.ink,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: canPop
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Səbət',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: TarzColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        itemCountLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: TarzColors.inkMuted.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
        ],
      ),
    );
  }
}

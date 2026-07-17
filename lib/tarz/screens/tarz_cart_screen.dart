import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../cart/tarz_cart_controller.dart';
import '../models/tarz_cart_item.dart';
import '../models/tarz_product_preview.dart';
import '../orders/tarz_orders_controller.dart';
import '../wishlist/tarz_wishlist_controller.dart';
import '../theme/tarz_colors.dart';
import '../widgets/cart/tarz_cart_empty_state.dart';
import '../widgets/cart/tarz_cart_item_tile.dart';
import '../widgets/cart/tarz_cart_promo_section.dart';
import '../widgets/cart/tarz_checkout_sheet.dart';
import '../widgets/cart/tarz_cart_sticky_checkout.dart';
import '../widgets/cart/tarz_cart_summary_section.dart';
import '../widgets/tarz_flash_message.dart';

/// Səbət səhifəsi — lokal + API sinxron.
class TarzCartScreen extends StatefulWidget {
  const TarzCartScreen({super.key});

  @override
  State<TarzCartScreen> createState() => _TarzCartScreenState();
}

class _TarzCartScreenState extends State<TarzCartScreen> {
  final _cart = TarzCartController.instance;
  final _orders = TarzOrdersController.instance;
  final _authService = AuthService();

  static const Color _pageBg = Colors.white;

  bool _promoExpanded = false;
  bool _giftWrapSelected = false;
  bool _checkoutBusy = false;

  @override
  void initState() {
    super.initState();
    _cart.ensureLoaded();
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }

  void _toast(String message) => TarzFlashMessage.show(context, message);

  void _goHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  TarzProductPreview _previewFromItem(TarzCartItem item) {
    return TarzProductPreview(
      id: item.productId,
      title: item.title,
      brand: item.brand,
      priceLabel: item.priceLabel,
      imageAsset: item.imageAsset,
      imageUrl: item.imageUrl,
      originalPriceLabel: item.originalPriceLabel,
      badgeLabel: item.badgeLabel,
    );
  }

  Future<void> _startCheckout() async {
    if (_checkoutBusy || _cart.isEmpty) return;

    final loggedIn = await _authService.isLoggedIn();
    if (!loggedIn) {
      if (!mounted) return;
      final action = await showTarzAuthRequiredDialog(
        context,
        message:
            'Sifarişi rəsmiləşdirmək üçün daxil olun və ya qeydiyyatdan keçin.',
      );
      if (!mounted || action == null) return;
      if (action == TarzAuthPromptAction.login) {
        await Navigator.of(context).pushNamed(AppRoutes.login);
      } else {
        await Navigator.of(context).pushNamed(AppRoutes.register);
      }
      return;
    }

    final user = await _authService.getCachedUser();
    if (!mounted) return;
    final request = await showTarzCheckoutSheet(
      context,
      initialPhone: user?.phone,
    );
    if (request == null || !mounted) return;

    setState(() => _checkoutBusy = true);
    try {
      final summary = _cart.buildSummary(includeGiftWrap: _giftWrapSelected);
      final order = await _orders.placeOrder(
        request: request,
        totalManat: summary.totalManat,
        itemCount: _cart.totalQuantity,
      );
      await _cart.clear();
      if (!mounted) return;
      await showTarzOrderSuccessDialog(context, order: order);
      if (!mounted) return;
      _toast('Sifariş #${order.displayId} qəbul edildi');
    } catch (e) {
      if (mounted) _toast('Sifariş rəsmiləşdirilmədi');
    } finally {
      if (mounted) setState(() => _checkoutBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListenableBuilder(
              listenable: _cart,
              builder: (context, _) =>
                  _buildHeader(canPop, _cart.itemCountLabel),
            ),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: _cart.listRevision,
                builder: (context, _, __) {
                  final loading = _cart.isLoading && _cart.isEmpty;
                  if (loading) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  if (_cart.isEmpty) {
                    return TarzCartEmptyState(onShop: _goHome);
                  }
                  return _CartFilledBody(
                    cart: _cart,
                    giftWrapSelected: _giftWrapSelected,
                    promoExpanded: _promoExpanded,
                    onGiftWrapChanged: (v) =>
                        setState(() => _giftWrapSelected = v),
                    onPromoToggle: () => setState(
                      () => _promoExpanded = !_promoExpanded,
                    ),
                    onApplyPromo: () => _toast('Promokod tətbiq edildi'),
                    onFavorite: (item) async {
                      await TarzWishlistController.instance
                          .add(_previewFromItem(item));
                      _toast('Favorilərə köçürüldü');
                    },
                    onRemove: (item) async {
                      await _cart.removeItem(item.id);
                      _toast('Məhsul silindi');
                    },
                  );
                },
              ),
            ),
            ListenableBuilder(
              listenable: _cart,
              builder: (context, _) {
                if (_cart.isEmpty || (_cart.isLoading && _cart.isEmpty)) {
                  return const SizedBox.shrink();
                }
                return TarzCartStickyCheckout(
                  onCheckout: _checkoutBusy ? null : _startCheckout,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool canPop, String itemCountLabel) {
    return Padding(
      padding: EdgeInsets.fromLTRB(canPop ? 4 : 16, 8, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (canPop)
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              style: IconButton.styleFrom(
                foregroundColor: TarzColors.ink,
                padding: const EdgeInsets.all(8),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Səbət',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: TarzColors.ink,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  itemCountLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: TarzColors.inkMuted.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps item rows scoped via [listRevision] + per-line listenables.
class _CartFilledBody extends StatelessWidget {
  const _CartFilledBody({
    required this.cart,
    required this.giftWrapSelected,
    required this.promoExpanded,
    required this.onGiftWrapChanged,
    required this.onPromoToggle,
    required this.onApplyPromo,
    required this.onFavorite,
    required this.onRemove,
  });

  final TarzCartController cart;
  final bool giftWrapSelected;
  final bool promoExpanded;
  final ValueChanged<bool> onGiftWrapChanged;
  final VoidCallback onPromoToggle;
  final VoidCallback onApplyPromo;
  final Future<void> Function(TarzCartItem item) onFavorite;
  final Future<void> Function(TarzCartItem item) onRemove;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: cart.reload,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            for (final id in cart.items.map((e) => e.id))
              ValueListenableBuilder<TarzCartItem>(
                key: ValueKey(id),
                valueListenable: cart.lineListenable(id),
                builder: (context, item, _) {
                  return TarzCartItemTile(
                    item: item,
                    onFavorite: () => onFavorite(item),
                    onRemove: () => onRemove(item),
                  );
                },
              ),
            const SizedBox(height: 4),
            ListenableBuilder(
              listenable: cart,
              builder: (context, _) {
                return TarzCartSummarySection(
                  summary: cart.buildSummary(
                    includeGiftWrap: giftWrapSelected,
                  ),
                  giftWrapSelected: giftWrapSelected,
                  onGiftWrapChanged: onGiftWrapChanged,
                );
              },
            ),
            TarzCartPromoSection(
              expanded: promoExpanded,
              onToggle: onPromoToggle,
              onApply: onApplyPromo,
            ),
          ],
        ),
      ),
    );
  }
}

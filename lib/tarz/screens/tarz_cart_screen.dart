import 'dart:async';

import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../cart/tarz_cart_controller.dart';
import '../models/tarz_cart_item.dart';
import '../models/tarz_order.dart';
import '../models/tarz_product_preview.dart';
import '../orders/tarz_orders_controller.dart';
import '../screens/epoint_payment_screen.dart';
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

  /// Yarımçıq ödəniş üçün saxlanmış orderId — kəsilmədən sonra verify etmək üçün.
  String? _pendingOrderId;

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

  // ---------------------------------------------------------------------------
  // Epoint card payment flow
  // ---------------------------------------------------------------------------

  Future<void> _startCheckout() async {
    // Dublikat klik qarşısını al.
    if (_checkoutBusy || _cart.isEmpty) return;

    // Auth yoxla.
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

    // Çatdırılma məlumatlarını topla.
    final user = await _authService.getCachedUser();
    if (!mounted) return;
    final request = await showTarzCheckoutSheet(
      context,
      initialPhone: user?.phone,
      isGiftWrapped: _giftWrapSelected,
    );
    if (request == null || !mounted) return;

    setState(() => _checkoutBusy = true);
    try {
      await _runEpointCheckout(request);
    } finally {
      if (mounted) setState(() => _checkoutBusy = false);
    }
  }

  /// Tam Epoint ödəniş axını: init → WebView → verify → (status polling) → nəticə.
  Future<void> _runEpointCheckout(TarzCheckoutRequest request) async {
    final service = _orders.service;

    // ─── 1. POST /checkout/epoint/init ───
    final EpointInitResult initResult;
    try {
      initResult = await service.initEpointPayment(
        deliveryType: request.deliveryMethod == TarzDeliveryMethod.delivery
            ? 'DELIVERY'
            : 'PICKUP',
        shippingAddress: request.deliveryMethod == TarzDeliveryMethod.delivery
            ? {
                'street': request.address ?? '',
                'city': request.city ?? '',
                'zipCode': request.postalCode ?? '',
              }
            : null,
        pickupBranch: request.deliveryMethod == TarzDeliveryMethod.pickup
            ? request.pickupBranch
            : null,
        isGiftWrapped: request.isGiftWrapped,
        clientOrigin: kEpointClientOrigin,
      );
    } catch (e) {
      if (mounted) _toast('Ödəniş başladıla bilmədi');
      // Init timeout-dan sonra retry etmə — backend artıq sifariş yaratmış ola bilər.
      return;
    }

    // Pending orderId-ni saxla — kəsilmədən sonra verify üçün.
    _pendingOrderId = initResult.orderId;

    if (!mounted) return;

    // ─── 2. WebView-da ödəniş URL-ini aç ───
    final paymentReturned = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => EpointPaymentScreen(
          paymentUrl: initResult.redirectUrl,
          orderId: initResult.orderId,
        ),
      ),
    );

    if (!mounted) return;

    if (paymentReturned != true) {
      // İstifadəçi WebView-ni bağladı / ləğv etdi.
      // Səbəti təmizləmə, uğur göstərmə.
      _toast('Ödəniş ləğv edildi');
      return;
    }

    // ─── 3. POST /checkout/epoint/verify-order ───
    await _verifyAndComplete(initResult.orderId, service);
  }

  /// Verify + status polling.
  Future<void> _verifyAndComplete(
    String orderId,
    OrderService service,
  ) async {
    if (!mounted) return;

    // Loading göstər.
    setState(() => _checkoutBusy = true);

    try {
      // 3a. Verify
      final verifyResult = await service.verifyEpointPayment(orderId: orderId);

      if (verifyResult.success) {
        // Backend təsdiqlədisə — uğur.
        await _onPaymentConfirmed(orderId);
        return;
      }

      // 3b. Verify nəticəsi müəyyən olmadıqda — GET /orders/:id ilə yoxla.
      await _pollPaymentStatus(orderId, service);
    } catch (e) {
      // Şəbəkə xətası — pending status check fallback.
      try {
        await _pollPaymentStatus(orderId, service);
      } catch (_) {
        if (mounted) {
          _toast('Ödəniş statusu yoxlanıla bilmədi. Sifarişlər səhifəsindən yoxlayın.');
        }
      }
    } finally {
      if (mounted) setState(() => _checkoutBusy = false);
    }
  }

  /// GET /orders/:id ilə bounded retries — paymentStatus-a bax.
  Future<void> _pollPaymentStatus(
    String orderId,
    OrderService service,
  ) async {
    const maxRetries = 5;
    const retryDelay = Duration(seconds: 3);

    for (int i = 0; i < maxRetries; i++) {
      if (!mounted) return;

      final order = await service.fetchOrderById(orderId);
      if (order == null) continue;

      final status = order.paymentStatusEnum;

      if (status == TarzPaymentStatus.success) {
        await _onPaymentConfirmed(orderId);
        return;
      }

      if (status == TarzPaymentStatus.failed) {
        if (mounted) _toast('Ödəniş uğursuz oldu');
        return;
      }

      // PENDING — bir az gözlə və yenidən yoxla.
      if (i < maxRetries - 1) {
        await Future<void>.delayed(retryDelay);
      }
    }

    // maxRetries bitdi, hələ pending.
    if (mounted) {
      _toast('Ödəniş hələ təsdiqlənməyib. Sifarişlər səhifəsindən yoxlayın.');
    }
  }

  /// Ödəniş təsdiqləndi — backend-dən yenilə (səbəti əl ilə təmizləmə).
  Future<void> _onPaymentConfirmed(String orderId) async {
    _pendingOrderId = null;

    // Backend-dən sifariş məlumatını al.
    TarzOrder? confirmedOrder;
    try {
      confirmedOrder = await _orders.service.fetchOrderById(orderId);
    } catch (_) {
      // Sifariş oxuma xətası ödəniş uğursuzluğu deyil.
    }

    // Backend-dən sifarişləri və səbəti yenilə.
    // Refresh xətası ödəniş xətası kimi göstərilmir.
    try {
      await _orders.reload();
    } catch (_) {}

    try {
      await _cart.reload();
    } catch (_) {}

    if (!mounted) return;

    if (confirmedOrder != null) {
      await showTarzOrderSuccessDialog(context, order: confirmedOrder);
    }

    if (mounted) {
      _toast('Ödəniş uğurla tamamlandı');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] TarzCartScreen');
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
    debugPrint('[rebuild] TarzCartScreen._CartFilledBody');
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

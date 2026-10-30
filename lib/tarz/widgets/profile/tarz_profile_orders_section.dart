import 'package:flutter/material.dart';

import '../../cart/tarz_price_utils.dart';
import '../../models/tarz_order.dart';
import '../../theme/tarz_colors.dart';
import 'order_tracking_bottom_sheet.dart';

/// Profil — son sifarişlər bölməsi.
class TarzProfileOrdersSection extends StatelessWidget {
  const TarzProfileOrdersSection({
    super.key,
    required this.orders,
    this.loading = false,
  });

  final List<TarzOrder> orders;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] TarzProfileOrdersSection');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Sifarişlərim',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: TarzColors.ink,
          ),
        ),
        const SizedBox(height: 12),
        if (loading && orders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (orders.isEmpty)
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Hələ sifarişiniz yoxdur',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: TarzColors.inkMuted.withValues(alpha: 0.9),
                ),
              ),
            ),
          )
        else
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(
              children: [
                for (var i = 0; i < orders.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _OrderTile(order: orders[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final TarzOrder order;

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    return '$d.$m.$y';
  }

  Color _statusColor(TarzOrderStatus status) {
    switch (status) {
      case TarzOrderStatus.ready:
        return const Color(0xFF2E7D32);
      case TarzOrderStatus.delivered:
        return const Color(0xFF1565C0);
      case TarzOrderStatus.cancelled:
        return const Color(0xFFC62828);
      case TarzOrderStatus.preparing:
        return const Color(0xFFE65100);
    }
  }

  String _paymentLabel(String raw) {
    final v = raw.toLowerCase();
    if (v.contains('success') || v.contains('paid')) return 'Ödəniş edildi';
    if (v.contains('pending')) return 'Ödəniş gözlənilir';
    if (v.contains('fail') || v.contains('cancel')) return 'Ödəniş alınmadı';
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${order.displayId}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TarzColors.ink,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => showOrderTrackingSheet(context, order),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.status.labelAz,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(order.status),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            order.itemCount > 0
                ? '${order.itemCount} məhsul · ${TarzPriceUtils.formatManatSpaced(order.totalManat)}'
                : TarzPriceUtils.formatManatSpaced(order.totalManat),
            style: TextStyle(
              fontSize: 13,
              color: TarzColors.inkMuted.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            [
              order.deliveryMethod.labelAz,
              if (order.paymentStatus != null &&
                  order.paymentStatus!.trim().isNotEmpty)
                _paymentLabel(order.paymentStatus!.trim()),
              _formatDate(order.createdAt),
            ].join(' · '),
            style: TextStyle(
              fontSize: 12,
              color: TarzColors.inkMuted.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

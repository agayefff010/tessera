import 'package:flutter/material.dart';

import '../../cart/tarz_price_utils.dart';
import '../../models/tarz_order.dart';
import '../../theme/tarz_colors.dart';
import '../../theme/tarz_spacing.dart';

// ---------------------------------------------------------------------------
// ORDER TRACKING STATUS — demo model
// ---------------------------------------------------------------------------

/// Tracking status stages for the progress bar.
///
/// **API migration:** Replace [OrderTrackingStatus.demoStage] with the real
/// value returned by the backend order-status endpoint.
enum OrderTrackingStatus {
  preparing,
  ready,
  delivering;

  String get labelAz {
    switch (this) {
      case OrderTrackingStatus.preparing:
        return 'Hazırlanır';
      case OrderTrackingStatus.ready:
        return 'Hazırdır';
      case OrderTrackingStatus.delivering:
        return 'Çatdırılır';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderTrackingStatus.preparing:
        return Icons.inventory_2_outlined;
      case OrderTrackingStatus.ready:
        return Icons.check_circle_outline_rounded;
      case OrderTrackingStatus.delivering:
        return Icons.local_shipping_outlined;
    }
  }

  /// Static demo value displayed in the bottom sheet.
  ///
  /// **API migration point:** When the backend status API is ready, replace
  /// this constant with the value parsed from the API response.
  static const OrderTrackingStatus demoStage = OrderTrackingStatus.ready;
}

// ---------------------------------------------------------------------------
// STATUS INFO — content per stage
// ---------------------------------------------------------------------------

class _StatusInfo {
  const _StatusInfo({required this.title, required this.description, required this.icon});
  final String title;
  final String description;
  final IconData icon;

  static _StatusInfo forStage(OrderTrackingStatus stage) {
    switch (stage) {
      case OrderTrackingStatus.preparing:
        return const _StatusInfo(
          title: 'Sifarişiniz hazırlanır',
          description: 'Məhsullarınız yığılır və paketlənir.',
          icon: Icons.inventory_2_outlined,
        );
      case OrderTrackingStatus.ready:
        return const _StatusInfo(
          title: 'Sifarişiniz hazırdır',
          description:
              'Məhsullarınız paketlənib, kuryerə təhvil verilməyə hazırdır.',
          icon: Icons.inventory_2_rounded,
        );
      case OrderTrackingStatus.delivering:
        return const _StatusInfo(
          title: 'Sifarişiniz yoldadır',
          description: 'Kuryeriniz məhsullarınızı çatdırır.',
          icon: Icons.local_shipping_outlined,
        );
    }
  }
}

// ---------------------------------------------------------------------------
// BOTTOM SHEET — public entry point
// ---------------------------------------------------------------------------

/// Shows the order tracking bottom sheet for the given [order].
///
/// Call this from the order status badge tap handler.
void showOrderTrackingSheet(BuildContext context, TarzOrder order) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => OrderTrackingBottomSheet(order: order),
  );
}

// ---------------------------------------------------------------------------
// WIDGET
// ---------------------------------------------------------------------------

/// Reusable order tracking bottom sheet content.
class OrderTrackingBottomSheet extends StatelessWidget {
  const OrderTrackingBottomSheet({super.key, required this.order});

  final TarzOrder order;

  // ── demo status ──────────────────────────────────────────────────────────
  /// **API migration point:** Replace this with the real status from the
  /// backend when the order-status endpoint is available.
  OrderTrackingStatus get _trackingStage => OrderTrackingStatus.demoStage;

  // ── helpers ──────────────────────────────────────────────────────────────
  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    return '$d.$m.$y';
  }

  @override
  Widget build(BuildContext context) {
    final stage = _trackingStage;
    final info = _StatusInfo.forStage(stage);
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── drag handle ──────────────────────────────────────────────────
          const _DragHandle(),

          // ── scrollable content ───────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // header
                  _Header(order: order, formatDate: _formatDate),

                  const SizedBox(height: 28),

                  // progress bar
                  _ProgressBar(activeStage: stage),

                  const SizedBox(height: 28),

                  // status info card
                  _StatusInfoCard(info: info),

                  const SizedBox(height: 24),

                  // product info
                  _ProductInfoSection(order: order),

                  const SizedBox(height: 20),

                  // delivery info
                  _DeliveryInfoSection(order: order),

                  const SizedBox(height: 28),

                  // bottom button
                  _CloseButton(onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SUB-WIDGETS
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ── header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.order, required this.formatDate});

  final TarzOrder order;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Sifarişin vəziyyəti',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TarzColors.ink,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: TarzColors.inkMuted.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [
              '#${order.displayId}',
              formatDate(order.createdAt),
            ].join(' · '),
            style: TextStyle(
              fontSize: 13,
              color: TarzColors.inkMuted.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── progress bar ───────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.activeStage});

  final OrderTrackingStatus activeStage;

  static const _stages = OrderTrackingStatus.values;

  @override
  Widget build(BuildContext context) {
    final activeIdx = activeStage.index;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            for (int i = 0; i < _stages.length; i++) ...[
              _StepCircle(
                stage: _stages[i],
                isCompleted: i < activeIdx,
                isActive: i == activeIdx,
              ),
              if (i < _stages.length - 1)
                Expanded(
                  child: Container(
                    height: 2.5,
                    color: i < activeIdx
                        ? TarzColors.ink
                        : const Color(0xFFE0E0E0),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.stage,
    required this.isCompleted,
    required this.isActive,
  });

  final OrderTrackingStatus stage;
  final bool isCompleted;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final filled = isCompleted || isActive;
    const size = 44.0;
    const iconSize = 20.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? TarzColors.ink : const Color(0xFFF0F0F0),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, size: iconSize, color: Colors.white)
                : Icon(
                    stage.icon,
                    size: iconSize,
                    color: filled ? Colors.white : const Color(0xFFB0B0B0),
                  ),
          ),
        ),
        const SizedBox(height: TarzSpacing.xs),
        Text(
          stage.labelAz,
          style: TextStyle(
            fontSize: 11,
            fontWeight: filled ? FontWeight.w600 : FontWeight.w500,
            color: filled ? TarzColors.ink : const Color(0xFFB0B0B0),
          ),
        ),
      ],
    );
  }
}

// ── status info card ───────────────────────────────────────────────────────

class _StatusInfoCard extends StatelessWidget {
  const _StatusInfoCard({required this.info});

  final _StatusInfo info;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TarzSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(info.icon, size: 22, color: TarzColors.ink),
            ),
            const SizedBox(width: TarzSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: TarzColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: TarzColors.inkMuted.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── product info section ───────────────────────────────────────────────────

class _ProductInfoSection extends StatelessWidget {
  const _ProductInfoSection({required this.order});

  final TarzOrder order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Məhsullar',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: TarzColors.ink,
          ),
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEEEEEE)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // thumbnail placeholder
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.checkroom_rounded,
                      size: 24,
                      color: Color(0xFFB0B0B0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.itemCount > 1
                            ? '${order.itemCount} məhsul'
                            : '1 məhsul',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: TarzColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Say: ${order.itemCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: TarzColors.inkMuted.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  TarzPriceUtils.formatManatSpaced(order.totalManat),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TarzColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── delivery info section ──────────────────────────────────────────────────

class _DeliveryInfoSection extends StatelessWidget {
  const _DeliveryInfoSection({required this.order});

  final TarzOrder order;

  @override
  Widget build(BuildContext context) {
    final hasAddress =
        order.address != null && order.address!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          label: 'Çatdırılma ünvanı',
          value: hasAddress ? order.address! : null,
        ),
        const SizedBox(height: 10),
        _InfoRow(
          label: 'Çatdırılma növü',
          value: order.deliveryMethod.labelAz,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: 6,
          color: TarzColors.inkMuted.withValues(alpha: 0.45),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label:  ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: TarzColors.inkMuted.withValues(alpha: 0.85),
                  ),
                ),
                TextSpan(
                  text: value ?? '—',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: TarzColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── close button ───────────────────────────────────────────────────────────

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: TarzColors.ink,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        child: const Text('Başa düşdüm'),
      ),
    );
  }
}

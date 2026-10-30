import 'package:flutter/material.dart';

import '../../models/tarz_order.dart';
import '../../theme/tarz_colors.dart';

enum TarzAuthPromptAction { login, register }

/// Qonaq istifadəçi — daxil ol / qeydiyyat.
Future<TarzAuthPromptAction?> showTarzAuthRequiredDialog(
  BuildContext context, {
  String message =
      'Davam etmək üçün daxil olun və ya qeydiyyatdan keçin.',
}) {
  return showDialog<TarzAuthPromptAction>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Hesab lazımdır'),
      content: Text(
        message,
        style: const TextStyle(fontSize: 14, height: 1.45),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Bağla'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(TarzAuthPromptAction.register),
          child: const Text('Qeydiyyatdan keç'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(TarzAuthPromptAction.login),
          style: FilledButton.styleFrom(
            backgroundColor: TarzColors.ink,
            foregroundColor: Colors.white,
          ),
          child: const Text('Daxil ol'),
        ),
      ],
    ),
  );
}

/// Sifariş təsdiqi — götürmə / çatdırılma seçimi.
///
/// [isGiftWrapped] hədiyyə sarğı seçimi — checkout sheet-ə xaricdən ötürülür.
Future<TarzCheckoutRequest?> showTarzCheckoutSheet(
  BuildContext context, {
  String? initialPhone,
  bool isGiftWrapped = false,
}) {
  return showModalBottomSheet<TarzCheckoutRequest>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _TarzCheckoutSheet(
      initialPhone: initialPhone,
      isGiftWrapped: isGiftWrapped,
    ),
  );
}

class _TarzCheckoutSheet extends StatefulWidget {
  const _TarzCheckoutSheet({
    this.initialPhone,
    this.isGiftWrapped = false,
  });

  final String? initialPhone;
  final bool isGiftWrapped;

  @override
  State<_TarzCheckoutSheet> createState() => _TarzCheckoutSheetState();
}

class _TarzCheckoutSheetState extends State<_TarzCheckoutSheet> {
  TarzDeliveryMethod _method = TarzDeliveryMethod.pickup;
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _postal = TextEditingController();
  final _phone = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null && widget.initialPhone!.isNotEmpty) {
      _phone.text = widget.initialPhone!;
    }
  }

  @override
  void dispose() {
    _address.dispose();
    _city.dispose();
    _postal.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (_method == TarzDeliveryMethod.delivery) {
      final address = _address.text.trim();
      final city = _city.text.trim();
      final phone = _phone.text.trim();
      if (address.isEmpty) {
        _showError('Çatdırılma ünvanını daxil edin');
        return;
      }
      if (city.isEmpty) {
        _showError('Şəhəri daxil edin');
        return;
      }
      if (phone.isEmpty) {
        _showError('Telefon nömrəsini daxil edin');
        return;
      }
      Navigator.of(context).pop(
        TarzCheckoutRequest(
          deliveryMethod: _method,
          address: address,
          city: city,
          postalCode: _postal.text.trim().isEmpty ? null : _postal.text.trim(),
          phone: phone,
          isGiftWrapped: widget.isGiftWrapped,
        ),
      );
      return;
    }

    // Pickup — mağaza adı sabit (branch API yoxdur, aşağıdakı gap-a bax).
    Navigator.of(context).pop(
      TarzCheckoutRequest(
        deliveryMethod: TarzDeliveryMethod.pickup,
        pickupBranch: 'Tessera Nizami',
        isGiftWrapped: widget.isGiftWrapped,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] TarzCheckoutSheet');
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sifarişi təsdiqlə',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TarzColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Çatdırılma üsulunu seçin',
              style: TextStyle(
                fontSize: 14,
                color: TarzColors.inkMuted.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 16),
            _DeliveryOption(
              title: TarzDeliveryMethod.pickup.labelAz,
              subtitle: 'Mağazadan özünüz götürün',
              selected: _method == TarzDeliveryMethod.pickup,
              onTap: () => setState(() => _method = TarzDeliveryMethod.pickup),
            ),
            const SizedBox(height: 10),
            _DeliveryOption(
              title: TarzDeliveryMethod.delivery.labelAz,
              subtitle: 'Ünvana çatdırılma',
              selected: _method == TarzDeliveryMethod.delivery,
              onTap: () => setState(() => _method = TarzDeliveryMethod.delivery),
            ),
            if (_method == TarzDeliveryMethod.delivery) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _address,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Ünvan *',
                  hintText: 'Küçə, bina, mənzil',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _city,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Şəhər *',
                  hintText: 'Bakı',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _postal,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Poçt indeksi (istəyə bağlı)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Telefon *',
                  hintText: '+994 XX XXX XX XX',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: TarzColors.ink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ödənişə keç',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryOption extends StatelessWidget {
  const _DeliveryOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? TarzColors.ink.withValues(alpha: 0.06) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? TarzColors.ink : const Color(0xFFE8E8E8),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? TarzColors.ink : TarzColors.inkMuted,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: TarzColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: TarzColors.inkMuted.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sifariş uğurlu dialoq.
Future<void> showTarzOrderSuccessDialog(
  BuildContext context, {
  required TarzOrder order,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Sifariş qəbul edildi'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sifariş nömrəniz:',
            style: TextStyle(
              fontSize: 14,
              color: TarzColors.inkMuted.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            order.id,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: TarzColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Status: ${order.status.labelAz}',
            style: const TextStyle(fontSize: 14, color: TarzColors.ink),
          ),
          if (order.paymentStatus != null) ...[
            const SizedBox(height: 4),
            Text(
              'Ödəniş: ${order.paymentStatusEnum.labelAz}',
              style: TextStyle(
                fontSize: 13,
                color: TarzColors.inkMuted.withValues(alpha: 0.9),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            order.deliveryMethod.labelAz,
            style: TextStyle(
              fontSize: 13,
              color: TarzColors.inkMuted.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            backgroundColor: TarzColors.ink,
            foregroundColor: Colors.white,
          ),
          child: const Text('Bağla'),
        ),
      ],
    ),
  );
}

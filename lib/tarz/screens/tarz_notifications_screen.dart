import 'package:flutter/material.dart';

import '../theme/tarz_colors.dart';

/// Bildirişlər səhifəsi.
class TarzNotificationsScreen extends StatelessWidget {
  const TarzNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: TarzColors.ink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Geri',
        ),
        title: const Text(
          'Bildirişlər',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: TarzColors.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: const _NotificationsEmptyState(),
    );
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 56,
              color: TarzColors.inkMuted.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hələ bildiriş yoxdur',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TarzColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni kampaniya və sifariş yeniləmələri burada görünəcək.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: TarzColors.inkMuted.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

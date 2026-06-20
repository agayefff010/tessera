import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../theme/tarz_breakpoints.dart';
import '../theme/tarz_colors.dart';

/// Profil səhifəsi.
class TarzProfileScreen extends StatelessWidget {
  const TarzProfileScreen({
    super.key,
    this.onWishlistTap,
    this.onOutfitsTap,
    this.onNotificationsTap,
  });

  final VoidCallback? onWishlistTap;
  final VoidCallback? onOutfitsTap;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = TarzBreakpoints.contentMaxWidth(constraints.maxWidth);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Profil',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: TarzColors.ink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ProfileHeader(
                    onLogin: () =>
                        Navigator.of(context).pushNamed(AppRoutes.login),
                    onRegister: () =>
                        Navigator.of(context).pushNamed(AppRoutes.register),
                  ),
                  const SizedBox(height: 24),
                  _MenuSection(
                    items: [
                      _ProfileMenuItem(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Sifarişlərim',
                        onTap: () => _toast(context, 'Sifarişlər'),
                      ),
                      _ProfileMenuItem(
                        icon: Icons.favorite_border_rounded,
                        title: 'Seçilmişlər',
                        onTap: onWishlistTap ?? () => _toast(context, 'Seçilmişlər'),
                      ),
                      _ProfileMenuItem(
                        icon: Icons.checkroom_outlined,
                        title: 'Kombinlərim',
                        onTap: onOutfitsTap ?? () => _toast(context, 'Kombinlərim'),
                      ),
                      _ProfileMenuItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Bildirişlər',
                        onTap: onNotificationsTap ??
                            () => Navigator.of(context)
                                .pushNamed(AppRoutes.notifications),
                      ),
                      _ProfileMenuItem(
                        icon: Icons.language_rounded,
                        title: 'Dil — Azərbaycan',
                        onTap: () => _toast(context, 'Dil seçimi'),
                      ),
                      _ProfileMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Kömək',
                        onTap: () => _toast(context, 'Kömək'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.onLogin,
    required this.onRegister,
  });

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: TarzColors.ink.withValues(alpha: 0.08),
              child: Icon(
                Icons.person_outline_rounded,
                size: 40,
                color: TarzColors.ink.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Şəxsi kabinetə daxil olun',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TarzColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sifarişlərinizi izləyin və seçilmişlərinizi saxlayın',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: TarzColors.inkMuted.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: onLogin,
                style: FilledButton.styleFrom(
                  backgroundColor: TarzColors.ink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Daxil ol',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: onRegister,
                style: OutlinedButton.styleFrom(
                  foregroundColor: TarzColors.ink,
                  side: const BorderSide(color: TarzColors.ink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Qeydiyyatdan keç',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.items});

  final List<_ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFEEEEEE)),
            items[i],
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: TarzColors.ink.withValues(alpha: 0.7)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: TarzColors.ink,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: TarzColors.inkMuted.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }
}

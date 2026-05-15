import 'package:flutter/material.dart';

import '../theme/tarz_spacing.dart';

/// Ana səhifə altı — tünd fon, akkordeon, tətbiq yükləmə, sosial şəbəkələr.
class TarzHomeFooter extends StatelessWidget {
  const TarzHomeFooter({super.key, this.onSectionTap});

  final void Function(String id)? onSectionTap;

  static const Color _bg = Color(0xFF121212);
  static const Color _muted = Color(0xFF9A9A9A);

  static const List<Color> _brandMarks = [
    Color(0xFFE85D04),
    Color(0xFF2774AE),
    Color(0xFFE63946),
    Color(0xFFF4D35E),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      dividerColor: Colors.white24,
      splashColor: Colors.white10,
      highlightColor: Colors.white10,
      listTileTheme: const ListTileThemeData(
        textColor: Colors.white,
        iconColor: Colors.white,
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        textColor: Colors.white,
        iconColor: Colors.white,
        collapsedTextColor: Colors.white,
        collapsedIconColor: Colors.white,
      ),
    );

    return ColoredBox(
      color: _bg,
      child: Theme(
        data: theme,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TarzSpacing.md,
            TarzSpacing.xl,
            TarzSpacing.md,
            TarzSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < _brandMarks.length; i++)
                    Padding(
                      padding: EdgeInsets.only(right: i == _brandMarks.length - 1 ? 10 : 3),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: _brandMarks[i],
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                        child: const SizedBox(width: 7, height: 7),
                      ),
                    ),
                  const Text(
                    'TESSERA',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'serif',
                      fontSize: 20,
                      letterSpacing: 2.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TarzSpacing.lg),
              _footerExpansion('Alıcılara', 'Çatdırılma, qaytarma və ödəniş haqqında.'),
              _footerExpansion('Satıcılara', 'Mağaza açmaq və məhsul yerləşdirmə.'),
              _footerExpansion('Dəstək', 'Əlaqə və tez-tez verilən suallar.'),
              _footerExpansion('Haqqımızda', 'TESSERA haqqında qısa məlumat.'),
              const SizedBox(height: TarzSpacing.lg),
              const Text(
                'Tərz tətbiqini yüklə',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: TarzSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _StoreChip(
                      label: 'App Store',
                      onTap: () => onSectionTap?.call('appstore'),
                    ),
                  ),
                  const SizedBox(width: TarzSpacing.sm),
                  Expanded(
                    child: _StoreChip(
                      label: 'Google Play',
                      onTap: () => onSectionTap?.call('play'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TarzSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialIcon(icon: Icons.photo_camera_outlined, onTap: () => onSectionTap?.call('ig')),
                  const SizedBox(width: TarzSpacing.lg),
                  _SocialIcon(icon: Icons.facebook, onTap: () => onSectionTap?.call('fb')),
                  const SizedBox(width: TarzSpacing.lg),
                  _SocialIcon(icon: Icons.music_note_rounded, onTap: () => onSectionTap?.call('tt')),
                ],
              ),
              const SizedBox(height: TarzSpacing.xl),
              Text(
                '© 2025 Tarz. Bütün müəllif hüquqları qorunur.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: _muted.withValues(alpha: 0.95),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerExpansion(String title, String body) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: TarzSpacing.md),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              color: _muted,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreChip extends StatelessWidget {
  const _StoreChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF121212),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 26),
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withValues(alpha: 0.08),
      ),
    );
  }
}

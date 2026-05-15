import 'package:flutter/material.dart';

import '../theme/tarz_spacing.dart';

/// «Sənin AI kombinlərin» blok — tünd fon, sol menyü, sağda şəkil şəbəkəsi.
class TarzAiOutfitsSection extends StatefulWidget {
  const TarzAiOutfitsSection({
    super.key,
    required this.tallImageAsset,
    required this.squareImageAsset1,
    required this.squareImageAsset2,
  });

  final String tallImageAsset;
  final String squareImageAsset1;
  final String squareImageAsset2;

  @override
  State<TarzAiOutfitsSection> createState() => _TarzAiOutfitsSectionState();
}

class _TarzAiOutfitsSectionState extends State<TarzAiOutfitsSection> {
  int _occasionIndex = 0;

  static const _occasions = [
    "Party’ə",
    'Toya',
    'Qışa',
    'Teatra',
    'İdmana',
  ];

  static const _title = 'Sənin AI kombinlərin';

  static const Color _panel = Color(0xFF1A2744);
  static const Color _titleColor = Color(0xFFD4DEE8);
  static const Color _muted = Color(0xFF9AABC4);
  static const Color _sparkle = Color(0xFFB8C5E0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TarzSpacing.md,
        TarzSpacing.md,
        TarzSpacing.md,
        TarzSpacing.xl,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ColoredBox(
          color: _panel,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              TarzSpacing.md,
              TarzSpacing.lg,
              TarzSpacing.md,
              TarzSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: _sparkle.withValues(alpha: 0.9)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: _titleColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                    Icon(Icons.auto_awesome, size: 16, color: _sparkle.withValues(alpha: 0.9)),
                  ],
                ),
                const SizedBox(height: TarzSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 92,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(_occasions.length, (i) {
                          final sel = i == _occasionIndex;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: () => setState(() => _occasionIndex = i),
                              child: Text(
                                _occasions[i],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                                  color: sel ? Colors.white : _muted,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    Expanded(child: _collage(context)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _collage(BuildContext context) {
    return SizedBox(
      height: 208,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final tallW = w * 0.5;
          final gap = 8.0;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 0,
                top: 0,
                width: tallW,
                height: 208,
                child: _tile(widget.tallImageAsset),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                width: w - tallW - gap,
                height: 98,
                child: _tile(widget.squareImageAsset1),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                width: tallW,
                height: 98,
                child: _tile(widget.squareImageAsset2),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(String asset) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ColoredBox(
          color: Colors.white.withValues(alpha: 0.12),
          child: const Center(
            child: Icon(Icons.image_not_supported_outlined, color: Colors.white38),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'tarz_filter_chip.dart';

/// «Fəsil» — üfüqi kompakt çiplər, çoxlu seçim.
class TarzFilterSeasonSection extends StatelessWidget {
  const TarzFilterSeasonSection({
    super.key,
    required this.selectedSeasons,
    required this.onSeasonToggled,
  });

  final Set<String> selectedSeasons;
  final ValueChanged<String> onSeasonToggled;

  static const _seasons = ['Yaz', 'Yay', 'Payız', 'Qış'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Fəsil'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _seasons.map((season) {
            return TarzFilterChip(
              label: season,
              selected: selectedSeasons.contains(season),
              compact: true,
              onTap: () => onSeasonToggled(season),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF121212),
      ),
    );
  }
}

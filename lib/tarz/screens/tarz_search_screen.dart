import 'package:flutter/material.dart';

import '../theme/tarz_colors.dart';
import '../widgets/tarz_home_search_bar.dart';

/// Axtarış ikonundan açılan tam səhifə.
class TarzSearchScreen extends StatefulWidget {
  const TarzSearchScreen({super.key});

  @override
  State<TarzSearchScreen> createState() => _TarzSearchScreenState();
}

class _TarzSearchScreenState extends State<TarzSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toast(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

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
          'Axtarış',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: TarzColors.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TarzHomeSearchBar(
              controller: _controller,
              onSearch: (q) {
                final t = q.trim();
                if (t.isEmpty) {
                  _toast('Axtarış üçün mətn daxil edin');
                  return;
                }
                _toast('Axtarış: $t');
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: Text(
                    'Məhsul, brend və ya rəng yazın və «Axtar» düyməsinə basın.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: TarzColors.inkMuted.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

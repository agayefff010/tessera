import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/tarz_colors.dart';

class TarzReviewImageDraft {
  const TarzReviewImageDraft({
    required this.name,
    required this.bytes,
  });

  final String name;
  final Uint8List bytes;
}

class TarzWriteReviewResult {
  const TarzWriteReviewResult({
    required this.rating,
    required this.comment,
    this.images = const [],
  });

  final int rating;
  final String comment;
  final List<TarzReviewImageDraft> images;
}

/// Rəy yazmaq — ulduz + mətn + qalereyadan şəkil.
Future<TarzWriteReviewResult?> showTarzWriteReviewSheet(BuildContext context) {
  return showModalBottomSheet<TarzWriteReviewResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _WriteReviewSheet(),
  );
}

class _WriteReviewSheet extends StatefulWidget {
  const _WriteReviewSheet();

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  static const Color _starColor = Color(0xFFFFB300);
  static const int _maxImages = 5;

  final _comment = TextEditingController();
  final _picker = ImagePicker();
  final List<TarzReviewImageDraft> _images = [];

  int _rating = 0;
  String? _error;
  bool _pickingImages = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    if (_pickingImages) return;
    if (_images.length >= _maxImages) {
      setState(() => _error = 'Ən çoxu $_maxImages şəkil əlavə edə bilərsiniz');
      return;
    }

    setState(() {
      _pickingImages = true;
      _error = null;
    });

    try {
      final remaining = _maxImages - _images.length;
      final picked = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1600,
        limit: remaining,
      );
      if (!mounted || picked.isEmpty) return;

      final loaded = <TarzReviewImageDraft>[];
      for (final file in picked) {
        if (_images.length + loaded.length >= _maxImages) break;
        final bytes = await file.readAsBytes();
        if (bytes.isEmpty) continue;
        final name = (file.name.trim().isNotEmpty)
            ? file.name
            : 'review_${DateTime.now().millisecondsSinceEpoch}.jpg';
        loaded.add(TarzReviewImageDraft(name: name, bytes: bytes));
      }

      if (!mounted) return;
      setState(() => _images.addAll(loaded));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Şəkil seçilmədi');
    } finally {
      if (mounted) setState(() => _pickingImages = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      _error = null;
    });
  }

  void _submit() {
    final text = _comment.text.trim();
    if (_rating < 1) {
      setState(() => _error = 'Reytinq seçin');
      return;
    }
    if (text.isEmpty) {
      setState(() => _error = 'Rəy mətnini yazın');
      return;
    }
    Navigator.of(context).pop(
      TarzWriteReviewResult(
        rating: _rating,
        comment: text,
        images: List.unmodifiable(_images),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rəy yaz',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: TarzColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Məhsulu qiymətləndirin və təcrübənizi paylaşın',
              style: TextStyle(
                fontSize: 13,
                color: TarzColors.inkMuted.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final value = index + 1;
                final selected = value <= _rating;
                return IconButton(
                  onPressed: () => setState(() {
                    _rating = value;
                    _error = null;
                  }),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                  icon: Icon(
                    selected ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 34,
                    color: _starColor,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _comment,
              maxLines: 4,
              minLines: 3,
              maxLength: 500,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                hintText: 'Rəyinizi yazın...',
                hintStyle: TextStyle(
                  color: TarzColors.inkMuted.withValues(alpha: 0.7),
                ),
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: TarzColors.ink, width: 1),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Şəkillər (istəyə görə)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TarzColors.inkMuted.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 88,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _AddPhotoTile(
                    loading: _pickingImages,
                    enabled: _images.length < _maxImages,
                    onTap: _pickFromGallery,
                  ),
                  for (var i = 0; i < _images.length; i++) ...[
                    const SizedBox(width: 8),
                    _SelectedPhotoTile(
                      bytes: _images[i].bytes,
                      onRemove: () => _removeImage(i),
                    ),
                  ],
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
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
                  'Göndər',
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

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F7F7),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled && !loading ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 88,
          height: 88,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.photo_library_outlined,
                  size: 28,
                  color: enabled
                      ? TarzColors.ink
                      : TarzColors.inkMuted.withValues(alpha: 0.5),
                ),
              const SizedBox(height: 6),
              Text(
                'Qalereya',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? TarzColors.inkMuted
                      : TarzColors.inkMuted.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedPhotoTile extends StatelessWidget {
  const _SelectedPhotoTile({
    required this.bytes,
    required this.onRemove,
  });

  final Uint8List bytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFFECECEC)),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.black.withValues(alpha: 0.55),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

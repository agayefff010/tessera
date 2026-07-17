import 'package:flutter/foundation.dart';

@immutable
class TarzProductReview {
  const TarzProductReview({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.authorName,
    this.userId,
    this.imageUrls = const [],
  });

  final String id;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? authorName;
  final String? userId;
  final List<String> imageUrls;

  String get authorLabel {
    final name = authorName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final id = userId;
    if (id != null && id.length >= 4) {
      return 'İstifadəçi ${id.substring(id.length - 4)}';
    }
    return 'İstifadəçi';
  }

  String get dateLabel {
    const months = [
      'yanvar',
      'fevral',
      'mart',
      'aprel',
      'may',
      'iyun',
      'iyul',
      'avqust',
      'sentyabr',
      'oktyabr',
      'noyabr',
      'dekabr',
    ];
    final m = months[(createdAt.month - 1).clamp(0, 11)];
    return '${createdAt.day} $m ${createdAt.year}';
  }
}

@immutable
class TarzProductReviewsResult {
  const TarzProductReviewsResult({
    required this.reviews,
    required this.totalReviews,
    required this.averageRating,
  });

  final List<TarzProductReview> reviews;
  final int totalReviews;
  final double averageRating;

  static const empty = TarzProductReviewsResult(
    reviews: [],
    totalReviews: 0,
    averageRating: 0,
  );
}

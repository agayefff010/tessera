import '../models/tarz_product_review.dart';

/// Backend `/products/:id/reviews` JSON → UI modeli.
abstract final class ReviewMapper {
  static TarzProductReviewsResult fromResponse(Map<String, dynamic> body) {
    final total = _asInt(body['totalReviews']) ?? 0;
    final average = _asDouble(body['averageRating']) ?? 0;
    final raw = body['data'] ?? body['reviews'];
    final reviews = <TarzProductReview>[];

    if (raw is List) {
      for (final item in raw) {
        if (item is! Map<String, dynamic>) continue;
        final review = fromJson(item);
        if (review != null) reviews.add(review);
      }
    }

    return TarzProductReviewsResult(
      reviews: reviews,
      totalReviews: total > 0 ? total : reviews.length,
      averageRating: average,
    );
  }

  static TarzProductReview? fromJson(Map<String, dynamic> json) {
    final id = json['_id']?.toString();
    if (id == null || id.isEmpty) return null;

    final rating = _asDouble(json['rating']) ?? 0;
    final comment = json['comment']?.toString() ?? '';
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now();

    String? userId;
    String? authorName;
    final user = json['user'];
    if (user is Map<String, dynamic>) {
      userId = user['_id']?.toString();
      authorName = user['name']?.toString() ?? user['fullName']?.toString();
    } else if (user is String) {
      userId = user;
    }

    final images = <String>[];
    final rawImages = json['images'];
    if (rawImages is List) {
      for (final img in rawImages) {
        final url = img?.toString();
        if (url != null && url.isNotEmpty) images.add(url);
      }
    }

    final approved = json['isApproved'];
    if (approved is bool && !approved) return null;

    return TarzProductReview(
      id: id,
      rating: rating.clamp(0, 5),
      comment: comment,
      createdAt: createdAt,
      authorName: authorName,
      userId: userId,
      imageUrls: images,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}

/// Ana səhifə reklam / slider banneri.
class TarzHomeBanner {
  const TarzHomeBanner({
    required this.id,
    required this.imageUrl,
    this.title,
    this.link,
    this.vendorId,
    this.vendorSlug,
  });

  final String id;
  final String imageUrl;
  final String? title;
  final String? link;
  final String? vendorId;
  final String? vendorSlug;
}

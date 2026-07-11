/// Ana səhifə slider banneri.
class TarzHomeBanner {
  const TarzHomeBanner({
    required this.id,
    required this.imageUrl,
    this.title,
    this.link,
  });

  final String id;
  final String imageUrl;
  final String? title;
  final String? link;
}

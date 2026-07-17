/// Backend vendor / mağaza profili.
class TarzVendor {
  const TarzVendor({
    required this.id,
    required this.name,
    required this.slug,
    this.profileImageUrl,
    this.description,
    this.address,
    this.openHours,
    this.phone,
    this.storeAddresses = const [],
    this.deliveryAvailable,
    this.companyName,
  });

  final String id;
  final String name;
  final String slug;
  final String? profileImageUrl;
  final String? description;
  final String? address;
  final String? openHours;
  final String? phone;
  final List<String> storeAddresses;
  final bool? deliveryAvailable;
  final String? companyName;
}

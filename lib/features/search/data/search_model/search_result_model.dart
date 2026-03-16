class SearchResultModel {
  final String id;
  final String title;
  final String description;
  final double pricePerNight;
  final String location;
  final String city;
  final String country;
  final int maxGuests;
  final List<ListingImage> images;
  final HostModel? host;
  final String? propertyTypeName;

  SearchResultModel({
    required this.id,
    required this.title,
    required this.description,
    required this.pricePerNight,
    required this.location,
    required this.city,
    required this.country,
    required this.maxGuests,
    required this.images,
    this.host,
    this.propertyTypeName,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      // بنستخدم display_price عشان شامل الخصومات لو موجودة
      pricePerNight: (json['display_price'] ?? json['price_per_night'] ?? 0)
          .toDouble(),
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      maxGuests: json['max_guests'] ?? 0,
      // تحويل لستة الصور
      images:
          (json['images_json'] as List?)
              ?.map((i) => ListingImage.fromJson(i))
              .toList() ??
          [],
      // تحويل بيانات الهوست
      host: json['host_json'] != null
          ? HostModel.fromJson(json['host_json'])
          : null,
      // تحويل نوع العقار (لو عايز الاسم بالعربي)
      propertyTypeName:
          json['property_type_json']?['translations']?['ar']?['name'],
    );
  }
}

class ListingImage {
  final String url;
  final int order;

  ListingImage({required this.url, required this.order});

  factory ListingImage.fromJson(Map<String, dynamic> json) {
    return ListingImage(url: json['url'] ?? '', order: json['order'] ?? 0);
  }
}

class HostModel {
  final String fullName;
  final String? avatarUrl;

  HostModel({required this.fullName, this.avatarUrl});

  factory HostModel.fromJson(Map<String, dynamic> json) {
    return HostModel(
      fullName: json['full_name'] ?? 'مضيف غير معروف',
      avatarUrl: json['avatar_url'],
    );
  }
}

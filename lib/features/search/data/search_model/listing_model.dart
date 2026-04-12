import 'package:freelancer/features/search/data/search_model/host_model.dart';

class ListingModel {
  final String? id;
  final String? userId;
  final String? title;
  final String? description;
  final double? pricePerNight;
  final String? location;
  final String? city;
  final String? state;
  final String? country;
  final int? maxGuests;
  final int? bedrooms;
  final int? beds;
  final int? bathrooms;
  final String? propertyTypeId;
  final bool? isGuestFavorite;
  final bool? isPublished;
  final double? cleaningFee;
  final String? currency;
  final String? cancellationPolicy;
  final String? listingCode;
  final double? lat;
  final double? lng;
  final String? googleMapsLink;
  final double? displayPrice;
  final DateTime? createdAt;
  final HostModel? host;
  final PropertyTypeModel? propertyType;
  final List<ListingImage>? images;
  final List<LifestyleModel>? lifestyles;
  final String? hostId;
  final Map<String, dynamic>? translations;

  ListingModel({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.pricePerNight,
    this.location,
    this.city,
    this.state,
    this.country,
    this.maxGuests,
    this.bedrooms,
    this.beds,
    this.bathrooms,
    this.propertyTypeId,
    this.isGuestFavorite,
    this.isPublished,
    this.cleaningFee,
    this.currency,
    this.cancellationPolicy,
    this.listingCode,
    this.createdAt,
    this.lat,
    this.lng,
    this.googleMapsLink,
    this.displayPrice,
    this.host,
    this.propertyType,
    this.images,
    this.lifestyles,
    this.hostId,
    this.translations,
  });

  // ✅ ميثود الـ copyWith عشان تخلي شغلك Dynamic 100%
  ListingModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    double? pricePerNight,
    String? location,
    String? city,
    String? state,
    String? country,
    int? maxGuests,
    int? bedrooms,
    int? beds,
    int? bathrooms,
    String? propertyTypeId,
    bool? isGuestFavorite,
    bool? isPublished,
    double? cleaningFee,
    String? currency,
    String? cancellationPolicy,
    String? listingCode,
    double? lat,
    double? lng,
    String? googleMapsLink,
    double? displayPrice,
    DateTime? createdAt,
    HostModel? host,
    PropertyTypeModel? propertyType,
    List<ListingImage>? images,
    List<LifestyleModel>? lifestyles,
    Map<String, dynamic>? translations,
  }) {
    return ListingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      location: location ?? this.location,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      maxGuests: maxGuests ?? this.maxGuests,
      bedrooms: bedrooms ?? this.bedrooms,
      beds: beds ?? this.beds,
      bathrooms: bathrooms ?? this.bathrooms,
      propertyTypeId: propertyTypeId ?? this.propertyTypeId,
      isGuestFavorite: isGuestFavorite ?? this.isGuestFavorite,
      isPublished: isPublished ?? this.isPublished,
      cleaningFee: cleaningFee ?? this.cleaningFee,
      currency: currency ?? this.currency,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      listingCode: listingCode ?? this.listingCode,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      googleMapsLink: googleMapsLink ?? this.googleMapsLink,
      displayPrice: displayPrice ?? this.displayPrice,
      createdAt: createdAt ?? this.createdAt,
      host: host ?? this.host,
      propertyType: propertyType ?? this.propertyType,
      images: images ?? this.images,
      lifestyles: lifestyles ?? this.lifestyles,
      hostId: hostId ?? this.hostId,
      translations: translations ?? this.translations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId ?? hostId,
      'host_id': hostId ?? userId,
      'title': title,
      'description': description,
      'price_per_night': pricePerNight,
      'location': location,
      'city': city,
      'state': state,
      'country': country,
      'max_guests': maxGuests,
      'bedrooms': bedrooms,
      'beds': beds,
      'bathrooms': bathrooms,
      'property_type_id': propertyTypeId,
      'is_guest_favorite': isGuestFavorite,
      'is_published': isPublished,
      'cleaning_fee': cleaningFee,
      'currency': currency,
      'cancellation_policy': cancellationPolicy,
      'listing_code': listingCode,
      'google_maps_link': googleMapsLink,
      'lat': lat,
      'lng': lng,
    };
  }

  // الـ Logic بتاع استخراج الإحداثيات من اللينك
  static double? _parseLat(String? link) {
    if (link == null) return null;
    final pinRegExp = RegExp(r'3d([0-9.-]+)!4d([0-9.-]+)');
    final pinMatch = pinRegExp.firstMatch(link);
    if (pinMatch != null && pinMatch.groupCount >= 2) {
      return double.tryParse(pinMatch.group(1)!);
    }
    final regExp = RegExp(r'@([0-9.-]+),([0-9.-]+)');
    final match = regExp.firstMatch(link);
    if (match != null && match.groupCount >= 2) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  static double? _parseLng(String? link) {
    if (link == null) return null;
    final pinRegExp = RegExp(r'3d([0-9.-]+)!4d([0-9.-]+)');
    final pinMatch = pinRegExp.firstMatch(link);
    if (pinMatch != null && pinMatch.groupCount >= 2) {
      return double.tryParse(pinMatch.group(2)!);
    }
    final regExp = RegExp(r'@([0-9.-]+),([0-9.-]+)');
    final match = regExp.firstMatch(link);
    if (match != null && match.groupCount >= 2) {
      return double.tryParse(match.group(2)!);
    }
    return null;
  }

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    var arTranslation = json['translations']?['ar'];

    return ListingModel(
      id: json['id'],
      userId: json['user_id'],
      title: arTranslation?['title'] ?? json['title'],
      description: arTranslation?['description'] ?? json['description'],
      pricePerNight: (json['price_per_night'] as num?)?.toDouble(),
      location: json['location'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      maxGuests: json['max_guests'],
      bedrooms: json['bedrooms'],
      beds: json['beds'],
      bathrooms: json['bathrooms'],
      propertyTypeId: json['property_type_id'],
      isGuestFavorite: json['is_guest_favorite'] ?? false,
      isPublished: json['is_published'] ?? false,
      cleaningFee: (json['cleaning_fee'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'EGP',
      cancellationPolicy: json['cancellation_policy'],
      listingCode: json['listing_code'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      googleMapsLink: json['google_maps_link'],
      lat:
          (json['lat'] as num?)?.toDouble() ??
          _parseLat(json['google_maps_link']),
      lng:
          (json['lng'] as num?)?.toDouble() ??
          _parseLng(json['google_maps_link']),
      displayPrice: (json['display_price'] as num?)?.toDouble(),
      host: json['host_json'] != null
          ? HostModel.fromJson(json['host_json'])
          : null,
      propertyType: json['property_type_json'] != null
          ? PropertyTypeModel.fromJson(json['property_type_json'])
          : null,
      images:
          (json['listing_images'] as List?)
              ?.map((i) => ListingImage.fromJson(i))
              .toList() ??
          (json['images_json'] as List?)
              ?.map((i) => ListingImage.fromJson(i))
              .toList(),
      lifestyles: (json['lifestyles_json'] as List?)
          ?.map((i) => LifestyleModel.fromJson(i))
          .toList(),
      translations: json['translations'],
      hostId: json['host_id'] ?? json['user_id'],
    );
  }
}

class ListingImage {
  final String? id;
  final String? url;
  final int? order;
  final String? category;

  ListingImage({this.id, this.url, this.order, this.category});

  factory ListingImage.fromJson(Map<String, dynamic> json) {
    return ListingImage(
      id: json['id'],
      url: json['url'],
      order: json['order'],
      category: json['category'],
    );
  }
}

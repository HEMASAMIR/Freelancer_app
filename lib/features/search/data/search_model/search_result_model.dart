class SearchResultModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double pricePerNight;
  final String location;
  final String city;
  final String state;
  final String country;
  final int maxGuests;
  final int bedrooms;
  final int beds;
  final int bathrooms;
  final String propertyTypeId;
  final bool isGuestFavorite;
  final bool isPublished;
  final double cleaningFee;
  final String currency;
  final String cancellationPolicy;
  final String listingCode;
  final String createdAt;
  final String updatedAt;
  final double avgRating;
  final int reviewCount;
  final double lat;
  final double lng;
  final double? bestOfferPrice;
  final double displayPrice;
  final double? totalPrice;
  final int? numNights;
  final int totalCount;
  final HostModel host;
  final PropertyTypeModel propertyType;
  final List<ListingImageModel> images;
  final List<LifestyleModel> lifestyles;

  const SearchResultModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.pricePerNight,
    required this.location,
    required this.city,
    required this.state,
    required this.country,
    required this.maxGuests,
    required this.bedrooms,
    required this.beds,
    required this.bathrooms,
    required this.propertyTypeId,
    required this.isGuestFavorite,
    required this.isPublished,
    required this.cleaningFee,
    required this.currency,
    required this.cancellationPolicy,
    required this.listingCode,
    required this.createdAt,
    required this.updatedAt,
    required this.avgRating,
    required this.reviewCount,
    required this.lat,
    required this.lng,
    this.bestOfferPrice,
    required this.displayPrice,
    this.totalPrice,
    this.numNights,
    required this.totalCount,
    required this.host,
    required this.propertyType,
    required this.images,
    required this.lifestyles,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      pricePerNight: (json['price_per_night'] as num).toDouble(),
      location: json['location'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      maxGuests: json['max_guests'] as int,
      bedrooms: json['bedrooms'] as int,
      beds: json['beds'] as int,
      bathrooms: json['bathrooms'] as int,
      propertyTypeId: json['property_type_id'] as String,
      isGuestFavorite: json['is_guest_favorite'] as bool,
      isPublished: json['is_published'] as bool,
      cleaningFee: (json['cleaning_fee'] as num).toDouble(),
      currency: json['currency'] as String,
      cancellationPolicy: json['cancellation_policy'] as String,
      listingCode: json['listing_code'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      avgRating: (json['avg_rating'] as num).toDouble(),
      reviewCount: json['review_count'] as int,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      bestOfferPrice: json['best_offer_price'] != null
          ? (json['best_offer_price'] as num).toDouble()
          : null,
      displayPrice: (json['display_price'] as num).toDouble(),
      totalPrice: json['total_price'] != null
          ? (json['total_price'] as num).toDouble()
          : null,
      numNights: json['num_nights'] as int?,
      totalCount: json['total_count'] as int,
      host: HostModel.fromJson(json['host_json'] as Map<String, dynamic>),
      propertyType: PropertyTypeModel.fromJson(
        json['property_type_json'] as Map<String, dynamic>,
      ),
      images: (json['images_json'] as List)
          .map((e) => ListingImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      lifestyles: (json['lifestyles_json'] as List)
          .map((e) => LifestyleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Host ──────────────────────────────────────────────────────

class HostModel {
  final String id;
  final String? bio;
  final String email;
  final String? phone;
  final String fullName;
  final String? avatarUrl;
  final String? selfieUrl;
  final bool isHost;
  final int verificationStatusId;
  final String? verifiedAt;

  const HostModel({
    required this.id,
    this.bio,
    required this.email,
    this.phone,
    required this.fullName,
    this.avatarUrl,
    this.selfieUrl,
    required this.isHost,
    required this.verificationStatusId,
    this.verifiedAt,
  });

  factory HostModel.fromJson(Map<String, dynamic> json) => HostModel(
    id: json['id'] as String,
    bio: json['bio'] as String?,
    email: json['email'] as String,
    phone: json['phone'] as String?,
    fullName: json['full_name'] as String,
    avatarUrl: json['avatar_url'] as String?,
    selfieUrl: json['selfie_url'] as String?,
    isHost: json['is_host'] as bool,
    verificationStatusId: json['verification_status_id'] as int,
    verifiedAt: json['verified_at'] as String?,
  );
}

// ── Property Type ─────────────────────────────────────────────

class PropertyTypeModel {
  final String id;
  final String icon;
  final String name;
  final String slug;
  final String type;
  final String description;

  const PropertyTypeModel({
    required this.id,
    required this.icon,
    required this.name,
    required this.slug,
    required this.type,
    required this.description,
  });

  factory PropertyTypeModel.fromJson(Map<String, dynamic> json) =>
      PropertyTypeModel(
        id: json['id'] as String,
        icon: json['icon'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        type: json['type'] as String,
        description: json['description'] as String,
      );
}

// ── Image ─────────────────────────────────────────────────────

class ListingImageModel {
  final String url;
  final int order;

  const ListingImageModel({required this.url, required this.order});

  factory ListingImageModel.fromJson(Map<String, dynamic> json) =>
      ListingImageModel(
        url: json['url'] as String,
        order: json['order'] as int,
      );
}

// ── Lifestyle ─────────────────────────────────────────────────

class LifestyleModel {
  final bool isPrimary;
  final LifestyleCategoryModel category;

  const LifestyleModel({required this.isPrimary, required this.category});

  factory LifestyleModel.fromJson(Map<String, dynamic> json) => LifestyleModel(
    isPrimary: json['is_primary'] as bool,
    category: LifestyleCategoryModel.fromJson(
      json['lifestyle_category'] as Map<String, dynamic>,
    ),
  );
}

class LifestyleCategoryModel {
  final String id;
  final String icon;
  final String name;
  final String slug;
  final int displayOrder;

  const LifestyleCategoryModel({
    required this.id,
    required this.icon,
    required this.name,
    required this.slug,
    required this.displayOrder,
  });

  factory LifestyleCategoryModel.fromJson(Map<String, dynamic> json) =>
      LifestyleCategoryModel(
        id: json['id'] as String,
        icon: json['icon'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        displayOrder: json['display_order'] as int,
      );
}

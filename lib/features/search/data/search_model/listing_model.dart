import 'dart:convert';
import 'package:freelancer/features/search/data/search_model/host_model.dart';

class ListingModel {
  final String? id;
  final String? userId;
  final String? title;
  final String? description;
  final double? pricePerNight;
  final String? location;
  final String? cityId;
  final String? stateId;
  final String? countryId;
  // Resolved name fields (filled by RPC or lookup)
  final String? cityName;
  final String? stateName;
  final String? countryName;
  final int? maxGuests;
  final int? bedrooms;
  final int? beds;
  final int? bathrooms;
  final String? propertyTypeId;
  final bool? isGuestFavorite;
  final bool? isBestOffer;
  final bool? isPublished;
  final double? cleaningFee;
  final String? currency;
  final String? cancellationPolicy;
  final String? listingCode;
  final int? minNights;
  final double? lat;
  final double? lng;
  final String? locationGeo;
  final String? googleMapsLink;
  final double? displayPrice;
  final DateTime? createdAt;
  final HostModel? host;
  final PropertyTypeModel? propertyType;
  final List<ListingImage>? images;
  final List<LifestyleModel>? lifestyles;
  final Map<String, dynamic>? translations;

  ListingModel({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.pricePerNight,
    this.location,
    this.cityId,
    this.stateId,
    this.countryId,
    this.cityName,
    this.stateName,
    this.countryName,
    this.maxGuests,
    this.bedrooms,
    this.beds,
    this.bathrooms,
    this.propertyTypeId,
    this.isGuestFavorite,
    this.isBestOffer,
    this.isPublished,
    this.cleaningFee,
    this.currency,
    this.cancellationPolicy,
    this.listingCode,
    this.minNights,
    this.createdAt,
    this.lat,
    this.lng,
    this.locationGeo,
    this.googleMapsLink,
    this.displayPrice,
    this.host,
    this.propertyType,
    this.images,
    this.lifestyles,
    this.translations,
  });

  // Helper getters: return resolved name first, NEVER fallback to UUID for display
  String? get city => _filterUuid(cityName);
  String? get state => _filterUuid(stateName);
  String? get country => _filterUuid(countryName);

  String? get displayLocation {
    final c = city;
    final co = country;
    if (c != null && co != null) return '$c, $co';
    if (c != null) return c;
    if (co != null) return co;
    return _filterUuid(location);
  }

  String? _filterUuid(String? value) {
    if (value == null) return null;
    if (value.length > 30 && value.contains('-')) return null; // Likely a UUID
    return value;
  }

  @Deprecated('Use userId')
  String? get hostId => userId;

  ListingModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    double? pricePerNight,
    String? location,
    String? cityId,
    String? stateId,
    String? countryId,
    String? cityName,
    String? stateName,
    String? countryName,
    int? maxGuests,
    int? bedrooms,
    int? beds,
    int? bathrooms,
    String? propertyTypeId,
    bool? isGuestFavorite,
    bool? isBestOffer,
    bool? isPublished,
    double? cleaningFee,
    String? currency,
    String? cancellationPolicy,
    String? listingCode,
    int? minNights,
    double? lat,
    double? lng,
    String? locationGeo,
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
      cityId: cityId ?? this.cityId,
      stateId: stateId ?? this.stateId,
      countryId: countryId ?? this.countryId,
      cityName: cityName ?? this.cityName,
      stateName: stateName ?? this.stateName,
      countryName: countryName ?? this.countryName,
      maxGuests: maxGuests ?? this.maxGuests,
      bedrooms: bedrooms ?? this.bedrooms,
      beds: beds ?? this.beds,
      bathrooms: bathrooms ?? this.bathrooms,
      propertyTypeId: propertyTypeId ?? this.propertyTypeId,
      isGuestFavorite: isGuestFavorite ?? this.isGuestFavorite,
      isBestOffer: isBestOffer ?? this.isBestOffer,
      isPublished: isPublished ?? this.isPublished,
      cleaningFee: cleaningFee ?? this.cleaningFee,
      currency: currency ?? this.currency,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      listingCode: listingCode ?? this.listingCode,
      minNights: minNights ?? this.minNights,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      locationGeo: locationGeo ?? this.locationGeo,
      googleMapsLink: googleMapsLink ?? this.googleMapsLink,
      displayPrice: displayPrice ?? this.displayPrice,
      createdAt: createdAt ?? this.createdAt,
      host: host ?? this.host,
      propertyType: propertyType ?? this.propertyType,
      images: images ?? this.images,
      lifestyles: lifestyles ?? this.lifestyles,
      translations: translations ?? this.translations,
    );
  }

  Map<String, dynamic> toJson() {
    final locationGeoValue =
        (lat != null && lng != null) ? 'POINT($lng $lat)' : locationGeo;

    final json = <String, dynamic>{
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'price_per_night': pricePerNight,
      'location': location,
      'city_id': cityId,
      'state_id': stateId,
      'country_id': countryId,
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
      'min_nights': minNights,
      'google_maps_link': googleMapsLink,
      'location_geo': locationGeoValue,
      'translations': translations,
    };

    json.removeWhere((key, value) => value == null);
    return json;
  }

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

  static Map<String, double?> _parsePoint(String? pointText) {
    if (pointText == null || pointText.trim().isEmpty) {
      return {'lat': null, 'lng': null};
    }

    final pointRegex = RegExp(r'POINT\s*\(([-0-9.]+)\s+([-0-9.]+)\)');
    final match = pointRegex.firstMatch(pointText.trim());
    if (match == null || match.groupCount < 2) {
      return {'lat': null, 'lng': null};
    }

    final lng = double.tryParse(match.group(1)!);
    final lat = double.tryParse(match.group(2)!);
    return {'lat': lat, 'lng': lng};
  }

  static String? _asPointText(dynamic value) {
    if (value is String) return value;

    if (value is Map && value['type'] == 'Point' && value['coordinates'] is List) {
      final coords = value['coordinates'] as List;
      if (coords.length >= 2) {
        final lng = (coords[0] as num?)?.toDouble();
        final lat = (coords[1] as num?)?.toDouble();
        if (lat != null && lng != null) {
          return 'POINT($lng $lat)';
        }
      }
    }

    return null;
  }

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    final arTranslation = json['translations']?['ar'];
    final locationGeoText = _asPointText(json['location_geo']);
    final parsedPoint = _parsePoint(locationGeoText);
    final parsedLat = parsedPoint['lat'];
    final parsedLng = parsedPoint['lng'];

    // Helper to extract name from potential nested join object or flat key
    String? extractName(dynamic value, String? flatKey) {
      if (value is List && value.isNotEmpty) {
        return extractName(value.first, null);
      }
      if (value is Map && value.containsKey('name')) {
        return value['name']?.toString();
      }
      final str = value?.toString() ?? flatKey?.toString();
      if (str != null && str.length > 30 && str.contains('-')) {
        return null; // UUID
      }
      return str;
    }

    return ListingModel(
      id: json['id'],
      userId: json['user_id'],
      title: arTranslation?['title'] ?? json['title'],
      description: arTranslation?['description'] ?? json['description'],
      pricePerNight: (json['price_per_night'] as num?)?.toDouble(),
      location: json['location'],
      cityId: json['city_id']?.toString(),
      stateId: json['state_id']?.toString(),
      countryId: json['country_id']?.toString(),
      
      // Resolved names - handle nested join objects like { "name": "..." } or flat keys
      cityName: extractName(json['city'] ?? json['cities'], json['city_name']),
      stateName: extractName(json['state'] ?? json['states'], json['state_name']),
      countryName: extractName(json['country'] ?? json['countries'], json['country_name']),

      maxGuests: json['max_guests'],
      bedrooms: json['bedrooms'],
      beds: json['beds'],
      bathrooms: json['bathrooms'],
      propertyTypeId: json['property_type_id'],
      isGuestFavorite: json['is_guest_favorite'] ?? false,
      isBestOffer: json['is_best_offer'] ?? json['best_offer'] ?? false,
      isPublished: json['is_published'] ?? false,
      cleaningFee: (json['cleaning_fee'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'EGP',
      cancellationPolicy: json['cancellation_policy'],
      listingCode: json['listing_code'],
      minNights: json['min_nights'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      googleMapsLink: json['google_maps_link'],
      locationGeo: locationGeoText,
      lat:
          parsedLat ??
          (json['lat'] as num?)?.toDouble() ??
          _parseLat(json['google_maps_link']),
      lng:
          parsedLng ??
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
    String? rawUrl =
        json['url']?.toString() ??
        json['image_url']?.toString() ??
        json['listing_image_url']?.toString() ??
        json['image']?.toString();

    // Fix if rawUrl is a JSON array string like '["listings/..."]'
    if (rawUrl != null && rawUrl.startsWith('[') && rawUrl.endsWith(']')) {
      try {
        final List<dynamic> parsed = jsonDecode(rawUrl);
        if (parsed.isNotEmpty) {
          rawUrl = parsed.first.toString();
        } else {
          rawUrl = null;
        }
      } catch (e) {
        rawUrl = rawUrl?.replaceAll(RegExp(r'[\[\]"]'), '');
      }
    }

    String? resolvedUrl;
    if (rawUrl != null && rawUrl.isNotEmpty) {
      if (rawUrl.startsWith('http')) {
        resolvedUrl = rawUrl;
      } else if (rawUrl.startsWith('/')) {
        const supabaseUrl = 'https://xpvrgdpsvffmttlwwfuo.supabase.co';
        resolvedUrl = '$supabaseUrl$rawUrl';
      } else {
        const supabaseUrl = 'https://xpvrgdpsvffmttlwwfuo.supabase.co';
        resolvedUrl = '$supabaseUrl/storage/v1/object/public/$rawUrl';
      }
    }

    return ListingImage(
      id: json['id']?.toString(),
      url: resolvedUrl,
      order: json['order'] ?? json['sort_order'],
      category: json['category']?.toString(),
    );
  }
}

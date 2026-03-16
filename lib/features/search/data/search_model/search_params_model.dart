class SearchParamsModel {
  final List<String>? attributeCodes;
  final bool? bestOffer;
  final String? categorySlug;
  final String? checkIn;
  final String? checkOut;
  final String? country;
  final double? geoLat;
  final double? geoLng;
  final double? geoRadiusKm;
  final int? guests;
  final bool? includeSurrounding;
  final int limit;
  final String? locale;
  final String? location;
  final int offset;
  final double? priceMax;
  final double? priceMin;
  final List<String>? propertyTypeSlugs;
  final List<String>? specificIds;

  const SearchParamsModel({
    this.attributeCodes,
    this.bestOffer,
    this.categorySlug,
    this.checkIn,
    this.checkOut,
    this.country,
    this.geoLat,
    this.geoLng,
    this.geoRadiusKm,
    this.guests,
    this.includeSurrounding,
    this.limit = 10,
    this.locale,
    this.location,
    this.offset = 0,
    this.priceMax,
    this.priceMin,
    this.propertyTypeSlugs,
    this.specificIds,
  });

  Map<String, dynamic> toJson() => {
    'p_attribute_codes': attributeCodes,
    'p_best_offer': bestOffer,
    'p_category_slug': categorySlug,
    'p_check_in': checkIn,
    'p_check_out': checkOut,
    'p_country': country,
    'p_geo_lat': geoLat,
    'p_geo_lng': geoLng,
    'p_geo_radius_km': geoRadiusKm,
    'p_guests': guests,
    'p_include_surrounding': includeSurrounding,
    'p_limit': limit,
    'p_locale': locale,
    'p_location': location,
    'p_offset': offset,
    'p_price_max': priceMax,
    'p_price_min': priceMin,
    'p_property_type_slugs': propertyTypeSlugs,
    'p_specific_ids': specificIds,
  };
}

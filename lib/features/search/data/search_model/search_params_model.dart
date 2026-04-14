class SearchParamsModel {
  final int limit;
  final int offset;
  final String? location;
  final String? checkIn;
  final String? checkOut;
  final int? guests;
  final double? priceMin;
  final double? priceMax;
  final bool? bestOffer;

  SearchParamsModel({
    this.limit = 20,
    this.offset = 0,
    this.location,
    this.checkIn,
    this.checkOut,
    this.guests,
    this.priceMin,
    this.priceMax,
    this.bestOffer,
  });

  SearchParamsModel copyWith({
    int? limit,
    int? offset,
    String? location,
    String? checkIn,
    String? checkOut,
    int? guests,
    double? priceMin,
    double? priceMax,
    bool? bestOffer,
  }) {
    return SearchParamsModel(
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      location: location ?? this.location,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      guests: guests ?? this.guests,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      bestOffer: bestOffer ?? this.bestOffer,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'limit': limit,
      'offset': offset,
      if (location != null) 'location': location,
      if (checkIn != null) 'check_in': checkIn,
      if (checkOut != null) 'check_out': checkOut,
      if (guests != null) 'guests': guests,
      if (priceMin != null) 'price_min': priceMin,
      if (priceMax != null) 'price_max': priceMax,
      if (bestOffer != null) 'best_offer': bestOffer,
    };
  }

  // ✅ بيبعت كل الـ parameters عشان يتجنب الـ Candidate Function Error في Supabase
  Map<String, dynamic> toRequestBody() {
    final Map<String, dynamic> body = {
      'p_limit': limit,
      'p_offset': offset,
      'p_sort_by': 'created_at',
      'p_locale': 'ar', // ✅ Fix: يحدد الـ function signature بشكل صريح
    };

    if (location != null) body['p_location'] = location;
    if (guests != null) body['p_guests'] = guests;
    if (priceMin != null) body['p_price_min'] = priceMin;
    if (priceMax != null) body['p_price_max'] = priceMax;
    if (checkIn != null) body['p_check_in'] = checkIn;
    if (checkOut != null) body['p_check_out'] = checkOut;
    if (bestOffer != null) body['p_best_offer'] = bestOffer;

    return body;
  }
}

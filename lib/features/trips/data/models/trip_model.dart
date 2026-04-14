class TripModel {
  final String? id;
  final String? userId;
  final String? listingId;
  final String? checkIn;
  final String? checkOut;
  final int? guests;
  final num? subtotal;
  final String? commissionRateId;
  final String? status;
  final String? escrowStatus;
  final String? createdAt;
  final TripListing? listing;

  TripModel({
    this.id,
    this.userId,
    this.listingId,
    this.checkIn,
    this.checkOut,
    this.guests,
    this.subtotal,
    this.commissionRateId,
    this.status,
    this.escrowStatus,
    this.createdAt,
    this.listing,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      listingId: json['listing_id']?.toString(),
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      guests: json['guests'],
      subtotal: json['subtotal'],
      commissionRateId: json['commission_rate_id']?.toString(),
      status: json['status'],
      escrowStatus: json['escrow_status'],
      createdAt: json['created_at'],
      listing: json['listing'] != null ? TripListing.fromJson(json['listing']) : null,
    );
  }
}

class TripListing {
  final int? id;
  final String? title;
  final String? location;
  final List<String>? images;

  TripListing({
    this.id,
    this.title,
    this.location,
    this.images,
  });

  factory TripListing.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['listing_images'] != null) {
      if (json['listing_images'] is List) {
        parsedImages = (json['listing_images'] as List)
            .map((e) => e['url'] as String)
            .toList();
      }
    }

    return TripListing(
      id: json['id'],
      title: json['title'],
      location: json['location'],
      images: parsedImages,
    );
  }
}

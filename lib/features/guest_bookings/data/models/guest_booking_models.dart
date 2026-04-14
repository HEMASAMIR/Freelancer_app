import 'package:freelancer/features/search/data/search_model/listing_model.dart';

class GuestBookingDetailedModel {
  final String? id;
  final String? listingId;
  final String? userId;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int? guests;
  final double? subtotal;
  final String? status;
  final DateTime? createdAt;
  final ListingModel? listing;

  GuestBookingDetailedModel({
    this.id,
    this.listingId,
    this.userId,
    this.checkIn,
    this.checkOut,
    this.guests,
    this.subtotal,
    this.status,
    this.createdAt,
    this.listing,
  });

  factory GuestBookingDetailedModel.fromJson(Map<String, dynamic> json) {
    return GuestBookingDetailedModel(
      id: json['id'],
      listingId: json['listing_id'],
      userId: json['user_id'],
      checkIn: json['check_in'] != null ? DateTime.parse(json['check_in']) : null,
      checkOut: json['check_out'] != null ? DateTime.parse(json['check_out']) : null,
      guests: json['guests'],
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      status: json['status'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      listing: json['listing'] != null ? ListingModel.fromJson(json['listing']) : null,
    );
  }
}

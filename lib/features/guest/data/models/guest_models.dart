import 'package:freelancer/features/search/data/search_model/listing_model.dart';

class GuestTripModel {
  final String? id;
  final String? userId;
  final String? listingId;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? totalPrice;
  final String? status;
  final DateTime? createdAt;
  final ListingModel? listing;

  GuestTripModel({
    this.id,
    this.userId,
    this.listingId,
    this.startDate,
    this.endDate,
    this.totalPrice,
    this.status,
    this.createdAt,
    this.listing,
  });

  factory GuestTripModel.fromJson(Map<String, dynamic> json) {
    return GuestTripModel(
      id: json['id'],
      userId: json['user_id'],
      listingId: json['listing_id'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      status: json['status'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      listing: json['listing'] != null ? ListingModel.fromJson(json['listing']) : null,
    );
  }
}

class GuestWishlistModel {
  final String? id;
  final String? userId;
  final String? name;
  final DateTime? createdAt;
  final List<ListingModel>? items;

  GuestWishlistModel({
    this.id,
    this.userId,
    this.name,
    this.createdAt,
    this.items,
  });

  factory GuestWishlistModel.fromJson(Map<String, dynamic> json) {
    return GuestWishlistModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      items: (json['wishlist_items'] as List?)
          ?.map((item) => ListingModel.fromJson(item['listing']))
          .toList(),
    );
  }
}

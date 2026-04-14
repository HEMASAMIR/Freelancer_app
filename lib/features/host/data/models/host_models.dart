import 'package:freelancer/features/search/data/search_model/listing_model.dart';

class HostBookingModel {
  final String? id;
  final String? listingId;
  final String? guestId;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? totalPrice;
  final String? status;
  final DateTime? createdAt;
  final ListingModel? listing;
  final GuestProfileModel? guest;

  HostBookingModel({
    this.id,
    this.listingId,
    this.guestId,
    this.startDate,
    this.endDate,
    this.totalPrice,
    this.status,
    this.createdAt,
    this.listing,
    this.guest,
  });

  factory HostBookingModel.fromJson(Map<String, dynamic> json) {
    return HostBookingModel(
      id: json['id'],
      listingId: json['listing_id'],
      guestId: json['guest_id'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      status: json['status'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      listing: json['listing'] != null ? ListingModel.fromJson(json['listing']) : null,
      guest: json['guest'] != null ? GuestProfileModel.fromJson(json['guest']) : null,
    );
  }
}

class GuestProfileModel {
  final String? id;
  final String? fullName;
  final String? email;

  GuestProfileModel({this.id, this.fullName, this.email});

  factory GuestProfileModel.fromJson(Map<String, dynamic> json) {
    return GuestProfileModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
    );
  }
}

class AvailabilityModel {
  final String? id;
  final String? listingId;
  final DateTime? date;
  final bool? isAvailable;
  final double? priceOverride;

  AvailabilityModel({
    this.id,
    this.listingId,
    this.date,
    this.isAvailable,
    this.priceOverride,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['id'],
      listingId: json['listing_id'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      isAvailable: json['is_available'],
      priceOverride: (json['price_override'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing_id': listingId,
      'date': date?.toIso8601String(),
      'is_available': isAvailable,
      'price_override': priceOverride,
    };
  }
}

class HostReviewModel {
  final String? id;
  final String? listingId;
  final String? userId;
  final double? rating;
  final String? comment;
  final DateTime? createdAt;
  final ListingModel? listing;
  final GuestProfileModel? user;

  HostReviewModel({
    this.id,
    this.listingId,
    this.userId,
    this.rating,
    this.comment,
    this.createdAt,
    this.listing,
    this.user,
  });

  factory HostReviewModel.fromJson(Map<String, dynamic> json) {
    return HostReviewModel(
      id: json['id'],
      listingId: json['listing_id'],
      userId: json['user_id'],
      rating: (json['rating'] as num?)?.toDouble(),
      comment: json['comment'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      listing: json['listing'] != null ? ListingModel.fromJson(json['listing']) : null,
      user: json['user'] != null ? GuestProfileModel.fromJson(json['user']) : null,
    );
  }
}

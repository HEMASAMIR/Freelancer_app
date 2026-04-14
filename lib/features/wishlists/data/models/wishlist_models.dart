import 'package:freelancer/features/search/data/search_model/listing_model.dart';

class WishlistModel {
  final String? id;
  final String? userId;
  final String? name;
  final DateTime? createdAt;
  final List<ListingModel>? listings;

  WishlistModel({
    this.id,
    this.userId,
    this.name,
    this.createdAt,
    this.listings,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      listings: (json['wishlist_items'] as List?)
          ?.map((item) => ListingModel.fromJson(item['listing']))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
    };
  }
}

class WishlistItemModel {
  final String? id;
  final String? wishlistId;
  final String? listingId;
  final DateTime? createdAt;

  WishlistItemModel({
    this.id,
    this.wishlistId,
    this.listingId,
    this.createdAt,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'],
      wishlistId: json['wishlist_id'],
      listingId: json['listing_id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wishlist_id': wishlistId,
      'listing_id': listingId,
    };
  }
}

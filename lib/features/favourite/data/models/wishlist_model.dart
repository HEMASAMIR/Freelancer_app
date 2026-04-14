class WishlistModel {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;

  WishlistModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
    };
  }
}

class WishlistItemModel {
  final String? id;
  final String wishlistId;
  final String listingId;

  WishlistItemModel({
    this.id,
    required this.wishlistId,
    required this.listingId,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'],
      wishlistId: json['wishlist_id'] ?? '',
      listingId: json['listing_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wishlist_id': wishlistId,
      'listing_id': listingId,
    };
  }
}

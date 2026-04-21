class ListingCommentModel {
  final String? id;
  final String? listingId;
  final String? userId;
  final String? content;
  final String? parentId; // null = top-level, non-null = reply
  final int likesCount;
  final bool likedByMe;
  final String? createdAt;
  final String? updatedAt;
  // joined from profiles
  final String? authorName;
  final String? authorAvatar;

  const ListingCommentModel({
    this.id,
    this.listingId,
    this.userId,
    this.content,
    this.parentId,
    this.likesCount = 0,
    this.likedByMe = false,
    this.createdAt,
    this.updatedAt,
    this.authorName,
    this.authorAvatar,
  });

  factory ListingCommentModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final profile = json['profile'] as Map<String, dynamic>?;
    final likes = json['listing_comment_likes'] as List?;
    final liked = currentUserId != null &&
        (likes?.any((l) => l['user_id'] == currentUserId) ?? false);

    return ListingCommentModel(
      id: json['id']?.toString(),
      listingId: json['listing_id']?.toString(),
      userId: json['user_id']?.toString(),
      content: json['content']?.toString(),
      parentId: json['parent_id']?.toString(),
      likesCount: json['likes_count'] ?? (likes?.length ?? 0),
      likedByMe: liked,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      authorName: profile?['full_name']?.toString() ??
          json['author_name']?.toString(),
      authorAvatar: profile?['avatar_url']?.toString(),
    );
  }

  ListingCommentModel copyWith({
    String? content,
    int? likesCount,
    bool? likedByMe,
  }) {
    return ListingCommentModel(
      id: id,
      listingId: listingId,
      userId: userId,
      content: content ?? this.content,
      parentId: parentId,
      likesCount: likesCount ?? this.likesCount,
      likedByMe: likedByMe ?? this.likedByMe,
      createdAt: createdAt,
      updatedAt: updatedAt,
      authorName: authorName,
      authorAvatar: authorAvatar,
    );
  }
}

import 'package:dartz/dartz.dart';
import '../models/listing_comment_model.dart';

abstract class CommentsRepository {
  Future<Either<String, List<ListingCommentModel>>> getComments({
    required String listingId,
    String? currentUserId,
  });

  Future<Either<String, ListingCommentModel>> addComment({
    required String listingId,
    required String userId,
    required String content,
    String? parentId,
  });

  Future<Either<String, Unit>> updateComment({
    required String commentId,
    required String userId,
    required String content,
  });

  Future<Either<String, Unit>> deleteComment({
    required String commentId,
    required String userId,
  });

  Future<Either<String, Unit>> toggleLike({
    required String commentId,
    required String userId,
    required bool isLiked,
  });
}

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:freelancer/core/constant/constant.dart';
import '../models/listing_comment_model.dart';
import 'comments_repo.dart';

class CommentsRepositoryImpl implements CommentsRepository {
  final Dio dio;
  CommentsRepositoryImpl({required this.dio});

  // ── SELECT all comments for a listing (with profile join) ──────────
  @override
  Future<Either<String, List<ListingCommentModel>>> getComments({
    required String listingId,
    String? currentUserId,
  }) async {
    try {
      final response = await dio.get(
        SupabaseKeys.listingCommentsRest,
        queryParameters: {
          'listing_id': 'eq.$listingId',
          'order': 'created_at.asc',
          'select':
              '*,profile:profiles(full_name,avatar_url),listing_comment_likes(user_id)',
        },
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return Right(
          data
              .map(
                (e) => ListingCommentModel.fromJson(
                  e,
                  currentUserId: currentUserId,
                ),
              )
              .toList(),
        );
      }
      return const Left('Failed to load comments');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  // ── INSERT new comment ─────────────────────────────────────────────
  @override
  Future<Either<String, ListingCommentModel>> addComment({
    required String listingId,
    required String userId,
    required String content,
    String? parentId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'listing_id': listingId,
        'user_id': userId,
        'content': content,
      };
      if (parentId != null) payload['parent_id'] = parentId;

      final response = await dio.post(
        SupabaseKeys.listingCommentsRest,
        data: payload,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final json = data is List ? data.first : data;
        return Right(ListingCommentModel.fromJson(json, currentUserId: userId));
      }
      return const Left('Failed to post comment');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  // ── PATCH (update) own comment ─────────────────────────────────────
  @override
  Future<Either<String, Unit>> updateComment({
    required String commentId,
    required String userId,
    required String content,
  }) async {
    try {
      final response = await dio.patch(
        SupabaseKeys.listingCommentsRest,
        queryParameters: {'id': 'eq.$commentId', 'user_id': 'eq.$userId'},
        data: {'content': content},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return Right(unit);
      }
      return const Left('Failed to update comment');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  // ── DELETE own comment ─────────────────────────────────────────────
  @override
  Future<Either<String, Unit>> deleteComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      final response = await dio.delete(
        SupabaseKeys.listingCommentsRest,
        queryParameters: {'id': 'eq.$commentId', 'user_id': 'eq.$userId'},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return Right(unit);
      }
      return const Left('Failed to delete comment');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  // ── Like / Unlike ──────────────────────────────────────────────────
  @override
  Future<Either<String, Unit>> toggleLike({
    required String commentId,
    required String userId,
    required bool isLiked,
  }) async {
    try {
      if (isLiked) {
        // Remove like
        await dio.delete(
          'listing_comment_likes',
          queryParameters: {
            'comment_id': 'eq.$commentId',
            'user_id': 'eq.$userId',
          },
        );
      } else {
        // Add like
        await dio.post(
          'listing_comment_likes',
          data: {'comment_id': commentId, 'user_id': userId},
        );
      }
      return Right(unit);
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }
}

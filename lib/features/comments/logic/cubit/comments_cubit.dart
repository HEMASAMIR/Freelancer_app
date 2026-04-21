import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/listing_comment_model.dart';
import '../../data/repos/comments_repo.dart';
import 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  final CommentsRepository repository;
  List<ListingCommentModel> _comments = [];

  CommentsCubit(this.repository) : super(CommentsInitial());

  // ── Load ──────────────────────────────────────────────────────────
  Future<void> loadComments({
    required String listingId,
    String? currentUserId,
  }) async {
    emit(CommentsLoading());
    final result = await repository.getComments(
      listingId: listingId,
      currentUserId: currentUserId,
    );
    result.fold(
      (error) => emit(CommentsError(error)),
      (list) {
        _comments = list;
        emit(CommentsLoaded(List.from(_comments)));
      },
    );
  }

  // ── Post ──────────────────────────────────────────────────────────
  Future<void> postComment({
    required String listingId,
    required String userId,
    required String content,
    String? parentId,
    String? authorName,
  }) async {
    final result = await repository.addComment(
      listingId: listingId,
      userId: userId,
      content: content,
      parentId: parentId,
    );
    result.fold(
      (error) => emit(CommentsError(error)),
      (comment) {
        // Inject author name optimistically
        final enriched = ListingCommentModel(
          id: comment.id,
          listingId: comment.listingId,
          userId: comment.userId,
          content: comment.content,
          parentId: comment.parentId,
          likesCount: 0,
          likedByMe: false,
          createdAt: comment.createdAt,
          updatedAt: comment.updatedAt,
          authorName: authorName ?? 'You',
        );
        _comments.add(enriched);
        emit(CommentPosted(enriched));
        emit(CommentsLoaded(List.from(_comments)));
      },
    );
  }

  // ── Edit ──────────────────────────────────────────────────────────
  Future<void> editComment({
    required String commentId,
    required String userId,
    required String newContent,
  }) async {
    final result = await repository.updateComment(
      commentId: commentId,
      userId: userId,
      content: newContent,
    );
    result.fold(
      (error) => emit(CommentsError(error)),
      (_) {
        _comments = _comments.map((c) {
          return c.id == commentId ? c.copyWith(content: newContent) : c;
        }).toList();
        emit(CommentUpdated());
        emit(CommentsLoaded(List.from(_comments)));
      },
    );
  }

  // ── Delete ────────────────────────────────────────────────────────
  Future<void> deleteComment({
    required String commentId,
    required String userId,
  }) async {
    final result = await repository.deleteComment(
      commentId: commentId,
      userId: userId,
    );
    result.fold(
      (error) => emit(CommentsError(error)),
      (_) {
        _comments.removeWhere((c) => c.id == commentId);
        emit(CommentDeleted());
        emit(CommentsLoaded(List.from(_comments)));
      },
    );
  }

  // ── Like / Unlike ─────────────────────────────────────────────────
  Future<void> toggleLike({
    required String commentId,
    required String userId,
  }) async {
    final idx = _comments.indexWhere((c) => c.id == commentId);
    if (idx == -1) return;

    final current = _comments[idx];
    final nowLiked = !current.likedByMe;
    // Optimistic update
    _comments[idx] = current.copyWith(
      likedByMe: nowLiked,
      likesCount: current.likesCount + (nowLiked ? 1 : -1),
    );
    emit(CommentsLoaded(List.from(_comments)));

    final result = await repository.toggleLike(
      commentId: commentId,
      userId: userId,
      isLiked: current.likedByMe,
    );
    result.fold(
      (error) {
        // Revert on failure
        _comments[idx] = current;
        emit(CommentsLoaded(List.from(_comments)));
        emit(CommentsError(error));
      },
      (_) {
        emit(CommentLikeToggled());
        emit(CommentsLoaded(List.from(_comments)));
      },
    );
  }
}

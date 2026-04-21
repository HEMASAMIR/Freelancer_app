import 'package:equatable/equatable.dart';
import '../../data/models/listing_comment_model.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();
  @override
  List<Object?> get props => [];
}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

class CommentsLoaded extends CommentsState {
  final List<ListingCommentModel> comments;
  const CommentsLoaded(this.comments);
  @override
  List<Object?> get props => [comments];
}

class CommentsError extends CommentsState {
  final String message;
  const CommentsError(this.message);
  @override
  List<Object?> get props => [message];
}

class CommentPosted extends CommentsState {
  final ListingCommentModel comment;
  const CommentPosted(this.comment);
  @override
  List<Object?> get props => [comment];
}

class CommentDeleted extends CommentsState {}
class CommentUpdated extends CommentsState {}
class CommentLikeToggled extends CommentsState {}

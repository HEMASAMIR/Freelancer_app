import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/widgets/login_required_sheet.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:freelancer/features/comments/data/models/listing_comment_model.dart';
import 'package:freelancer/features/comments/logic/cubit/comments_cubit.dart';
import 'package:freelancer/features/comments/logic/cubit/comments_state.dart';
import 'package:intl/intl.dart';

const _maroon = Color(0xFF710E1F);

class CommentsSection extends StatefulWidget {
  final String listingId;
  const CommentsSection({super.key, required this.listingId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final _controller = TextEditingController();
  String? _replyToId;
  String? _replyToName;
  String? _editingId;
  bool _posting = false;

  String? _currentUserId;
  String? _currentUserName;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadComments();
  }

  void _loadCurrentUser() {
    final state = context.read<AuthCubit>().state;
    _isAdmin = state is AuthAdminSuccess;

    if (state is AuthSuccess) {
      _currentUserId = state.user.id;
      _currentUserName =
          state.user.userMetadata['full_name'] ?? state.user.email;
    } else if (state is AuthAdminSuccess) {
      _currentUserId = state.user.id;
      _currentUserName =
          state.user.userMetadata['full_name'] ?? state.user.email;
    }
  }

  void _loadComments() {
    context.read<CommentsCubit>().loadComments(
      listingId: widget.listingId,
      currentUserId: _currentUserId,
    );
  }

  void _cancelReplyOrEdit() {
    setState(() {
      _replyToId = null;
      _replyToName = null;
      _editingId = null;
      _controller.clear();
    });
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_currentUserId == null) {
      showLoginRequiredSheet(
        context,
        title: 'Log in to comment',
        subtitle: 'You need to be logged in to leave a comment.',
        icon: Icons.chat_bubble_outline_rounded,
      );
      return;
    }

    setState(() => _posting = true);
    final cubit = context.read<CommentsCubit>();

    if (_editingId != null) {
      await cubit.editComment(
        commentId: _editingId!,
        userId: _currentUserId!,
        newContent: text,
      );
    } else {
      await cubit.postComment(
        listingId: widget.listingId,
        userId: _currentUserId!,
        content: text,
        parentId: _replyToId,
        authorName: _currentUserName,
      );
    }

    _cancelReplyOrEdit();
    setState(() => _posting = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Input Area ─────────────────────────────────────────────
        _buildInputSection(),
        SizedBox(height: 20.h),
        // ── Comments List ──────────────────────────────────────────
        BlocBuilder<CommentsCubit, CommentsState>(
          builder: (context, state) {
            if (state is CommentsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CommentsLoaded) {
              if (state.comments.isEmpty) {
                return _buildEmptyState();
              }
              // Separate top-level and replies
              final topLevel = state.comments
                  .where((c) => c.parentId == null)
                  .toList();
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topLevel.length,
                itemBuilder: (context, index) {
                  final comment = topLevel[index];
                  final replies = state.comments
                      .where((c) => c.parentId == comment.id)
                      .toList();
                  return _CommentTile(
                    comment: comment,
                    replies: replies,
                    currentUserId: _currentUserId,
                    isAdmin: _isAdmin,
                    onReply: (id, name) {
                      setState(() {
                        _replyToId = id;
                        _replyToName = name;
                        _editingId = null;
                        _controller.clear();
                      });
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    onEdit: (c) {
                      setState(() {
                        _editingId = c.id;
                        _controller.text = c.content ?? '';
                      });
                    },
                    onDelete: (id) async {
                      if (_currentUserId == null) return;
                      await context.read<CommentsCubit>().deleteComment(
                        commentId: id,
                        userId: _currentUserId!,
                      );
                    },
                    onLike: (id) async {
                      if (_currentUserId == null) {
                        showLoginRequiredSheet(context);
                        return;
                      }
                      await context.read<CommentsCubit>().toggleLike(
                        commentId: id,
                        userId: _currentUserId!,
                      );
                    },
                  );
                },
              );
            }
            if (state is CommentsError) {
              return Padding(
                padding: EdgeInsets.all(16.r),
                child: Text(
                  state.message,
                  style: TextStyle(color: Colors.red.shade400),
                ),
              );
            }
            return _buildEmptyState();
          },
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reply / Edit indicator
        if (_replyToName != null || _editingId != null)
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Row(
              children: [
                Icon(
                  _editingId != null
                      ? Icons.edit_outlined
                      : Icons.reply_rounded,
                  size: 14.sp,
                  color: _maroon,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    _editingId != null
                        ? 'Editing comment'
                        : 'Replying to $_replyToName',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _maroon,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _cancelReplyOrEdit,
                  child: Icon(Icons.close, size: 16.sp, color: Colors.grey),
                ),
              ],
            ),
          ),

        TextField(
          controller: _controller,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(
            hintText: 'Ask a question or leave a comment...',
            hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: _maroon),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          style: TextStyle(fontSize: 13.sp, color: AppColors.ink),
        ),
        SizedBox(height: 8.h),
        // Warning
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, size: 14.sp, color: _maroon),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                'Warning: You agree to receive an email if someone replies to this post. '
                'Comments will be deleted if they contain offensive content.',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            if (_replyToId != null || _editingId != null)
              TextButton(
                onPressed: _cancelReplyOrEdit,
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _posting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _maroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              ),
              icon: _posting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _editingId != null
                          ? Icons.save_outlined
                          : Icons.send_rounded,
                      size: 16.sp,
                    ),
              label: Text(
                _editingId != null ? 'Save Changes' : 'Post Comment',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Center(
        child: Text(
          'No comments yet. Be the first to ask a question.',
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade400,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  COMMENT TILE
// ═══════════════════════════════════════════════════════════════════
class _CommentTile extends StatelessWidget {
  final ListingCommentModel comment;
  final List<ListingCommentModel> replies;
  final String? currentUserId;
  final bool isAdmin;
  final void Function(String id, String name) onReply;
  final void Function(ListingCommentModel c) onEdit;
  final void Function(String id) onDelete;
  final void Function(String id) onLike;

  const _CommentTile({
    required this.comment,
    required this.replies,
    required this.currentUserId,
    required this.isAdmin,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
    required this.onLike,
  });

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} h ago';
      return DateFormat('MMM d').format(dt);
    } catch (_) {
      return '';
    }
  }

  bool get _isOwn => currentUserId != null && currentUserId == comment.userId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Author ──────────────────────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: _maroon.withValues(alpha: 0.1),
                backgroundImage: comment.authorAvatar != null
                    ? NetworkImage(comment.authorAvatar!)
                    : null,
                child: comment.authorAvatar == null
                    ? Text(
                        (comment.authorName ?? '?')[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: _maroon,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName ?? 'Anonymous',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      _formatTime(comment.createdAt),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // ── Content ─────────────────────────────────────────────
          Text(
            comment.content ?? '',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.ink,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10.h),

          // ── Actions ─────────────────────────────────────────────
          Row(
            children: [
              // Like
              GestureDetector(
                onTap: () => onLike(comment.id!),
                child: Row(
                  children: [
                    Icon(
                      comment.likedByMe
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      size: 16.sp,
                      color: comment.likedByMe ? _maroon : Colors.grey,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${comment.likesCount}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: comment.likedByMe ? _maroon : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              // Reply (Button active only for Admin, otherwise just shows count if there are replies)
              if (isAdmin || replies.isNotEmpty)
                GestureDetector(
                  onTap: isAdmin
                      ? () => onReply(comment.id!, comment.authorName ?? 'User')
                      : null,
                  child: Row(
                    children: [
                      Icon(Icons.reply_rounded, size: 16.sp, color: Colors.grey),
                      SizedBox(width: 4.w),
                      Text(
                        '${replies.length} Reply',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              if (_isOwn) ...[
                GestureDetector(
                  onTap: () => onEdit(comment),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () => onDelete(comment.id!),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // ── Replies ─────────────────────────────────────────────
          if (replies.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Container(
              margin: EdgeInsets.only(left: 16.w),
              padding: EdgeInsets.only(left: 12.w),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: _maroon.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: replies
                    .map(
                      (reply) => _ReplyTile(
                        reply: reply,
                        currentUserId: currentUserId,
                        onEdit: onEdit,
                        onDelete: onDelete,
                        onLike: onLike,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  REPLY TILE (nested)
// ═══════════════════════════════════════════════════════════════════
class _ReplyTile extends StatelessWidget {
  final ListingCommentModel reply;
  final String? currentUserId;
  final void Function(ListingCommentModel c) onEdit;
  final void Function(String id) onDelete;
  final void Function(String id) onLike;

  const _ReplyTile({
    required this.reply,
    required this.currentUserId,
    required this.onEdit,
    required this.onDelete,
    required this.onLike,
  });

  bool get _isOwn => currentUserId != null && currentUserId == reply.userId;

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} h ago';
      return DateFormat('MMM d').format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12.r,
                backgroundColor: _maroon.withValues(alpha: 0.08),
                child: Text(
                  (reply.authorName ?? '?')[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: _maroon,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  reply.authorName ?? 'Anonymous',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                _formatTime(reply.createdAt),
                style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade400),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            reply.content ?? '',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.greyText,
              height: 1.4,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              GestureDetector(
                onTap: () => onLike(reply.id!),
                child: Row(
                  children: [
                    Icon(
                      reply.likedByMe
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      size: 13.sp,
                      color: reply.likedByMe ? _maroon : Colors.grey,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '${reply.likesCount}',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_isOwn) ...[
                GestureDetector(
                  onTap: () => onEdit(reply),
                  child: Text(
                    'Edit',
                    style: TextStyle(fontSize: 11.sp, color: AppColors.ink),
                  ),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: () => onDelete(reply.id!),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

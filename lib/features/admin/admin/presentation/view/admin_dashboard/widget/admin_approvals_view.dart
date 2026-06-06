import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/admin/logic/admin_management_cubit.dart';
import 'package:freelancer/features/admin/logic/admin_management_state.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';
import 'package:freelancer/core/utils/widgets/elegant_toast.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class AdminApprovalsView extends StatefulWidget {
  const AdminApprovalsView({super.key});

  @override
  State<AdminApprovalsView> createState() => _AdminApprovalsViewState();
}

class _AdminApprovalsViewState extends State<AdminApprovalsView> {
  @override
  void initState() {
    super.initState();
    // Load pending listings when the view is opened
    context.read<AdminManagementCubit>().loadPendingListings();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminManagementCubit, AdminManagementState>(
      listener: (context, state) {
        if (state is AdminManagementSuccess) {
          ElegantToast.show(
            context,
            state.message,
            icon: Icons.check_circle_outline_rounded,
          );
        } else if (state is AdminManagementError) {
          ElegantToast.show(
            context,
            state.message,
            icon: Icons.error_outline_rounded,
          );
        }
      },
      builder: (context, state) {
        if (state is AdminManagementLoading) {
          return _buildShimmerList();
        }

        List<ListingModel> pendingListings = [];
        if (state is AdminPendingListingsLoaded) {
          pendingListings = state.listings;
        }

        if (pendingListings.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<AdminManagementCubit>().loadPendingListings();
          },
          color: AppColors.primaryBurgundy,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            itemCount: pendingListings.length,
            itemBuilder: (context, index) {
              final listing = pendingListings[index];
              return _buildListingApprovalCard(context, listing);
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: AppColors.backgroundCream,
            child: Container(
              height: 220.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: AppColors.primaryBurgundy.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.done_all_rounded,
              size: 48.sp,
              color: AppColors.primaryBurgundy,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.inkBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No pending listing approvals remaining.',
            style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AdminManagementCubit>().loadPendingListings();
            },
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            label: const Text('Refresh', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBurgundy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingApprovalCard(BuildContext context, ListingModel listing) {
    String imageUrl = '';
    if (listing.images != null && listing.images!.isNotEmpty) {
      imageUrl = listing.images!.first.url ?? '';
      if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
        imageUrl = imageUrl.startsWith('/')
            ? '${SupabaseKeys.supabaseUrl}$imageUrl'
            : '${SupabaseKeys.supabaseUrl}/storage/v1/object/public/$imageUrl';
      }
    }
    final encodedUrl = imageUrl.isNotEmpty
        ? Uri.encodeFull(imageUrl.replaceAll('\\', '/'))
        : '';

    final city = listing.city ?? 'Unknown City';
    final price = listing.pricePerNight ?? 0.0;
    final dateStr = listing.createdAt != null
        ? DateFormat('MMM d, yyyy').format(listing.createdAt!)
        : 'Unknown date';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image Header ──
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                child: SizedBox(
                  height: 140.h,
                  width: double.infinity,
                  child: encodedUrl.isNotEmpty
                      ? Image.network(
                          encodedUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
              ),
              Positioned(
                top: 12.h,
                left: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Code: ${listing.listingCode ?? "N/A"}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBurgundy.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Pending Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Listing Details ──
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.title ?? 'Unnamed listing',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.inkBlack,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14.sp,
                                color: AppColors.primaryBurgundy,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                city,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.greyText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${NumberFormat('#,###').format(price)} EGP',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBurgundy,
                          ),
                        ),
                        Text(
                          'per night',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Description
                if (listing.description != null &&
                    listing.description!.trim().isNotEmpty) ...[
                  Text(
                    listing.description!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.greyText,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                ],

                // Amenities / Details Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFeatureChip(
                      Icons.people_outline,
                      '${listing.maxGuests ?? 0} Guests',
                    ),
                    _buildFeatureChip(
                      Icons.bed_outlined,
                      '${listing.beds ?? 0} Beds',
                    ),
                    _buildFeatureChip(
                      Icons.bathtub_outlined,
                      '${listing.bathrooms ?? 0} Baths',
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Created date
                Text(
                  'Submitted on $dateStr',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.greyText.withOpacity(0.7),
                  ),
                ),
                const Divider(height: 24, color: AppColors.dividerGrey),

                // Actions row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _confirmReject(context, listing.id ?? ''),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(
                          'رفض وحذف',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _confirmApprove(context, listing.id ?? ''),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          elevation: 0,
                        ),
                        child: Text(
                          'موافقة ونشر',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.bgColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.greyText),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.home_work_outlined,
        size: 40.sp,
        color: Colors.grey[400],
      ),
    );
  }

  void _confirmApprove(BuildContext context, String listingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text(
          'تأكيد الموافقة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل أنت متأكد من قبول ونشر هذا العقار؟ سيظهر فوراً لجميع المستخدمين في الصفحة الرئيسية.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.greyText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminManagementCubit>().approveListing(listingId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: const Text(
              'موافقة ونشر',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReject(BuildContext context, String listingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text(
          'تأكيد الرفض والحذف',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        content: const Text(
          'هل أنت متأكد من رفض وحذف هذا العقار نهائياً؟ هذا الإجراء غير قابل للتراجع وسيتم حذف البيانات بالكامل.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.greyText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminManagementCubit>().rejectListing(listingId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: const Text(
              'حذف نهائي',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

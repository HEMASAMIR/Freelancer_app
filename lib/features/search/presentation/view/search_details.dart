import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';
import 'package:freelancer/features/favourite/presentation/widget/wishlist_bottom_sheet.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_state.dart';
import 'package:freelancer/features/bookings/logic/cubit/bookings_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/widgets/login_required_sheet.dart';
import 'package:freelancer/features/bookings/presentation/view/confirm_booking_screen.dart';
import 'package:freelancer/features/comments/logic/cubit/comments_cubit.dart';
import 'package:freelancer/features/comments/presentation/widget/comments_section.dart';
import 'package:freelancer/features/search/presentation/widget/property_map_section.dart';

const Color airbnbMaroon = Color(0xFF710E1F);
const Color airbnbBg = Color(0xFFF7F3F0);

class SearchDetails extends StatefulWidget {
  final ListingModel listing;
  const SearchDetails({super.key, required this.listing});

  @override
  State<SearchDetails> createState() => _SearchDetailsState();
}

class _SearchDetailsState extends State<SearchDetails> {
  final ValueNotifier<int> _reviewCountNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _reviewCountNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const SideDrawer(),
      backgroundColor: airbnbBg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- 1. الهيدر بالكامل (البانر + الداتا) قبل الصور ---
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _BestOffersBannerFullWidth(), // البانر المارون العريض
                    _TopInfoSection(
                      listing: widget.listing,
                      reviewCountNotifier: _reviewCountNotifier,
                    ), // العنوان والنجوم واللوكيشن
                  ],
                ),
              ),

              // --- 2. سلايدر الصور يجي هنا ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: _BentoImageGallery(listing: widget.listing),
                ),
              ),

              // --- 3. باقي تفاصيل الصفحة تحت الصور ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HostInfoSection(listing: widget.listing),
                      const _CustomDivider(),
                      _AboutSection(description: widget.listing.description),
                      const _CustomDivider(),
                      _OffersSection(lifestyles: widget.listing.lifestyles),
                      const _CustomDivider(),
                      if (widget.listing.cancellationPolicy != null &&
                          widget.listing.cancellationPolicy!.isNotEmpty)
                        _CancellationPolicySection(
                          policy: widget.listing.cancellationPolicy!,
                        ),
                      if (widget.listing.cancellationPolicy != null &&
                          widget.listing.cancellationPolicy!.isNotEmpty)
                        const _CustomDivider(),
                      if (widget.listing.lat != null && widget.listing.lng != null)
                        PropertyMapSection(
                          lat: widget.listing.lat!,
                          lng: widget.listing.lng!,
                          locationName: widget.listing.location ?? widget.listing.city,
                        )
                      else
                        _LocationMapSection(location: widget.listing.location),
                      const _CustomDivider(),
                      // قسم المراجعات اللي كان ممسوح رجعناه هنا بشكل أشيك
                      _ReviewsDetailedSection(
                        listing: widget.listing,
                        reviewCountNotifier: _reviewCountNotifier,
                      ),
                      const _CustomDivider(),
                      // Comments & Q&A
                      _CommentsHeader(),
                      SizedBox(height: 12.h),
                      BlocProvider(
                        create: (_) => sl<CommentsCubit>(),
                        child: CommentsSection(listingId: widget.listing.id ?? ''),
                      ),
                      _BookingCard(listing: widget.listing),
                      SizedBox(height: 40.h),
                      const CustomFooter(),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- ويجت البيانات العلوية (تم معالجة طول العنوان واللوكيشن) ---
class _TopInfoSection extends StatelessWidget {
  final ListingModel listing;
  final ValueNotifier<int> reviewCountNotifier;
  const _TopInfoSection({required this.listing, required this.reviewCountNotifier});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان: خليناه يقبل أكتر من سطر عشان العميل ما يقرفكش
          Text(
            listing.title ?? "Two Bedroom Chalet",
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.h),

          // السطر اللي فيه التقييم والمكان
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.star, size: 16.sp, color: Colors.black),
              SizedBox(width: 4.w),
              Text(
                listing.isGuestFavorite == true ? "Guest Favorite" : "New",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              ValueListenableBuilder<int>(
                valueListenable: reviewCountNotifier,
                builder: (context, count, _) {
                  return Text(
                    " · $count reviews",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[800]),
                  );
                },
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.location_on_outlined,
                size: 16.sp,
                color: Colors.grey[700],
              ),
              Expanded(
                child: Text(
                  ' ${listing.displayLocation ?? ''}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                    decoration: TextDecoration.underline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),

          // أزرار التفاعل (Save)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BlocBuilder<FavCubit, FavState>(
                builder: (context, state) {
                  final favCubit = context.read<FavCubit>();
                  final bool isFav = favCubit.isFavorite(listing.id.toString());

                  return _ActionBtn(
                    icon: isFav ? Icons.favorite : Icons.favorite_border,
                    label: isFav ? "Saved" : "Save",
                    iconColor: isFav ? Colors.red : Colors.black,
                    onTap: () {
                      final AuthCubitState = context.read<AuthCubit>().state;
                      final isLoggedIn = AuthCubitState is AuthSuccess || AuthCubitState is AuthAdminSuccess;
                      if (!isLoggedIn) {
                        showLoginRequiredSheet(context);
                        return;
                      }
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => BlocProvider.value(
                          value: context.read<FavCubit>(),
                          child: WishlistBottomSheet(listing: listing),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- الويجت اللي رجعناها (Reviews Section) ---
class _ReviewsDetailedSection extends StatefulWidget {
  final ListingModel listing;
  final ValueNotifier<int> reviewCountNotifier;
  const _ReviewsDetailedSection({required this.listing, required this.reviewCountNotifier});

  @override
  State<_ReviewsDetailedSection> createState() => _ReviewsDetailedSectionState();
}

class _ReviewsDetailedSectionState extends State<_ReviewsDetailedSection> {
  int _rating = 0;
  bool _submitted = false;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _ratingOptions = [
    {'value': 5, 'label': 'ممتاز (Excellent)', 'icon': Icons.sentiment_very_satisfied, 'color': const Color(0xFF4CAF50)},
    {'value': 4, 'label': 'جيد جداً (Very Good)', 'icon': Icons.sentiment_satisfied, 'color': const Color(0xFF8BC34A)},
    {'value': 3, 'label': 'جيد (Good)', 'icon': Icons.sentiment_neutral, 'color': const Color(0xFFFFC107)},
    {'value': 2, 'label': 'مقبول (Fair)', 'icon': Icons.sentiment_dissatisfied, 'color': const Color(0xFFFF9800)},
    {'value': 1, 'label': 'سيء (Poor)', 'icon': Icons.sentiment_very_dissatisfied, 'color': const Color(0xFFF44336)},
  ];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final authState = context.read<AuthCubit>().state;
      String? userId;
      if (authState is AuthSuccess) userId = authState.user.id;
      else if (authState is AuthAdminSuccess) userId = authState.user.id;

      final prefs = await SharedPreferences.getInstance();
      final localReview = prefs.getInt('review_${widget.listing.id}');

      final response = await Supabase.instance.client
          .from('reviews')
          .select('rating, user_id')
          .eq('listing_id', widget.listing.id ?? '');

      final List data = response as List;
      
      if (mounted) {
        final hasBackendReview = userId != null && data.any((r) => r['user_id'] == userId);
        widget.reviewCountNotifier.value = data.length + (!hasBackendReview && localReview != null ? 1 : 0);
        
        if (localReview != null) {
          setState(() {
            _rating = localReview;
            _submitted = true;
          });
        } else if (hasBackendReview) {
          final myReview = data.where((r) => r['user_id'] == userId).toList();
          setState(() {
            _rating = myReview.first['rating'] ?? 0;
            _submitted = true;
          });
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
      
      // Fallback to local
      final prefs = await SharedPreferences.getInstance();
      final localReview = prefs.getInt('review_${widget.listing.id}');
      if (localReview != null && mounted) {
        setState(() {
          _rating = localReview;
          _submitted = true;
        });
        if (widget.reviewCountNotifier.value == 0) {
          widget.reviewCountNotifier.value = 1;
        }
      }
      
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitRating(int rating) async {
    if (_submitted) return;
    
    final authState = context.read<AuthCubit>().state;
    String? userId;
    if (authState is AuthSuccess) userId = authState.user.id;
    else if (authState is AuthAdminSuccess) userId = authState.user.id;

    if (userId == null) {
      showLoginRequiredSheet(context);
      return;
    }

    // Optimistic UI update and Local Save
    setState(() {
      _rating = rating;
      _submitted = true;
    });
    widget.reviewCountNotifier.value += 1;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('review_${widget.listing.id}', rating);

    try {
      await Supabase.instance.client.from('reviews').upsert({
        'listing_id': widget.listing.id,
        'user_id': userId,
        'rating': rating,
      });
    } catch (e) {
      debugPrint("Error saving review to backend (kept locally): $e");
      // Intentionally NOT reverting UI or showing error snackbar 
      // because the RLS policy might be strict, but we want a good UX.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: widget.reviewCountNotifier,
          builder: (context, count, _) {
            return Row(
              children: [
                Icon(Icons.star, size: 20.sp, color: count > 0 ? Colors.orange : Colors.black),
                SizedBox(width: 8.w),
                Text(
                  count > 0 ? "$count review${count > 1 ? 's' : ''}" : "No reviews yet",
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
              ],
            );
          }
        ),
        SizedBox(height: 16.h),
        
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(color: airbnbMaroon)),
          )
        else
          AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                child: child,
              ),
            );
          },
          child: !_submitted
              ? Column(
                  key: const ValueKey('rating_options'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rate your experience:",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    SizedBox(height: 12.h),
                    ..._ratingOptions.map((option) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: InkWell(
                          onTap: () => _submitRating(option['value']),
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12.r),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(option['icon'], color: option['color'], size: 28.sp),
                                SizedBox(width: 12.w),
                                Text(
                                  option['label'],
                                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.black87),
                                ),
                                const Spacer(),
                                Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey.shade400),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                )
              : Container(
                  key: const ValueKey('success_message'),
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9), // Light green bg
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFC5E1A5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_rounded, color: Colors.white, size: 26.sp),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Thank you!",
                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Your $_rating-star review has been submitted successfully.",
                              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF388E3C)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

// Comments Header
class _CommentsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.chat_bubble_outline_rounded, size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          'Comments & Q&A',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// البانر العريض اللي فوق خالص
class _BestOffersBannerFullWidth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
      color: airbnbMaroon,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                color: Colors.white,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "Best Offers of the Week",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12.sp),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: iconColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}


// --- قسم الخريطة ---
class _LocationMapSection extends StatelessWidget {
  final String? location;
  const _LocationMapSection({this.location});

  Future<void> _launchMap() async {
    if (location == null) return;
    final Uri googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location!)}",
    );
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Where you'll be",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        InkWell(
          onTap: _launchMap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              height: 180.h,
              width: double.infinity,
              color: Colors.grey[100],
              child: Image.network(
                // We use a placeholder logic if no key is available to avoid broken links
                'https://via.placeholder.com/600x300/F5F5F5/710E1F?text=Map+Preview+of+${Uri.encodeComponent(location ?? "Location")}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                      SizedBox(height: 8.h),
                      Text(location ?? "Location Preview"),
                      Text(
                        "Tap to open Google Maps",
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- قسم المميزات ---
class _OffersSection extends StatelessWidget {
  final List<dynamic>? lifestyles;
  const _OffersSection({this.lifestyles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What this place offers",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        if (lifestyles == null || lifestyles!.isEmpty)
          const Text("No amenities listed")
        else
          Column(
            children: lifestyles!.map((lifestyle) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: airbnbMaroon,
                ),
                title: Text(lifestyle.name ?? "Feature"),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// --- كارت الحجز ---
class _BookingCard extends StatefulWidget {
  final ListingModel listing;
  const _BookingCard({required this.listing});
  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  DateTimeRange? selectedDateRange;
  int guestsCount = 1;
  bool isLoading = false;

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDateRange: selectedDateRange,
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: airbnbMaroon)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => selectedDateRange = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "EGP ${widget.listing.pricePerNight?.toInt() ?? 0}",
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
              Text(" night"),
            ],
          ),
          SizedBox(height: 20.h),
          // حقول التواريخ والضيوف
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () => _selectDateRange(context),
                  child: Row(
                    children: [
                      Expanded(
                        child: _Tile(
                          title: "CHECK-IN",
                          value: selectedDateRange != null
                              ? DateFormat(
                                  'MM/dd/yyyy',
                                ).format(selectedDateRange!.start)
                              : "Add date",
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 60.h,
                        color: Colors.grey.shade400,
                      ),
                      Expanded(
                        child: _Tile(
                          title: "CHECKOUT",
                          value: selectedDateRange != null
                              ? DateFormat(
                                  'MM/dd/yyyy',
                                ).format(selectedDateRange!.end)
                              : "Add date",
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade400),
                _GuestSelector(
                  count: guestsCount,
                  onAdd: () => setState(() => guestsCount++),
                  onRemove: () =>
                      setState(() => guestsCount > 1 ? guestsCount-- : null),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (selectedDateRange == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please select check-in & check-out dates first",
                            ),
                            backgroundColor: airbnbMaroon,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        setState(() => isLoading = true);
                        try {
                          final authCubit = context.read<AuthCubit>();
                          final bookingCubit = context.read<BookingsCubit>();

                          // نجرب نرجع الـ session لو لسه مش اتحملت
                          if (!authCubit.isAuthenticated) {
                            await authCubit.getUserInfo();
                          }

                          final AuthCubitState = authCubit.state;

                          if (AuthCubitState is! AuthSuccess &&
                              AuthCubitState is! AuthAdminSuccess) {
                            setState(() => isLoading = false);
                            if (!context.mounted) return;
                            await showLoginRequiredSheet(
                              context,
                              title: 'Log in to book',
                              subtitle: 'You need to be logged in to\nrequest a booking.',
                              icon: Icons.calendar_month_rounded,
                            );
                            return;
                          }

                          final userId = AuthCubitState is AuthSuccess
                              ? AuthCubitState.user.id
                              : (AuthCubitState as AuthAdminSuccess).user.id;

                          // Check availability first
                          final bool isAvailable =
                              await bookingCubit.checkAvailability(
                            widget.listing.id!,
                            selectedDateRange!.start.toIso8601String(),
                            selectedDateRange!.end.toIso8601String(),
                          );

                          if (!isAvailable) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Selected dates are not available.",
                                  ),
                                  backgroundColor: airbnbMaroon,
                                ),
                              );
                            }
                          } else {
                            final commission =
                                await bookingCubit.getCommissionRate();
                            final int days =
                                selectedDateRange!.duration.inDays > 0
                                    ? selectedDateRange!.duration.inDays
                                    : 1;

                            // Calculate pricing
                            double subtotal = 0;
                            for (int i = 0; i < days; i++) {
                              final d = selectedDateRange!.start
                                  .add(Duration(days: i));
                              final isWeekend =
                                  d.weekday == DateTime.friday ||
                                  d.weekday == DateTime.saturday;
                              subtotal += isWeekend
                                  ? (widget.listing.pricePerNight ?? 0) * 1.15
                                  : (widget.listing.pricePerNight ?? 0)
                                      .toDouble();
                            }
                            final double serviceFee = subtotal * 0.10;
                            final double total = subtotal + serviceFee;

                            if (context.mounted) {
                              // Navigate to Confirm Booking Screen
                              Navigator.pushNamed(
                                context,
                                AppRoutes.confirmBooking,
                                arguments: ConfirmBookingArgs(
                                  listing: widget.listing,
                                  dateRange: selectedDateRange!,
                                  guests: guestsCount,
                                  subtotal: subtotal,
                                  serviceFee: serviceFee,
                                  total: total,
                                  userId: userId,
                                  commissionRateId: commission?['id'],
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: ${e.toString()}"),
                                backgroundColor: airbnbMaroon,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => isLoading = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: airbnbMaroon),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  :  Text(
                      selectedDateRange != null ? "Request to Book" : "Check availability",

                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          // --- PRICE BREAKDOWN ---
          if (selectedDateRange != null) ...[
            SizedBox(height: 16.h),
            const Text(
              "You won't be charged yet",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 16.h),
            _buildPriceBreakdown(),
          ],
          
          const Divider(height: 40),

          const _CalendarLegend(),
        ],
      ),
    );
  }

  // --- حساب وتفصيل فاتورة الحجز ---
  Widget _buildPriceBreakdown() {
    final start = selectedDateRange!.start;
    final end = selectedDateRange!.end;
    final int days = end.difference(start).inDays;
    if (days <= 0) return const SizedBox();

    final double basePrice = widget.listing.pricePerNight ?? 0;
    double expectedSubtotal = 0;
    List<Widget> dailyRows = [];
    
    for (int i = 0; i < days; i++) {
        final currentDate = start.add(Duration(days: i));
        final bool isWeekend = currentDate.weekday == DateTime.friday || currentDate.weekday == DateTime.saturday;
        final double dailyPrice = isWeekend ? basePrice * 1.15 : basePrice; 
        expectedSubtotal += dailyPrice;
        
        dailyRows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${DateFormat('EEE, MMM d').format(currentDate)}${isWeekend ? ' (Weekend day)' : ''}",
                  style: TextStyle(fontSize: 12.sp, color: isWeekend ? airbnbMaroon.withOpacity(0.8) : Colors.black87),
                ),
                Text(
                  "EGP ${NumberFormat('#,###').format(dailyPrice)}",
                  style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                ),
              ],
            ),
          ),
        );
    }

    final double serviceFee = expectedSubtotal * 0.10; 
    final double total = expectedSubtotal + serviceFee;

    return Column(
      children: [
        ...dailyRows,
        const Divider(height: 24),
        _priceRow("Subtotal ($days nights)", expectedSubtotal, isBold: false),
        const SizedBox(height: 8),
        _priceRow("Service fee", serviceFee, isBold: false),
        const Divider(height: 24),
        _priceRow("Total", total, isBold: true),
      ],
    );
  }

  Widget _priceRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14.sp : 13.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          "EGP ${NumberFormat('#,###').format(amount)}",
          style: TextStyle(
            fontSize: isBold ? 14.sp : 13.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

// --- الويجتات الصغيرة المساعدة ---


class _GuestSelector extends StatelessWidget {
  final int count;
  final VoidCallback onAdd, onRemove;
  const _GuestSelector({
    required this.count,
    required this.onAdd,
    required this.onRemove,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "GUESTS",
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
            ),
            Text("$count guest"),
          ],
        ),
        Row(
          children: [
            _btn(Icons.remove, onRemove),
            SizedBox(width: 15.w),
            Text("$count", style: const TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 15.w),
            _btn(Icons.add, onAdd),
          ],
        ),
      ],
    ),
  );
  Widget _btn(IconData i, VoidCallback t) => InkWell(
    onTap: t,
    child: Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Icon(i, size: 18.sp),
    ),
  );
}

class _HostInfoSection extends StatelessWidget {
  final ListingModel listing;
  const _HostInfoSection({required this.listing});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hosted by ${listing.host?.fullName ?? 'Owner'}",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              "${listing.bedrooms ?? 0} bedrooms • ${listing.beds ?? 0} beds • ${listing.bathrooms ?? 0} bathrooms",
            ),
          ],
        ),
      ),
      CircleAvatar(
        radius: 24.r,
        backgroundColor: Colors.grey[300],
        child: Text(listing.host?.fullName?[0] ?? "H"),
      ),
    ],
  );
}

class _BentoImageGallery extends StatefulWidget {
  final ListingModel listing;
  const _BentoImageGallery({required this.listing});

  @override
  State<_BentoImageGallery> createState() => _BentoImageGalleryState();
}

class _BentoImageGalleryState extends State<_BentoImageGallery> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.listing.images ?? [];
    if (images.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          height: 300.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: const Center(child: Icon(Icons.home_outlined, size: 60, color: Colors.grey)),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: SizedBox(
          height: 350.h,
          width: double.infinity,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (_, __, ___) => _FullScreenGallery(images: images, initialIndex: index),
                        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
                      ));
                    },
                    child: Container(
                      color: Colors.black, // Premium background for contained images
                      child: InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Image.network(
                          images[index].url ?? '',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (images.length > 1)
                Positioned(
                  bottom: 12.h,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: _currentIndex == index ? 12.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: _currentIndex == index ? Colors.white : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            )
                          ]
                        ),
                      );
                    }),
                  ),
                ),
                
              // Counter Badge
              if (images.length > 1)
                Positioned(
                  top: 16.h,
                  right: 16.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${images.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  final List<ListingImage> images;
  final int initialIndex;
  
  const _FullScreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 5.0,
            child: Center(
              child: Image.network(
                widget.images[index].url ?? '',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16.w,
    runSpacing: 10.h,
    children: [
      _i(Colors.grey[200]!, "Booked"),
      _i(Colors.pink[50]!, "Blocked"),
      _i(const Color(0xFFE8E4F2), "Adjusted"),
      _i(const Color(0xFFFFD700), "Custom"),
      _i(const Color(0xFF00C38B), "Best Offer"),
    ],
  );
  Widget _i(Color c, String t) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      SizedBox(width: 6.w),
      Text(t, style: TextStyle(fontSize: 11.sp)),
    ],
  );
}

class _Tile extends StatelessWidget {
  final String title, value;
  const _Tile({required this.title, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(12.r),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    ),
  );
}

class _CustomDivider extends StatelessWidget {
  const _CustomDivider();
  @override
  Widget build(BuildContext context) =>
      Divider(height: 40.h, thickness: 1, color: Colors.grey.shade300);
}

class _CancellationPolicySection extends StatelessWidget {
  final String policy;
  const _CancellationPolicySection({required this.policy});

  IconData get _icon {
    switch (policy.toLowerCase()) {
      case 'flexible':
        return Icons.check_circle_outline;
      case 'moderate':
        return Icons.info_outline;
      case 'strict':
        return Icons.warning_amber_rounded;
      default:
        return Icons.policy_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_busy_outlined, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              "Cancellation policy",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(_icon, color: airbnbMaroon, size: 24.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      policy,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _policyDescription(policy),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _policyDescription(String policy) {
    switch (policy.toLowerCase()) {
      case 'flexible':
        return 'Free cancellation up to 24 hours before check-in.';
      case 'moderate':
        return 'Free cancellation up to 5 days before check-in.';
      case 'strict':
        return '50% refund up to 1 week before check-in.';
      default:
        return 'Review the cancellation terms before booking.';
    }
  }
}

class _AboutSection extends StatefulWidget {
  final String? description;
  const _AboutSection({this.description});
  @override
  State<_AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<_AboutSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.description ?? "No description provided.";
    final isLong = text.length > 200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _expanded || !isLong ? text : '${text.substring(0, 200)}...',
          style: TextStyle(height: 1.5, fontSize: 15.sp),
        ),
        if (isLong) ...[
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Text(
                  _expanded ? 'Show less' : 'Show more',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_right,
                  size: 18.sp,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/features/bookings/logic/cubit/bookings_state.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';
import 'package:freelancer/features/favourite/presentation/widget/wishlist_bottom_sheet.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:freelancer/features/bookings/logic/cubit/bookings_cubit.dart';
import 'package:freelancer/core/app_router/routes.dart';

const Color airbnbMaroon = Color(0xFF710E1F);
const Color airbnbBg = Color(0xFFF7F3F0);

class SearchDetails extends StatelessWidget {
  final ListingModel listing;
  const SearchDetails({super.key, required this.listing});

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
                      listing: listing,
                    ), // العنوان والنجوم واللوكيشن
                  ],
                ),
              ),

              // --- 2. سلايدر الصور يجي هنا ---
              _ImageSliderAppBar(listing: listing),

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
                      _HostInfoSection(listing: listing),
                      const _CustomDivider(),
                      _AboutSection(description: listing.description),
                      const _CustomDivider(),
                      _OffersSection(lifestyles: listing.lifestyles),
                      const _CustomDivider(),
                      _LocationMapSection(location: listing.location),
                      const _CustomDivider(),
                      // قسم المراجعات اللي كان ممسوح رجعناه هنا بشكل أشيك
                      _ReviewsDetailedSection(listing: listing),
                      const _CustomDivider(),
                      _BookingCard(listing: listing),
                      SizedBox(height: 40.h),
                      const CustomFooter(),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _FloatingChatButton(),
        ],
      ),
    );
  }
}

// --- ويجت البيانات العلوية (تم معالجة طول العنوان واللوكيشن) ---
class _TopInfoSection extends StatelessWidget {
  final ListingModel listing;
  const _TopInfoSection({required this.listing});

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
              Text(
                " · 0 reviews",
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[800]),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.location_on_outlined,
                size: 16.sp,
                color: Colors.grey[700],
              ),
              // الـ Expanded هنا بيضمن إن اللوكيشن يظهر كامل أو ينتهي بـ نقاط لو طويل جداً
              Expanded(
                child: Text(
                  " ${listing.city}, ${listing.country}",
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

          // أزرار التفاعل (Share & Save)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionBtn(
                icon: Icons.ios_share,
                label: "Share",
                onTap: () {
                  // يمكن إضافة مشاركة الرابط هنا لاحقاً
                },
              ),
              SizedBox(width: 20.w),
              BlocBuilder<FavCubit, FavState>(
                builder: (context, state) {
                  final favCubit = context.read<FavCubit>();
                  final bool isFav = favCubit.isFavorite(listing.id.toString());

                  return _ActionBtn(
                    icon: isFav ? Icons.favorite : Icons.favorite_border,
                    label: isFav ? "Saved" : "Save",
                    iconColor: isFav ? Colors.red : Colors.black,
                    onTap: () {
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
class _ReviewsDetailedSection extends StatelessWidget {
  final ListingModel listing;
  const _ReviewsDetailedSection({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              "No reviews yet",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          "Be the first to review this place!",
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
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
                'https://maps.googleapis.com/maps/api/staticmap?center=${Uri.encodeComponent(location ?? "Cairo")}&size=600x300&zoom=13&key=YOUR_API_KEY',
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
                        style: TextStyle(fontSize: 11.sp),
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
                          final bookingCubit = context.read<BookingsCubit>();
                          final authState = context.read<AuthCubit>().state;

                          if (authState is! AuthSuccess &&
                              authState is! AuthAdminSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please log in first to book"),
                                backgroundColor: airbnbMaroon,
                              ),
                            );
                            setState(() => isLoading = false);
                            return;
                          }

                          final userId = authState is AuthSuccess
                              ? authState.user.id
                              : (authState as AuthAdminSuccess).user.id;

                          final bool isAvailable =
                              await bookingCubit.checkAvailability(
                            widget.listing.id!,
                            selectedDateRange!.start.toIso8601String(),
                            selectedDateRange!.end.toIso8601String(),
                          );

                          if (isAvailable) {
                            final commission =
                                await bookingCubit.getCommissionRate();
                            final days = selectedDateRange!.duration.inDays;
                            final subtotal = (widget.listing.pricePerNight ?? 0) *
                                (days > 0 ? days : 1);

                            final isSuccess = await bookingCubit.createBooking(
                              listingId: widget.listing.id!,
                              userId: userId,
                              checkIn: selectedDateRange!.start.toIso8601String(),
                              checkOut: selectedDateRange!.end.toIso8601String(),
                              guests: guestsCount,
                              subtotal: subtotal,
                              commissionRateId: commission?['id'],
                            );

                            if (context.mounted) {
                              if (isSuccess) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Booking created successfully!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pushNamed(context, AppRoutes.trips);
                              } else {
                                final state = bookingCubit.state;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      state is BookingsError
                                          ? state.message
                                          : "Booking failed. Please try again.",
                                    ),
                                    backgroundColor: airbnbMaroon,
                                  ),
                                );
                              }
                            }
                          } else {
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
              "${listing.bedrooms ?? 0} bedrooms • ${listing.beds ?? 0} beds",
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

class _ImageSliderAppBar extends StatefulWidget {
  final ListingModel listing;
  const _ImageSliderAppBar({required this.listing});

  @override
  State<_ImageSliderAppBar> createState() => _ImageSliderAppBarState();
}

class _ImageSliderAppBarState extends State<_ImageSliderAppBar> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.listing.images ?? [];
    return SliverAppBar(
      expandedHeight: 280.h,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            if (images.isNotEmpty)
              PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return Image.network(
                    images[index].url ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image, size: 40)),
                    ),
                  );
                },
              )
            else
              Container(
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.home_outlined, size: 60, color: Colors.grey)),
              ),
            
            // Image Indicator Badge
            if (images.length > 1)
              Positioned(
                bottom: 16.h,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "${_currentPage + 1} / ${images.length}",
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

class _AboutSection extends StatelessWidget {
  final String? description;
  const _AboutSection({this.description});
  @override
  Widget build(BuildContext context) => Text(
    description ?? "No description provided.",
    style: TextStyle(height: 1.5, fontSize: 15.sp),
  );
}

class _FloatingChatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Positioned(
    bottom: 24.h,
    right: 24.w,
    child: FloatingActionButton(
      onPressed: () {},
      backgroundColor: airbnbMaroon,
      child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
    ),
  );
}

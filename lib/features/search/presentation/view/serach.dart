import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/search/data/search_model/search_result_model.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_cubit.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_state.dart';
import 'package:freelancer/features/search/presentation/widget/best_offers.dart';
import 'package:freelancer/features/search/presentation/widget/filter_selection.dart';
import 'package:freelancer/features/search/presentation/widget/top_selection_cards.dart';
import 'package:freelancer/features/search/presentation/widget/when_selection.dart';
import 'package:freelancer/features/search/presentation/widget/where_selection.dart';
import 'package:freelancer/features/search/presentation/widget/who_selection.dart';

// ═══════════════════════════════════════════════════════════════
// Search Results Screen
// ═══════════════════════════════════════════════════════════════

class SearchResultsScreen extends StatelessWidget {
  final SearchParamsModel params;
  const SearchResultsScreen({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchCubit>()..getListings(params),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F6F2),
        appBar: _buildAppBar(context),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FiltersChipsBar(params: params),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) return _buildLoading();
                  if (state is SearchError) return _buildError(state.message);
                  if (state is SearchSuccess) {
                    if (state.listings.isEmpty) return _buildEmpty();
                    return _buildResults(state.listings);
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            params.location ?? 'All listings',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (params.checkIn != null || params.guests != null)
            Text(
              [
                if (params.checkIn != null && params.checkOut != null)
                  '${params.checkIn} → ${params.checkOut}',
                '${params.guests ?? 1} guest${(params.guests ?? 1) > 1 ? 's' : ''}',
              ].join('  ·  '),
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, __) => _SkeletonCard(),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48.r, color: Colors.grey[400]),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No listings found',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your search or filters.',
            style: TextStyle(fontSize: 15.sp, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(List<SearchResultModel> listings) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: listings.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, i) => _ListingCard(listing: listings[i]),
    );
  }
}

// ── Filters Chips Bar ─────────────────────────────────────────

class _FiltersChipsBar extends StatefulWidget {
  final SearchParamsModel params;
  const _FiltersChipsBar({required this.params});

  @override
  State<_FiltersChipsBar> createState() => _FiltersChipsBarState();
}

class _FiltersChipsBarState extends State<_FiltersChipsBar> {
  late String _selectedTab;

  final List<String> _tabs = ['Best Offers', 'Main Office', 'Merakia', 'Cairo'];

  @override
  void initState() {
    super.initState();
    // أول tab مختار هو الـ location اللي جه من الـ params لو موجود
    _selectedTab = widget.params.location ?? _tabs.first;
  }

  void _onTabTap(String tab) {
    setState(() => _selectedTab = tab);

    final newParams = SearchParamsModel(
      location: tab == 'Best Offers' ? null : tab,
      checkIn: widget.params.checkIn,
      checkOut: widget.params.checkOut,
      guests: widget.params.guests,
      priceMin: widget.params.priceMin,
      priceMax: widget.params.priceMax,
      bestOffer: tab == 'Best Offers' ? true : null,
      limit: 20,
      offset: 0,
    );

    context.read<SearchCubit>().getListings(newParams);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F6F2),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tabs ──────────────────────────────────────────
          BestOffersRow(selectedTab: _selectedTab, onTabTap: _onTabTap),

          // ── Count + Chips + Clear ──────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    final count = state is SearchSuccess
                        ? state.listings.length
                        : 0;
                    return Text(
                      'Showing $count listings',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    if (widget.params.location != null)
                      _chip(Icons.location_on, widget.params.location!),
                    if (widget.params.checkIn != null)
                      _chip(
                        Icons.calendar_month,
                        '${widget.params.checkIn} - ${widget.params.checkOut}',
                      ),
                    if (widget.params.guests != null)
                      _chip(Icons.people, '${widget.params.guests}+ guests'),
                    if (widget.params.priceMin != null ||
                        widget.params.priceMax != null)
                      _chip(
                        Icons.attach_money,
                        '${widget.params.priceMin?.round() ?? 0} - ${widget.params.priceMax?.round() ?? '∞'} EGP',
                      ),
                    if (widget.params.bestOffer == true)
                      _chip(Icons.sell, 'Best Offers', isRed: true),
                  ],
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Clear all',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF8B1A1A),
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, {bool isRed = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: isRed ? const Color(0xFF8B1A1A).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: isRed ? const Color(0xFF8B1A1A) : Colors.grey.shade300,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.r,
            color: isRed ? const Color(0xFF8B1A1A) : Colors.blueGrey,
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: isRed ? const Color(0xFF8B1A1A) : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Listing Card ──────────────────────────────────────────────

class _ListingCard extends StatelessWidget {
  final SearchResultModel listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final firstImage = listing.images.isNotEmpty
        ? listing.images.first.url
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: firstImage != null
                  ? Image.network(
                      firstImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        listing.title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (listing.avgRating > 0) ...[
                      SizedBox(width: 8.w),
                      Icon(Icons.star_rounded, size: 14.r, color: Colors.amber),
                      Text(
                        listing.avgRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13.r,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${listing.city}, ${listing.country}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    _infoChip(
                      Icons.bed_outlined,
                      '${listing.beds} bed${listing.beds > 1 ? 's' : ''}',
                    ),
                    SizedBox(width: 8.w),
                    _infoChip(
                      Icons.bathroom_outlined,
                      '${listing.bathrooms} bath${listing.bathrooms > 1 ? 's' : ''}',
                    ),
                    SizedBox(width: 8.w),
                    _infoChip(
                      Icons.people_outline,
                      '${listing.maxGuests} guests',
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (listing.bestOfferPrice != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B1A1A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'Best Offer',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: const Color(0xFF8B1A1A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      const SizedBox(),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${listing.displayPrice.toStringAsFixed(0)} ${listing.currency}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: ' / night',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
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

  Widget _placeholder() => Container(
    color: Colors.grey[100],
    child: Center(
      child: Icon(Icons.image_outlined, size: 32, color: Colors.grey[400]),
    ),
  );

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 13.r, color: Colors.grey[500]),
        SizedBox(width: 3.w),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

// ── Skeleton Card ─────────────────────────────────────────────

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Container(height: 180.h, color: Colors.grey[200]),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmer(width: 160.w, height: 14.h),
                SizedBox(height: 8.h),
                _shimmer(width: 100.w, height: 11.h),
                SizedBox(height: 8.h),
                _shimmer(width: 200.w, height: 11.h),
                SizedBox(height: 10.h),
                _shimmer(width: 80.w, height: 14.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmer({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Airbnb Search Modal
// ═══════════════════════════════════════════════════════════════

class AirbnbSearchModal extends StatefulWidget {
  const AirbnbSearchModal({super.key});

  @override
  State<AirbnbSearchModal> createState() => _AirbnbSearchModalState();
}

class _AirbnbSearchModalState extends State<AirbnbSearchModal> {
  String _activeSection = 'where';
  String? _selectedDestination;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  DateTime _focusedMonth = DateTime(2026, 3);
  int _guestCount = 1;
  double _minPrice = 0;
  double _maxPrice = 5000;
  bool _bestOffer = false;
  final Set<String> _selectedAmenities = {};

  String get _dateRange {
    if (_checkInDate == null && _checkOutDate == null) return "Any dates";
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final start = _checkInDate != null
        ? "${_checkInDate!.day} ${months[_checkInDate!.month]}"
        : "Add date";
    final end = _checkOutDate != null
        ? "${_checkOutDate!.day} ${months[_checkOutDate!.month]}"
        : "Add date";
    return "$start → $end";
  }

  void _onDateTap(DateTime date) {
    setState(() {
      if (_checkInDate == null ||
          (_checkInDate != null && _checkOutDate != null)) {
        _checkInDate = date;
        _checkOutDate = null;
      } else {
        if (date.isBefore(_checkInDate!)) {
          _checkInDate = date;
        } else {
          _checkOutDate = date;
          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() => _activeSection = 'who');
          });
        }
      }
    });
  }

  void _setThisWeekend() {
    final now = DateTime.now();
    final daysUntilSat = (6 - now.weekday) % 7;
    final sat = now.add(Duration(days: daysUntilSat == 0 ? 7 : daysUntilSat));
    setState(() {
      _checkInDate = sat;
      _checkOutDate = sat.add(const Duration(days: 1));
    });
  }

  void _setNextWeek() {
    final now = DateTime.now();
    final nextMon = now.add(Duration(days: (8 - now.weekday) % 7 + 1));
    setState(() {
      _checkInDate = nextMon;
      _checkOutDate = nextMon.add(const Duration(days: 6));
    });
  }

  void _clearDates() => setState(() => _checkInDate = _checkOutDate = null);

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _onSearch() {
    final params = SearchParamsModel(
      location: _selectedDestination,
      checkIn: _formatDate(_checkInDate),
      checkOut: _formatDate(_checkOutDate),
      guests: _guestCount,
      priceMin: _minPrice > 0 ? _minPrice : null,
      priceMax: _maxPrice < 5000 ? _maxPrice : null,
      bestOffer: _bestOffer ? true : null,
      limit: 20,
      offset: 0,
    );
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchResultsScreen(params: params)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 12.h),
            height: 4.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _bestOffer = !_bestOffer),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: _bestOffer
                            ? const Color(0xFF8B1A1A).withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: _bestOffer
                              ? const Color(0xFF8B1A1A)
                              : Colors.grey.shade300,
                          width: _bestOffer ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_offer_outlined,
                            size: 18.r,
                            color: _bestOffer
                                ? const Color(0xFF8B1A1A)
                                : Colors.grey,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'Best Offers only',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: _bestOffer
                                  ? const Color(0xFF8B1A1A)
                                  : Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          if (_bestOffer)
                            Icon(
                              Icons.check_circle,
                              size: 18.r,
                              color: const Color(0xFF8B1A1A),
                            ),
                        ],
                      ),
                    ),
                  ),
                  TopSelectionCards(
                    activeSection: _activeSection,
                    selectedDestination: _selectedDestination,
                    dateRange: _dateRange,
                    guestCount: _guestCount,
                    onSectionTap: (id) => setState(() => _activeSection = id),
                  ),
                  SizedBox(height: 16.h),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildActiveSection(),
                  ),
                ],
              ),
            ),
          ),
          _buildSearchBtn(),
        ],
      ),
    );
  }

  Widget _buildActiveSection() {
    switch (_activeSection) {
      case 'where':
        return WhereSection(
          selectedDestination: _selectedDestination,
          onSelect: (dest) {
            setState(() => _selectedDestination = dest);
            Future.delayed(const Duration(milliseconds: 200), () {
              setState(() => _activeSection = 'when');
            });
          },
          onClear: () => setState(() => _selectedDestination = null),
        );
      case 'when':
        return WhenSection(
          checkInDate: _checkInDate,
          checkOutDate: _checkOutDate,
          focusedMonth: _focusedMonth,
          onDateTap: _onDateTap,
          onPrevMonth: () => setState(
            () => _focusedMonth = DateTime(
              _focusedMonth.year,
              _focusedMonth.month - 1,
            ),
          ),
          onNextMonth: () => setState(
            () => _focusedMonth = DateTime(
              _focusedMonth.year,
              _focusedMonth.month + 1,
            ),
          ),
          onThisWeekend: _setThisWeekend,
          onNextWeek: _setNextWeek,
          onClearDates: _clearDates,
        );
      case 'who':
        return WhoSection(
          guestCount: _guestCount,
          onChanged: (val) => setState(() => _guestCount = val),
        );
      case 'filters':
        return FiltersSection(
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          selectedAmenities: _selectedAmenities,
          onPriceChanged: (vals) => setState(() {
            _minPrice = vals.start;
            _maxPrice = vals.end;
          }),
          onAmenityToggle: (label) => setState(() {
            _selectedAmenities.contains(label)
                ? _selectedAmenities.remove(label)
                : _selectedAmenities.add(label);
          }),
          onReset: () => setState(() {
            _selectedAmenities.clear();
            _minPrice = 0;
            _maxPrice = 5000;
          }),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildSearchBtn() {
    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: _onSearch,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B1A1A),
          minimumSize: Size(double.infinity, 50.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, color: Colors.white, size: 18.r),
            SizedBox(width: 8.w),
            const Text(
              "Search",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

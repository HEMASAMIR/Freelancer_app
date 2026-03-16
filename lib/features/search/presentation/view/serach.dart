import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/search/data/search_model/search_result_model.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_cubit.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_state.dart';

import 'package:freelancer/features/search/presentation/widget/best_offers.dart';
import 'package:freelancer/features/search/presentation/widget/top_selection_cards.dart';
import 'package:freelancer/features/search/presentation/widget/when_selection.dart';
import 'package:freelancer/features/search/presentation/widget/where_selection.dart';
import 'package:freelancer/features/search/presentation/widget/who_selection.dart';

// ── Search Results Screen ───────────────────────────────────────
class SearchResultsScreen extends StatelessWidget {
  final SearchParamsModel params;
  const SearchResultsScreen({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchCubit>()..getListings(params: params),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F6F2),
        appBar: _buildAppBar(context),
        body: Column(
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
          if (params.checkIn != null)
            Text(
              '${params.checkIn} → ${params.checkOut}  ·  ${params.guests} guests',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildLoading() => ListView.separated(
    padding: EdgeInsets.all(16.w),
    itemCount: 5,
    separatorBuilder: (_, __) => SizedBox(height: 12.h),
    itemBuilder: (_, __) => const _SkeletonCard(),
  );

  Widget _buildResults(List<SearchResultModel> listings) => ListView.separated(
    padding: EdgeInsets.all(16.w),
    itemCount: listings.length,
    separatorBuilder: (_, __) => SizedBox(height: 12.h),
    itemBuilder: (_, i) => _ListingCard(listing: listings[i]),
  );

  Widget _buildError(String msg) => Center(child: Text(msg));
  Widget _buildEmpty() => const Center(child: Text("No listings found."));
}

// ── Filters Chips Bar ───────────────────────────────────────────
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
    _selectedTab = widget.params.location ?? _tabs.first;
  }

  void _onTabTap(String tab) {
    setState(() => _selectedTab = tab);
    final newParams = widget.params.copyWith(
      location: tab == 'Best Offers' ? null : tab,
      bestOffer: tab == 'Best Offers' ? true : null,
    );
    context.read<SearchCubit>().getListings(params: newParams);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(bottom: 12.h),
      child: BestOffersRow(selectedTab: _selectedTab, onTabTap: _onTabTap),
    );
  }
}

// ── Listing Card ────────────────────────────────────────────────
class _ListingCard extends StatelessWidget {
  final SearchResultModel listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final String? firstImageUrl = listing.images.isNotEmpty
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
              child: firstImageUrl != null
                  ? Image.network(
                      firstImageUrl,
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
                Text(
                  listing.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (listing.propertyTypeName != null)
                      Text(
                        listing.propertyTypeName!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.blueGrey,
                        ),
                      ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${listing.pricePerNight.round()} EGP',
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
    child: const Center(child: Icon(Icons.image_outlined, color: Colors.grey)),
  );
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Container(height: 150.h, color: Colors.grey[200]),
          Expanded(child: Container(color: Colors.white)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Airbnb Search Modal (Main Entry)
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
  int _guestCount = 1;

  // Filter States
  Set<String> _selectedAmenities = {};
  bool _bestOffer = false;
  double? _minPrice;
  double? _maxPrice;

  void _onSearch() {
    final params = SearchParamsModel(
      location: _selectedDestination,
      checkIn: _checkInDate?.toIso8601String().split('T').first,
      checkOut: _checkOutDate?.toIso8601String().split('T').first,
      guests: _guestCount,
      priceMin: _minPrice,
      priceMax: _maxPrice,
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
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  TopSelectionCards(
                    activeSection: _activeSection,
                    selectedDestination: _selectedDestination,
                    guestCount: _guestCount,
                    dateRange: _checkInDate != null ? "Selected" : "Any dates",
                    onSectionTap: (id) => setState(() => _activeSection = id),
                  ),
                  const SizedBox(height: 20),
                  _buildCurrentSection(),
                ],
              ),
            ),
          ),
          _buildSearchBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCurrentSection() {
    switch (_activeSection) {
      case 'where':
        return WhereSection(
          selectedDestination: _selectedDestination,
          onSelect: (dest) => setState(() {
            _selectedDestination = dest;
            _activeSection = 'when';
          }),
          onClear: () => setState(() => _selectedDestination = null),
        );
      case 'when':
        return WhenSection(
          checkInDate: _checkInDate,
          checkOutDate: _checkOutDate,
          focusedMonth: DateTime.now(),
          onDateTap: (date) => setState(() {
            if (_checkInDate == null) {
              _checkInDate = date;
            } else {
              _checkOutDate = date;
              _activeSection = 'who';
            }
          }),
          onClearDates: () =>
              setState(() => _checkInDate = _checkOutDate = null),
          onNextMonth: () {},
          onPrevMonth: () {},
          onNextWeek: () {},
          onThisWeekend: () {},
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
          onPriceChanged: (min, max) => setState(() {
            _minPrice = min;
            _maxPrice = max;
          }),
          onAmenityToggle: (amenity) => setState(() {
            if (_selectedAmenities.contains(amenity)) {
              _selectedAmenities.remove(amenity);
            } else {
              _selectedAmenities.add(amenity);
            }
          }),
          onReset: () => setState(() {
            _minPrice = null;
            _maxPrice = null;
            _selectedAmenities.clear();
          }),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildSearchBottomBar() {
    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.tune,
              color: _activeSection == 'filters'
                  ? const Color(0xFF8B1A1A)
                  : Colors.grey,
            ),
            onPressed: () => setState(() => _activeSection = 'filters'),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1A1A),
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: _onSearch,
              child: const Text(
                "Search",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── FiltersSection Widget (Dynamic Inputs) ──────────────────────
class FiltersSection extends StatefulWidget {
  final double? minPrice;
  final double? maxPrice;
  final Set<String> selectedAmenities;
  final Function(double? min, double? max) onPriceChanged;
  final ValueChanged<String> onAmenityToggle;
  final VoidCallback onReset;

  const FiltersSection({
    super.key,
    this.minPrice,
    this.maxPrice,
    required this.selectedAmenities,
    required this.onPriceChanged,
    required this.onAmenityToggle,
    required this.onReset,
  });

  @override
  State<FiltersSection> createState() => _FiltersSectionState();
}

class _FiltersSectionState extends State<FiltersSection> {
  late TextEditingController _minController;
  late TextEditingController _maxController;

  static const _amenities = [
    {'label': 'Air Conditioning', 'icon': Icons.ac_unit},
    {'label': 'Beach Access', 'icon': Icons.beach_access},
    {'label': 'Full Kitchen', 'icon': Icons.kitchen},
    {'label': 'Wifi', 'icon': Icons.wifi},
    {'label': 'Pool', 'icon': Icons.pool},
    {'label': 'Parking', 'icon': Icons.local_parking},
  ];

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.minPrice != null ? widget.minPrice!.round().toString() : '',
    );
    _maxController = TextEditingController(
      text: widget.maxPrice != null ? widget.maxPrice!.round().toString() : '',
    );
  }

  @override
  void didUpdateWidget(covariant FiltersSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // لو تم عمل Reset من بره نحدث الـ Controllers
    if (widget.minPrice == null && _minController.text.isNotEmpty) {
      _minController.clear();
    }
    if (widget.maxPrice == null && _maxController.text.isNotEmpty) {
      _maxController.clear();
    }
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _onPriceChange() {
    final min = double.tryParse(_minController.text);
    final max = double.tryParse(_maxController.text);
    widget.onPriceChanged(min, max);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Price per night",
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _priceInput("Minimum", _minController, "0")),
              SizedBox(width: 12.w),
              Expanded(
                child: _priceInput("Maximum", _maxController, "Any price"),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            "Amenities",
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _amenities.map((a) {
              final label = a['label'] as String;
              final isSelected = widget.selectedAmenities.contains(label);
              return GestureDetector(
                onTap: () => widget.onAmenityToggle(label),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF8B1A1A).withOpacity(0.08)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF8B1A1A)
                          : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        a['icon'] as IconData,
                        size: 14.r,
                        color: isSelected
                            ? const Color(0xFF8B1A1A)
                            : Colors.grey[600],
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isSelected
                              ? const Color(0xFF8B1A1A)
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _minController.clear();
                _maxController.clear();
                widget.onReset();
              },
              child: const Text(
                "Reset filters",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceInput(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => _onPriceChange(),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: 'EGP ',
            prefixStyle: TextStyle(color: Colors.grey, fontSize: 12.sp),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: Color(0xFF8B1A1A),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

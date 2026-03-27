import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/search/presentation/view/search_result_screen.dart';
// استيراد الـ Widgets المنفصلة
import 'package:freelancer/features/search/presentation/widget/filter_selection.dart';
import 'package:freelancer/features/search/presentation/widget/section_shell.dart';
import 'package:freelancer/features/search/presentation/widget/when_selection.dart';
import 'package:freelancer/features/search/presentation/widget/who_selection.dart';
import 'package:freelancer/features/search/presentation/widget/where_selection.dart';
import 'package:freelancer/features/search/presentation/widget/property_search_header.dart';
import 'package:freelancer/features/search/presentation/widget/property_search_bottom_bar.dart';

class AirbnbSearchModal extends StatefulWidget {
  // جعل الـ listing والـ initialParams اختياريين لهندسة الـ Null Safety
  final ListingModel? listing;
  final SearchParamsModel? initialParams;

  const AirbnbSearchModal({super.key, this.listing, this.initialParams});

  @override
  State<AirbnbSearchModal> createState() => _AirbnbSearchModalState();
}

class _AirbnbSearchModalState extends State<AirbnbSearchModal> {
  String activeSection = 'where';
  String? selectedDestination;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  DateTime focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  int guests = 1;
  double? minPrice;
  double? maxPrice;
  Set<String> selectedAmenities = {};

  @override
  void initState() {
    super.initState();
    // تعبئة البيانات الأولية لو موجودة (مثلاً لو بنعدل بحث حالي)
    if (widget.initialParams != null) {
      selectedDestination = widget.initialParams!.location;
      guests = widget.initialParams!.guests ?? 1;
      minPrice = widget.initialParams!.priceMin;
      maxPrice = widget.initialParams!.priceMax;
    }
  }

  void _handleDateTap(DateTime date) {
    setState(() {
      if (checkInDate == null ||
          (checkInDate != null && checkOutDate != null)) {
        checkInDate = date;
        checkOutDate = null;
      } else {
        if (date.isAfter(checkInDate!)) {
          checkOutDate = date;
        } else {
          checkInDate = date;
          checkOutDate = null;
        }
      }
    });
  }

  String get _whenSummary {
    if (checkInDate == null) return "Any dates";
    final inStr =
        "${checkInDate!.day}/${checkInDate!.month}/${checkInDate!.year}";
    if (checkOutDate == null) return inStr;
    return "$inStr → ${checkOutDate!.day}/${checkOutDate!.month}/${checkOutDate!.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Column(
        children: [
          PropertySearchHeader(
            title: "Stays",
            onClose: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                children: [
                  SectionShell(
                    isExpanded: activeSection == 'where',
                    closedTitle: "Where",
                    closedSub: selectedDestination ?? "Search destinations",
                    onTapClosed: () => setState(() => activeSection = 'where'),
                    expandedTitle: "Where to?",
                    child: WhereSection(
                      selectedDestination: selectedDestination,
                      onSelect: (dest) => setState(() {
                        selectedDestination = dest;
                        activeSection = 'when';
                      }),
                      onClear: () => setState(() => selectedDestination = null),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SectionShell(
                    isExpanded: activeSection == 'when',
                    closedTitle: "When",
                    closedSub: _whenSummary,
                    onTapClosed: () => setState(() => activeSection = 'when'),
                    expandedTitle: "When's your trip?",
                    child: WhenSection(
                      checkInDate: checkInDate,
                      checkOutDate: checkOutDate,
                      focusedMonth: focusedMonth,
                      onDateTap: _handleDateTap,
                      onPrevMonth: () => setState(
                        () => focusedMonth = DateTime(
                          focusedMonth.year,
                          focusedMonth.month - 1,
                        ),
                      ),
                      onNextMonth: () => setState(
                        () => focusedMonth = DateTime(
                          focusedMonth.year,
                          focusedMonth.month + 1,
                        ),
                      ),
                      onThisWeekend: () {
                        final now = DateTime.now();
                        final sat = DateTime(
                          now.year,
                          now.month,
                          now.day + (6 - now.weekday) % 7,
                        );
                        setState(() {
                          checkInDate = sat;
                          checkOutDate = sat.add(const Duration(days: 1));
                        });
                      },
                      onNextWeek: () {
                        final now = DateTime.now();
                        final mon = DateTime(
                          now.year,
                          now.month,
                          now.day + (8 - now.weekday),
                        );
                        setState(() {
                          checkInDate = mon;
                          checkOutDate = mon.add(const Duration(days: 6));
                        });
                      },
                      onClearDates: () => setState(() {
                        checkInDate = null;
                        checkOutDate = null;
                      }),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SectionShell(
                    isExpanded: activeSection == 'who',
                    closedTitle: "Who",
                    closedSub: "$guests guest${guests != 1 ? 's' : ''}",
                    onTapClosed: () => setState(() => activeSection = 'who'),
                    expandedTitle: "How many guests?",
                    child: WhoSection(
                      guestCount: guests,
                      onChanged: (val) => setState(() => guests = val),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SectionShell(
                    isExpanded: activeSection == 'filters',
                    closedTitle: "Filters",
                    closedSub: (minPrice != null || maxPrice != null)
                        ? "EGP ${minPrice?.round() ?? 0} – ${maxPrice != null ? 'EGP ${maxPrice!.round()}' : 'Any'}"
                        : "Price & more",
                    onTapClosed: () =>
                        setState(() => activeSection = 'filters'),
                    expandedTitle: "Filters",
                    child: FiltersSection(
                      minPrice: minPrice,
                      maxPrice: maxPrice,
                      selectedAmenities: selectedAmenities,
                      onPriceChanged: (min, max) => setState(() {
                        minPrice = min;
                        maxPrice = max;
                      }),
                      onAmenityToggle: (a) => setState(() {
                        selectedAmenities.contains(a)
                            ? selectedAmenities.remove(a)
                            : selectedAmenities.add(a);
                      }),
                      onReset: () => setState(() {
                        minPrice = null;
                        maxPrice = null;
                        selectedAmenities.clear();
                      }),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          PropertySearchBottomBar(
            onClearAll: () {
              setState(() {
                selectedDestination = null;
                checkInDate = null;
                checkOutDate = null;
                guests = 1;
                minPrice = null;
                maxPrice = null;
                selectedAmenities.clear();
              });
            },
            onSearch: () {
              // 1. تجميع كل الاختيارات في موديل الـ Params
              final searchParams = SearchParamsModel(
                location: selectedDestination,
                checkIn: checkInDate?.toIso8601String(),
                checkOut: checkOutDate?.toIso8601String(),
                guests: guests,
                priceMin: minPrice,
                priceMax: maxPrice,
                bestOffer: false,
              );

              Navigator.pushNamed(
                context,
                AppRoutes.searchResult, 
                arguments: searchParams, 
              );
            },
          ),
        ],
      ),
    );
  }
}

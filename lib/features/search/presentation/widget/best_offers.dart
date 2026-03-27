import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';

class BestOffersRow extends StatefulWidget {
  /// لو استدعيته من شاشة تانية بدون params — يشتغل standalone
  /// لو استدعيته من _FiltersChipsBar — بيستقبل selectedTab و onTabTap من بره
  final String? selectedTab;
  final ValueChanged<String>? onTabTap;

  const BestOffersRow({super.key, this.selectedTab, this.onTabTap});

  @override
  State<BestOffersRow> createState() => _BestOffersRowState();
}

class _BestOffersRowState extends State<BestOffersRow> {
  late String _selected;

  static const List<String> tabs = [
    'Best Offers',
    'Main Office',
    'Merakia',
    'Cairo',
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedTab ?? tabs.first;
  }

  void _onTap(String tab) {
    setState(() => _selected = tab);

    if (widget.onTabTap != null) {
      widget.onTabTap!(tab);
      return;
    }

    final params = SearchParamsModel(
      location: tab == 'Best Offers' ? null : tab,
      bestOffer: tab == 'Best Offers' ? true : false,
      limit: 20,
      offset: 0,
    );

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => BlocProvider(
    //       create: (_) => sl<SearchCubit>()..getListings(params: params),
    //       child: (params: params),
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selected == tab;
          return GestureDetector(
            onTap: () => _onTap(tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF8B1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF8B1A1A)
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

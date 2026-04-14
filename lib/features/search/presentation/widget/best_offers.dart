import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_cubit.dart';
import 'package:freelancer/features/search/presentation/view/search_result_screen.dart';

class BestOffersRow extends StatefulWidget {
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

    // لو في callback من بره — فوّض له وخلاص
    if (widget.onTabTap != null) {
      widget.onTabTap!(tab);
      return;
    }

    // ✅ FIX: Standalone mode — بنبني الـ params صح وبنفتح الـ SearchResultScreen
    final params = SearchParamsModel(
      location: tab == 'Best Offers' ? null : tab,
      bestOffer: tab == 'Best Offers',
      limit: 20,
      offset: 0,
    );

    // ✅ FIX: فكّينا التعليق وصلّحنا الـ syntax (كان child: (params: params) وده خطأ)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<SearchCubit>()..getListings(params: params),
          child: SearchResultScreen(params: params),
        ),
      ),
    );
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

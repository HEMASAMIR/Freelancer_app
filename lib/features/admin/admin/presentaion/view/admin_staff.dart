import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/features/admin/admin/widget/page_header.dart';
import 'package:freelancer/features/admin/admin/widget/search_filter.dart';
import 'package:freelancer/features/admin/admin/widget/staf_data_table.dart';
import 'package:freelancer/features/admin/admin/widget/table_pagination.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20.h),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            CustomAppBar(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                maroonColor: AppColors.maroon,
                greyColor: AppColors.textGrey,
              ),
              SizedBox(height: 30.h),
              SearchFilterField(),
              SizedBox(height: 20.h),
              StaffDataTable(greyColor: AppColors.textGrey),
              SizedBox(height: 20.h),
              TablePagination(greyColor: AppColors.textGrey),
            ],
          ),
        ),
      ),
    );
  }
}

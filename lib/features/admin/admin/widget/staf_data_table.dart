import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/features/admin/admin/widget/staff_row.dart';
import 'package:freelancer/features/admin/admin/widget/table_header.dart';

class StaffDataTable extends StatelessWidget {
  final Color greyColor;
  const StaffDataTable({required this.greyColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          TableHeaderRow(),
          const Divider(height: 1),
          StaffRow(
            name: 'Staff One',
            email: 'staff.1@example.com',
            role: 'SO',
            greyColor: greyColor,
            index: 1,
          ),
          StaffRow(
            name: 'Platform Owner',
            email: 'admin@example.com',
            role: 'PO',
            isMe: true,
            greyColor: greyColor,
            index: 2,
          ),
        ],
      ),
    );
  }
}

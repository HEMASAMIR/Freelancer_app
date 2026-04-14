import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/features/admin/admin/widget/page_action.dart';

class TablePagination extends StatelessWidget {
  final Color greyColor;
  const TablePagination({super.key, required this.greyColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '2 row(s) total',
          style: TextStyle(fontSize: 12.sp, color: greyColor),
        ),
        Row(
          children: [
            Text('Page 1 of 1', style: TextStyle(fontSize: 12.sp)),
            SizedBox(width: 10.w),
            PageActionBtn(icon: Icons.chevron_left),
            PageActionBtn(icon: Icons.chevron_right),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TableHeaderRow extends StatelessWidget {
  const TableHeaderRow({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('Staff Member', style: _headerStyle())),
          Expanded(flex: 3, child: Text('Email', style: _headerStyle())),
          Icon(Icons.unfold_more, size: 16.sp, color: Colors.grey),
        ],
      ),
    );
  }

  TextStyle _headerStyle() =>
      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600);
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PropertyBottomBar extends StatelessWidget {
  final double price;
  final VoidCallback onReserve;

  const PropertyBottomBar({
    super.key,
    required this.price,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 30.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EGP ${price.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                'per night',
                style: TextStyle(color: Colors.grey, fontSize: 12.sp),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onReserve,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBD1E59),
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Reserve',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

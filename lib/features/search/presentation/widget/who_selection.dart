import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// --- الشاشة الرئيسية اللي فيها الـ Logic ---
class WhoBookingPage extends StatefulWidget {
  const WhoBookingPage({super.key});

  @override
  State<WhoBookingPage> createState() => _WhoBookingPageState();
}

class _WhoBookingPageState extends State<WhoBookingPage> {
  bool isWhoExpanded = false; // التحكم في التبديل بين الشكلين
  int guests = 1; // عدد الضيوف

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // --- التعديل هنا: التبديل بين الكارت الصغير والسكشن الكبير ---
              if (!isWhoExpanded)
                // 1. الكارت الصغير (يظهر في البداية)
                GestureDetector(
                  onTap: () => setState(() => isWhoExpanded = true),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Who",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          guests > 1 ? "$guests guests" : "Add guests",
                          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // 2. السكشن الكبير (يظهر لما تضغط على Who)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الهيدر الداخلي (أيقونة الشخص + السؤال)
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 24.r),
                          SizedBox(width: 10.w),
                          Text(
                            "How many guests?",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      // الـ WhoSection اللي فيه الزائد والناقص
                      WhoSection(
                        guestCount: guests,
                        onChanged: (val) => setState(() => guests = val),
                      ),
                      // زرار Done اختياري لو عايز ترجع لشكل الكارت الصغير
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              setState(() => isWhoExpanded = false),
                          child: const Text(
                            "Done",
                            style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // زرار البحث الأحمر
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBD1E59),
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () => print("Searching for $guests guests"),
                child: Text(
                  "Search",
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- الـ Widget اللي إنت بعتها (جوه نفس الملف) ---
class WhoSection extends StatelessWidget {
  final int guestCount;
  final ValueChanged<int> onChanged;

  const WhoSection({
    super.key,
    required this.guestCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Adults",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
              Text(
                "Ages 13 or above",
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
            ],
          ),
          Row(
            children: [
              _CircleBtn(
                icon: Icons.remove,
                onTap: guestCount > 1 ? () => onChanged(guestCount - 1) : null,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Text(
                  "$guestCount",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              _CircleBtn(
                icon: Icons.add,
                onTap: () => onChanged(guestCount + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// زرار الزائد والناقص
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircleBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: onTap == null ? Colors.grey.shade200 : Colors.grey.shade400,
          ),
        ),
        child: Icon(
          icon,
          size: 18.r,
          color: onTap == null ? Colors.grey.shade300 : Colors.black,
        ),
      ),
    );
  }
}

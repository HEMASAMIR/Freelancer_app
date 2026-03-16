import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WhenSection extends StatelessWidget {
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final DateTime focusedMonth;
  final ValueChanged<DateTime> onDateTap;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onThisWeekend;
  final VoidCallback onNextWeek;
  final VoidCallback onClearDates;

  const WhenSection({
    super.key,
    required this.checkInDate,
    required this.checkOutDate,
    required this.focusedMonth,
    required this.onDateTap,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onThisWeekend,
    required this.onNextWeek,
    required this.onClearDates,
  });

  static const _monthNames = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _shortMonths = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime d) =>
      "${d.day} ${_shortMonths[d.month]} ${d.year}";

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('when'),
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Check-in / Check-out boxes
          Row(
            children: [
              Expanded(
                child: _DateBox(
                  label: "Check-in",
                  value: checkInDate != null
                      ? _formatDate(checkInDate!)
                      : "Add date",
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _DateBox(
                  label: "Check-out",
                  value: checkOutDate != null
                      ? _formatDate(checkOutDate!)
                      : "Add date",
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Two months
          _MonthCalendar(
            month: focusedMonth,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            monthNames: _monthNames,
            onDateTap: onDateTap,
          ),
          SizedBox(height: 20.h),
          _MonthCalendar(
            month: DateTime(focusedMonth.year, focusedMonth.month + 1),
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            monthNames: _monthNames,
            onDateTap: onDateTap,
          ),

          SizedBox(height: 8.h),

          // Prev / Next nav
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavBtn(icon: Icons.chevron_left, onTap: onPrevMonth),
              _NavBtn(icon: Icons.chevron_right, onTap: onNextMonth),
            ],
          ),

          SizedBox(height: 16.h),

          Text(
            "QUICK OPTIONS",
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 10.h),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickChip(label: "This weekend", onTap: onThisWeekend),
              _QuickChip(label: "Next week", onTap: onNextWeek),
              _QuickChip(label: "Next month", onTap: onNextMonth),
              _QuickChip(
                label: "Clear dates",
                onTap: onClearDates,
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets (private, scoped to this file) ────────────────

class _DateBox extends StatelessWidget {
  final String label;
  final String value;
  const _DateBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isSet = value != "Add date";
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSet ? const Color(0xFF8B1A1A) : Colors.grey.shade300,
          width: isSet ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isSet ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  final DateTime month;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final List<String> monthNames;
  final ValueChanged<DateTime> onDateTap;

  const _MonthCalendar({
    required this.month,
    required this.checkInDate,
    required this.checkOutDate,
    required this.monthNames,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    const dayNames = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final today = DateTime.now();

    return Column(
      children: [
        Text(
          "${monthNames[month.month]} ${month.year}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
        ),
        SizedBox(height: 10.h),
        Row(
          children: dayNames
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        SizedBox(height: 6.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.1,
          ),
          itemCount: startWeekday + daysInMonth,
          itemBuilder: (_, index) {
            if (index < startWeekday) return const SizedBox();
            final day = index - startWeekday + 1;
            final date = DateTime(month.year, month.month, day);
            final isPast = date.isBefore(
              DateTime(today.year, today.month, today.day),
            );

            final isIn =
                checkInDate != null &&
                date.year == checkInDate!.year &&
                date.month == checkInDate!.month &&
                date.day == checkInDate!.day;

            final isOut =
                checkOutDate != null &&
                date.year == checkOutDate!.year &&
                date.month == checkOutDate!.month &&
                date.day == checkOutDate!.day;

            final inRange =
                checkInDate != null &&
                checkOutDate != null &&
                date.isAfter(checkInDate!) &&
                date.isBefore(checkOutDate!);

            return GestureDetector(
              onTap: isPast ? null : () => onDateTap(date),
              child: Container(
                margin: EdgeInsets.all(1.r),
                decoration: BoxDecoration(
                  color: isIn || isOut
                      ? const Color(0xFF8B1A1A)
                      : inRange
                      ? const Color(0xFFF1DADA)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Center(
                  child: Text(
                    "$day",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isIn || isOut
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isIn || isOut
                          ? Colors.white
                          : isPast
                          ? Colors.grey[300]
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 18.r),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  const _QuickChip({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDestructive ? Colors.red.shade200 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20.r),
          color: isDestructive ? Colors.red.shade50 : Colors.white,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
      ),
    );
  }
}

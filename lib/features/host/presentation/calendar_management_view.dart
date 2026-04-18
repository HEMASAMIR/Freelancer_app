import 'package:flutter/material.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';

class CalendarManagementView extends StatelessWidget {
  const CalendarManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calendar Management',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Block dates or set custom prices for your listings.',
          style: TextStyle(fontSize: 16, color: AppColors.sub),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.dividerGrey.withOpacity(0.5)),
          ),
          child: const Column(
            children: [
              Icon(Icons.calendar_month, size: 64, color: AppColors.primaryRed),
              SizedBox(height: 24),
              Text(
                'Calendar Integration',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Full calendar functionality with date blocking and price overrides is being finalized.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.sub),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

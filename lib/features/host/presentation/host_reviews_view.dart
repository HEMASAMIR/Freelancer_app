import 'package:flutter/material.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';

class HostReviewsView extends StatelessWidget {
  const HostReviewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Host Reviews',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Feedback from guests who stayed at your properties.',
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
              Icon(Icons.star_outline, size: 64, color: Colors.amber),
              SizedBox(height: 24),
              Text(
                'No Reviews Yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Once guests start leaving feedback, it will appear here.',
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

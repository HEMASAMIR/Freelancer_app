import 'package:flutter/material.dart';
import 'package:freelancer/core/constant/constant.dart';

class OverviewFooter extends StatelessWidget {
  const OverviewFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 0.5, color: AppColors.dividerGrey.withValues(alpha: 0.5)),
        const SizedBox(height: 24),
        const Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            Text(
              '© 2026 Quickin, Inc.',
              style: TextStyle(fontSize: 11, color: AppColors.sub),
            ),
            Text(
              '·',
              style: TextStyle(fontSize: 11, color: AppColors.greyText),
            ),
            Text('Terms', style: TextStyle(fontSize: 11, color: AppColors.sub)),
            Text(
              '·',
              style: TextStyle(fontSize: 11, color: AppColors.greyText),
            ),
            Text(
              'Sitemap',
              style: TextStyle(fontSize: 11, color: AppColors.sub),
            ),
            Text(
              '·',
              style: TextStyle(fontSize: 11, color: AppColors.greyText),
            ),
            Text(
              'Privacy',
              style: TextStyle(fontSize: 11, color: AppColors.sub),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.language, size: 14, color: AppColors.sub),
            SizedBox(width: 4),
            Text(
              'Arabic',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.sub,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 12),
            Text(
              '\$ USD',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.sub,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

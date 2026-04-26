import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HostSection extends StatelessWidget {
  final String? selfieUrl;
  final String fullName;
  final String joinedDate;

  const HostSection({
    super.key,
    this.selfieUrl,
    required this.fullName,
    required this.joinedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28.r,
          backgroundColor: Colors.grey[200],
          backgroundImage: selfieUrl != null ? CachedNetworkImageProvider(selfieUrl!) : null,
          child: selfieUrl == null
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        SizedBox(width: 15.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hosted by $fullName',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              'Joined in $joinedDate',
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
            ),
          ],
        ),
      ],
    );
  }
}

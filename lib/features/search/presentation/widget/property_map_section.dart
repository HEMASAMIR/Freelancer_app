import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PropertyMapSection extends StatelessWidget {
  final double lat;
  final double lng;
  final String? locationName;

  const PropertyMapSection({
    super.key,
    required this.lat,
    required this.lng,
    this.locationName,
  });

  /// Google Maps link for opening in external map app
  String get _googleMapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Where you'll be",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        if (locationName != null && locationName!.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            locationName!,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
        SizedBox(height: 15.h),
        Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Interactive map
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lng),
                  initialZoom: 14.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.freelancer.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lng),
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF5B0F16),
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // "Open in Maps" overlay
              Positioned(
                bottom: 10.h,
                right: 10.w,
                child: GestureDetector(
                  onTap: () => _openInMaps(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.open_in_new,
                          size: 14.r,
                          color: const Color(0xFF5B0F16),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Open in Maps',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5B0F16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openInMaps() async {
    final uri = Uri.parse(_googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

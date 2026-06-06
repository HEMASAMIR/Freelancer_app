import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';

class PropertyDetailsView extends StatefulWidget {
  final ListingModel listing;

  const PropertyDetailsView({super.key, required this.listing});

  @override
  State<PropertyDetailsView> createState() => _PropertyDetailsViewState();
}

class _PropertyDetailsViewState extends State<PropertyDetailsView> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.listing.images ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- الهيدر: صورة كاملة وزرار رجوع احترافي ---
          SliverAppBar(
            expandedHeight:
                0.6.sh, // ياخد 60% من طول الشاشة بالظبط مهما كان حجم الموبايل
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            elevation: 0,
            // زرار الرجوع بتصميم دائري شيك
            leading: Padding(
              padding: EdgeInsets.all(10.r),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black,
                    size: 18.r,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (images.isNotEmpty)
                    PageView.builder(
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        String imageUrl = images[index].url ?? '';

                        // إصلاح الرابط لو جاي من Supabase Storage مباشرة
                        if (imageUrl.isNotEmpty &&
                            !imageUrl.startsWith('http')) {
                          if (imageUrl.startsWith('/')) {
                            imageUrl = '${SupabaseKeys.supabaseUrl}$imageUrl';
                          } else {
                            imageUrl =
                                '${SupabaseKeys.supabaseUrl}/storage/v1/object/public/$imageUrl';
                          }
                        }

                        return Hero(
                          tag: index == 0
                              ? 'listing-${widget.listing.id}'
                              : 'listing-img-$index',
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[100]),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 50),
                    ),
                  // مؤشر الصفحات (النقط)
                  if (images.length > 1)
                    Positioned(
                      bottom: 20.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => Container(
                            width: 8.w,
                            height: 8.w,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // --- محتوى بيانات العقار ---
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.listing.title ?? "تفاصيل العقار",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBurgundy,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    widget.listing.description ??
                        "لا يوجد وصف متاح لهذا العقار حالياً.",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(
                    height: 100.h,
                  ), // مساحة إضافية عشان البار اللي تحت لو هتعمله
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_form_cubit.dart';


class WizardStep6Photos extends StatelessWidget {
  const WizardStep6Photos({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add some photos',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.inkBlack,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          SizedBox(height: 32.h),

          BlocBuilder<ListingFormCubit, ListingFormState>(
            builder: (context, formState) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Mocking file upload to allow progression testing
                      context.read<ListingFormCubit>().addPhotos(['https://mock.image/path.jpg']);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 24.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withValues(alpha: 0.02),
                        border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.3), width: 2),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.5), width: 1.5),
                            ),
                            child: Icon(Icons.file_upload_outlined, color: AppColors.primaryRed, size: 32.sp),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'Drag & drop photos here',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryRed,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'or click to select files (JPG, PNG, WebP)',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.greyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (formState.photoPaths.isNotEmpty) ...[
                    SizedBox(height: 32.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.w,
                        mainAxisSpacing: 8.h,
                      ),
                      itemCount: formState.photoPaths.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            image: const DecorationImage(
                              image: NetworkImage('https://i.stack.imgur.com/HILmr.png'), // Placeholder
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ]
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

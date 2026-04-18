import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
                  // ── Upload Zone ────────────────────────────────────
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final List<XFile> images = await picker.pickMultiImage();
                      if (images.isEmpty || !context.mounted) return;

                      if (kIsWeb) {
                        // Web: read bytes from XFile
                        final Map<String, Uint8List> bytesMap = {};
                        final List<String> paths = [];
                        for (final xfile in images) {
                          final bytes = await xfile.readAsBytes();
                          bytesMap[xfile.name] = bytes;
                          paths.add(xfile.name);
                        }
                        if (context.mounted) {
                          context
                              .read<ListingFormCubit>()
                              .addPhotos(paths, bytes: bytesMap);
                        }
                      } else {
                        // Mobile/Desktop: use file path
                        final paths = images.map((e) => e.path).toList();
                        if (context.mounted) {
                          context.read<ListingFormCubit>().addPhotos(paths);
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          vertical: 48.h, horizontal: 24.w),
                      decoration: BoxDecoration(
                        color:
                            AppColors.primaryRed.withValues(alpha: 0.02),
                        border: Border.all(
                            color: AppColors.primaryRed
                                .withValues(alpha: 0.3),
                            width: 2),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primaryRed
                                      .withValues(alpha: 0.5),
                                  width: 1.5),
                            ),
                            child: Icon(Icons.file_upload_outlined,
                                color: AppColors.primaryRed, size: 32.sp),
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

                  // ── Photo Grid ─────────────────────────────────────
                  if (formState.photoPaths.isNotEmpty) ...[
                    SizedBox(height: 32.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.w,
                        mainAxisSpacing: 8.h,
                      ),
                      itemCount: formState.photoPaths.length,
                      itemBuilder: (context, index) {
                        final path = formState.photoPaths[index];
                        final bytes = formState.photoBytes[path];

                        ImageProvider imageProvider;
                        if (kIsWeb && bytes != null) {
                          imageProvider = MemoryImage(bytes);
                        } else if (!kIsWeb) {
                          imageProvider = FileImage(File(path));
                        } else {
                          // Web but no bytes — shouldn't happen, fallback
                          imageProvider = const AssetImage(
                              'assets/images/placeholder.png');
                        }

                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(8.r),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4.h,
                              right: 4.w,
                              child: GestureDetector(
                                onTap: () => context
                                    .read<ListingFormCubit>()
                                    .removePhoto(path),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close,
                                      size: 14.sp,
                                      color: AppColors.primaryRed),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

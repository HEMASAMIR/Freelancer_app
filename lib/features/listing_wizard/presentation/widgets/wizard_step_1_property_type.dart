import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/listing_wizard/data/models/wizard_models.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_cubit.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_state.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_form_cubit.dart';

class WizardStep1PropertyType extends StatelessWidget {
  WizardStep1PropertyType({super.key});

  /// Returns an icon for a given property type name (case-insensitive fallback)
  IconData _iconForType(String name) {
    final n = name.toLowerCase();
    if (n.contains('apartment')) return Icons.domain;
    if (n.contains('house')) return Icons.home_outlined;
    if (n.contains('guest')) return Icons.holiday_village_outlined;
    if (n.contains('hotel')) return Icons.business;
    if (n.contains('villa')) return Icons.villa_outlined;
    if (n.contains('unit')) return Icons.meeting_room_outlined;
    if (n.contains('studio')) return Icons.single_bed_outlined;
    if (n.contains('cabin')) return Icons.cabin_outlined;
    return Icons.other_houses_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListingWizardCubit, ListingWizardState>(
      builder: (context, wizardState) {
        final bool isLoading = wizardState is ListingWizardLookupsLoading;
        final List<PropertyTypeModel> apiTypes = wizardState is ListingWizardLookupsLoaded
            ? wizardState.propertyTypes.cast<PropertyTypeModel>()
            : [];

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Which of these best describes your home?',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkBlack,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 32.h),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (apiTypes.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.wifi_off_outlined, size: 40.sp, color: AppColors.greyText),
                      SizedBox(height: 12.h),
                      Text(
                        'Could not load property types.\nPlease check your connection.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
                      ),
                    ],
                  ),
                )
              else
                BlocBuilder<ListingFormCubit, ListingFormState>(
                  builder: (context, formState) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: apiTypes.length,
                      itemBuilder: (context, index) {
                        final type = apiTypes[index];
                        // Use the UUID from the API — always correct
                        final String uuid = type.id;
                        final isSelected = formState.selectedPropertyTypeId == uuid;

                        return GestureDetector(
                          onTap: () {
                            context.read<ListingFormCubit>().setPropertyType(uuid);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isSelected ? AppColors.inkBlack : AppColors.dividerGrey.withValues(alpha: 0.5),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  _iconForType(type.name),
                                  size: 36.sp,
                                  color: isSelected ? AppColors.inkBlack : Colors.grey.shade800,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  type.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.inkBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

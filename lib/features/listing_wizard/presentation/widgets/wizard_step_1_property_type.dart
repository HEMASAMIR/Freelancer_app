import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_cubit.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_state.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_form_cubit.dart';

class WizardStep1PropertyType extends StatelessWidget {
  WizardStep1PropertyType({super.key});

  final List<Map<String, dynamic>> _staticItems = [
    {
      'name': 'Apartment',
      'subtitle': 'A rented unit in a\nmulti-unit building',
      'icon': Icons.domain,
    },
    {
      'name': 'House',
      'subtitle': 'A standalone\nresidential building',
      'icon': Icons.home_outlined,
    },
    {
      'name': 'Guest House',
      'subtitle': 'A separate unit on the\nsame property as the\nmain house',
      'icon': Icons.holiday_village_outlined,
    },
    {
      'name': 'Hotel',
      'subtitle': 'A room in a hotel or\nboutique hotel',
      'icon': Icons.business,
    },
    {
      'name': 'Unit',
      'subtitle': 'A generic rented unit',
      'icon': Icons.meeting_room_outlined,
    },
    {
      'name': 'Villa',
      'subtitle': 'A luxurious residence\noften with a yard',
      'icon': Icons.villa_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListingWizardCubit, ListingWizardState>(
      builder: (context, wizardState) {
        // Collect API IDs if available so database doesn't crash on save
        final List<dynamic> apiTypes = wizardState is ListingWizardLookupsLoaded ? wizardState.propertyTypes : [];

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
                    itemCount: _staticItems.length,
                    itemBuilder: (context, index) {
                      final item = _staticItems[index];
                      final itemName = item['name'] as String;
                      
                      // Match with API ID if it exists, otherwise fallback to the string name
                      final apiMatch = apiTypes.where((t) => t.name.toString().toLowerCase() == itemName.toLowerCase()).firstOrNull;
                      final String realId = apiMatch != null ? apiMatch.id.toString() : itemName;
                      
                      final isSelected = formState.selectedPropertyTypeId == realId;
                      
                      return GestureDetector(
                        onTap: () {
                          context.read<ListingFormCubit>().setPropertyType(realId);
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
                                item['icon'] as IconData,
                                size: 36.sp,
                                color: isSelected ? AppColors.inkBlack : Colors.grey.shade800,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                itemName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.inkBlack,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                item['subtitle'] as String,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.greyText,
                                  height: 1.2,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_cubit.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_state.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_form_cubit.dart';

class WizardStep1PropertyType extends StatelessWidget {
  const WizardStep1PropertyType({super.key});

  IconData _getIconForType(String typeString) {
    final t = typeString.toLowerCase();
    if (t.contains('apartment')) return Icons.apartment;
    if (t.contains('villa')) return Icons.villa_outlined;
    if (t.contains('guest')) return Icons.holiday_village_outlined;
    if (t.contains('house')) return Icons.home_outlined;
    if (t.contains('hotel')) return Icons.domain;
    if (t.contains('unit')) return Icons.meeting_room_outlined;
    return Icons.domain_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListingWizardCubit, ListingWizardState>(
      builder: (context, wizardState) {
        if (wizardState is! ListingWizardLookupsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final types = wizardState.propertyTypes;

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
                      childAspectRatio: 0.85,
                    ),
                    itemCount: types.length,
                    itemBuilder: (context, index) {
                      final item = types[index];
                      final isSelected = formState.selectedPropertyTypeId == item.id.toString();
                      
                      return GestureDetector(
                        onTap: () {
                          context.read<ListingFormCubit>().setPropertyType(item.id.toString());
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSelected ? AppColors.inkBlack : AppColors.dividerGrey.withValues(alpha: 0.5),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _getIconForType(item.name),
                                size: 32.sp,
                                color: AppColors.inkBlack,
                              ),
                              const Spacer(),
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
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

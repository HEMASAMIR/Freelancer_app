import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_cubit.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_state.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_form_cubit.dart';

class WizardStep2Lifestyles extends StatelessWidget {
  const WizardStep2Lifestyles({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListingWizardCubit, ListingWizardState>(
      builder: (context, wizardState) {
        if (wizardState is! ListingWizardLookupsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = wizardState.lifestyleCategories;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Describe the vibe',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkBlack,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Select up to 2 tags that best fit your listing.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.greyText,
                ),
              ),
              SizedBox(height: 32.h),
              
              BlocBuilder<ListingFormCubit, ListingFormState>(
                builder: (context, formState) {
                  final selectedCount = formState.selectedLifestyleIds.length;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: categories.map((tag) {
                          final isSelected = formState.selectedLifestyleIds.contains(tag.id.toString());
                          return GestureDetector(
                            onTap: () {
                              context.read<ListingFormCubit>().toggleLifestyle(tag.id.toString());
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(30.r),
                                border: Border.all(
                                  color: isSelected ? AppColors.inkBlack : AppColors.dividerGrey,
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Text(
                                tag.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: AppColors.inkBlack,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 32.h),
                      
                      if (selectedCount == 0)
                        Text(
                          'Please select at least 1 tag',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                      SizedBox(height: 8.h),
                      Text(
                        'Selected: $selectedCount/2',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.greyText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

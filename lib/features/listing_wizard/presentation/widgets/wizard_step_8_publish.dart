import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_form_cubit.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_state.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_cubit.dart';

class WizardStep8Publish extends StatelessWidget {
  const WizardStep8Publish({super.key});

  @override
  Widget build(BuildContext context) {
    // We need BOTH cubits — nest their builders so we always have fresh data.
    return BlocBuilder<ListingWizardCubit, ListingWizardState>(
      builder: (context, wizardState) {
        return BlocBuilder<ListingFormCubit, ListingFormState>(
          builder: (context, formState) {
            // Walk up the state hierarchy to find the last LookupsLoaded state.
            // The cubit may be in a sub-state (e.g. LocationsLoaded) that doesn't
            // carry the lookup lists — so we always read it from the cubit directly
            // as a fallback, which holds the *current* state.
            final lookupsState = wizardState is ListingWizardLookupsLoaded
                ? wizardState
                : (context.read<ListingWizardCubit>().state
                        is ListingWizardLookupsLoaded
                    ? context.read<ListingWizardCubit>().state
                        as ListingWizardLookupsLoaded
                    : null);

            String cityName = formState.cityId;
            String countryName = formState.countryId;
            String conditionNames = 'No specific limits';

            if (lookupsState != null) {
              final city = lookupsState.cities
                  .where((c) => c.id.toString() == formState.cityId)
                  .firstOrNull;
              if (city != null) cityName = city.name;

              final country = lookupsState.countries
                  .where((c) => c.id.toString() == formState.countryId)
                  .firstOrNull;
              if (country != null) countryName = country.name;

              if (formState.selectedConditionIds.isNotEmpty) {
                final activeConditions = lookupsState.listingConditions
                    .where((c) =>
                        formState.selectedConditionIds
                            .contains(c.id.toString()))
                    .map((e) => e.name)
                    .toList();
                conditionNames = activeConditions.join(', ');
              }
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review and Publish',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkBlack,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 32.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.dividerGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryRow('Title', formState.titleEn.isEmpty ? 'Untitled' : formState.titleEn),
                        _buildSummaryRow('Location', '$cityName, $countryName'),
                        _buildSummaryRow('Price', '${formState.pricePerNight} ${formState.currency}'),
                        _buildSummaryRow('Conditions', conditionNames),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: RichText(
        text: TextSpan(
          text: '$title: ',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.inkBlack),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.inkBlack),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_form_cubit.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_cubit.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_state.dart';

class WizardStep3Descriptions extends StatefulWidget {
  const WizardStep3Descriptions({super.key});

  @override
  State<WizardStep3Descriptions> createState() => _WizardStep3DescriptionsState();
}

class _WizardStep3DescriptionsState extends State<WizardStep3Descriptions> {
  late TextEditingController _titleEnController;
  late TextEditingController _titleArController;
  late TextEditingController _descEnController;
  late TextEditingController _descArController;

  @override
  void initState() {
    super.initState();
    final formState = context.read<ListingFormCubit>().state;
    _titleEnController = TextEditingController(text: formState.titleEn);
    _titleArController = TextEditingController(text: formState.titleAr);
    _descEnController = TextEditingController(text: formState.descriptionEn);
    _descArController = TextEditingController(text: formState.descriptionAr);

    _titleEnController.addListener(_updateForm);
    _titleArController.addListener(_updateForm);
    _descEnController.addListener(_updateForm);
    _descArController.addListener(_updateForm);
  }

  void _updateForm() {
    context.read<ListingFormCubit>().setTitles(
          en: _titleEnController.text,
          ar: _titleArController.text,
        );
    context.read<ListingFormCubit>().setDescriptions(
          en: _descEnController.text,
          ar: _descArController.text,
        );
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleArController.dispose();
    _descEnController.dispose();
    _descArController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let\'s give your place a name and description',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.inkBlack,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          SizedBox(height: 32.h),

          _buildInputField(
            title: 'Title (English)',
            hint: 'e.g., Cozy Cabin with Mountain View',
            controller: _titleEnController,
          ),
          _buildInputField(
            title: 'Title (Arabic) / (بالعربية)',
            hint: 'مثال: كابينة مريحة مع إطلالة على الجبل',
            controller: _titleArController,
            isRtl: true,
          ),
          _buildInputField(
            title: 'Description (English)',
            hint: 'Describe your place...',
            controller: _descEnController,
            maxLines: 4,
          ),
          _buildInputField(
            title: 'Description (Arabic) / (بالعربية)',
            hint: '... صف مكانك',
            controller: _descArController,
            maxLines: 4,
            isRtl: true,
          ),
          BlocBuilder<ListingFormCubit, ListingFormState>(
            builder: (context, state) {
              if (state.descriptionAr.length < 20 && state.descriptionAr.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Text(
                    'Description must be at least 20 characters',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.primaryRed, fontWeight: FontWeight.w600),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          _buildConditionsSection(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String title,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    bool isRtl = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.inkBlack,
          ),
        ),
        SizedBox(height: 8.h),
        Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(fontSize: 15.sp, color: AppColors.inkBlack),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 15.sp, color: AppColors.greyText.withValues(alpha: 0.5)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.dividerGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.dividerGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primaryRed, width: 1.5),
              ),
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildConditionsSection() {
    return BlocBuilder<ListingWizardCubit, ListingWizardState>(
      builder: (context, wizardState) {
        if (wizardState is! ListingWizardLookupsLoaded) {
          return const SizedBox.shrink(); 
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Listing Conditions / House Rules',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.inkBlack),
            ),
            SizedBox(height: 8.h),
            BlocBuilder<ListingFormCubit, ListingFormState>(
              builder: (context, formState) {
                return GestureDetector(
                  onTap: () => _showConditionsSheet(context, wizardState.listingConditions),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.dividerGrey),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formState.selectedConditionIds.isEmpty
                              ? 'Select conditions or type to create...'
                              : '${formState.selectedConditionIds.length} Conditions Selected',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: formState.selectedConditionIds.isEmpty ? AppColors.greyText.withValues(alpha: 0.5) : AppColors.inkBlack,
                            fontWeight: formState.selectedConditionIds.isEmpty ? FontWeight.w400 : FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: AppColors.greyText),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 8.h),
            Text(
              'Add specific rules like "No smoking", "No Pets", etc.',
              style: TextStyle(fontSize: 13.sp, color: AppColors.greyText),
            ),
            SizedBox(height: 24.h),
          ],
        );
      },
    );
  }

  void _showConditionsSheet(BuildContext context, List<dynamic> conditionsList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return BlocProvider.value(
              value: context.read<ListingFormCubit>(), // Pass the cubit to modal scope
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Center(
                    child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.dividerGrey, borderRadius: BorderRadius.circular(2.r))),
                  ),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: BlocBuilder<ListingFormCubit, ListingFormState>(
                      builder: (context, formState) {
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: conditionsList.length,
                          itemBuilder: (context, index) {
                            final condition = conditionsList[index];
                            final isSelected = formState.selectedConditionIds.contains(condition.id.toString());

                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                              tileColor: isSelected ? Colors.white : Colors.transparent,
                              title: Text(condition.name, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.inkBlack)),
                              subtitle: Text(condition.description ?? '', style: TextStyle(fontSize: 13.sp, color: AppColors.greyText)),
                              trailing: isSelected ? const Icon(Icons.check, color: AppColors.inkBlack) : null,
                              onTap: () {
                                context.read<ListingFormCubit>().toggleCondition(condition.id.toString());
                              },
                            );
                          },
                        );
                      },
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
}

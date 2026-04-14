import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_form_cubit.dart';

class WizardStep7Pricing extends StatefulWidget {
  const WizardStep7Pricing({super.key});

  @override
  State<WizardStep7Pricing> createState() => _WizardStep7PricingState();
}

class _WizardStep7PricingState extends State<WizardStep7Pricing> {
  late TextEditingController _priceController;
  late TextEditingController _cleaningFeeController;

  @override
  void initState() {
    super.initState();
    final formState = context.read<ListingFormCubit>().state;
    _priceController = TextEditingController(text: formState.pricePerNight == 0 ? '' : formState.pricePerNight.toString());
    _cleaningFeeController = TextEditingController(text: formState.cleaningFee == 0 ? '' : formState.cleaningFee.toString());

    _priceController.addListener(_updateForm);
    _cleaningFeeController.addListener(_updateForm);
  }

  void _updateForm() {
    context.read<ListingFormCubit>().setPricing(
          pricePerNight: double.tryParse(_priceController.text) ?? 0,
          cleaningFee: double.tryParse(_cleaningFeeController.text) ?? 0,
        );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _cleaningFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListingFormCubit, ListingFormState>(
      builder: (context, formState) {
        final double currentPrice = double.tryParse(_priceController.text) ?? 0;
        final bool showPriceError = _priceController.text.isNotEmpty && currentPrice <= 0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set your price',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkBlack,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 32.h),

              // Currency Dropdown styling
              Text('Currency', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.inkBlack)),
              SizedBox(height: 8.h),
              Container(
                width: 140.w,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.dividerGrey),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('EGP (£)', style: TextStyle(fontSize: 15.sp, color: AppColors.inkBlack)),
                    Icon(Icons.unfold_more, color: AppColors.greyText, size: 20.sp),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              _buildPricingField(
                'Price per night',
                _priceController,
                showError: showPriceError,
                errorText: 'Too small, expected number to be > 0',
              ),
              
              _buildPricingField(
                'Cleaning Fee',
                _cleaningFeeController,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPricingField(String title, TextEditingController controller, {bool showError = false, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.inkBlack)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          style: TextStyle(fontSize: 15.sp, color: AppColors.inkBlack),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(fontSize: 15.sp, color: AppColors.greyText.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r), 
              borderSide: BorderSide(color: showError ? AppColors.primaryRed : AppColors.dividerGrey)
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r), 
              borderSide: BorderSide(color: showError ? AppColors.primaryRed : AppColors.dividerGrey)
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r), 
              borderSide: BorderSide(color: showError ? AppColors.primaryRed : AppColors.primaryRed, width: 1.5)
            ),
            contentPadding: EdgeInsets.all(16.w),
          ),
        ),
        if (showError && errorText != null) ...[
          SizedBox(height: 6.h),
          Text(errorText, style: TextStyle(fontSize: 12.sp, color: AppColors.primaryRed)),
        ],
        SizedBox(height: 24.h),
      ],
    );
  }
}

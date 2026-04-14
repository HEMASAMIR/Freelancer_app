import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_form_cubit.dart';

class WizardStep5Details extends StatefulWidget {
  const WizardStep5Details({super.key});

  @override
  State<WizardStep5Details> createState() => _WizardStep5DetailsState();
}

class _WizardStep5DetailsState extends State<WizardStep5Details> {
  late TextEditingController _guestsController;
  late TextEditingController _bedsController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  late TextEditingController _minDurationController;

  @override
  void initState() {
    super.initState();
    final formState = context.read<ListingFormCubit>().state;
    _guestsController = TextEditingController(text: formState.guests.toString());
    _bedsController = TextEditingController(text: formState.beds.toString());
    _bedroomsController = TextEditingController(text: formState.bedrooms.toString());
    _bathroomsController = TextEditingController(text: formState.bathrooms.toString());
    _minDurationController = TextEditingController(text: formState.minDuration.toString());

    _guestsController.addListener(_updateForm);
    _bedsController.addListener(_updateForm);
    _bedroomsController.addListener(_updateForm);
    _bathroomsController.addListener(_updateForm);
    _minDurationController.addListener(_updateForm);
  }

  void _updateForm() {
    context.read<ListingFormCubit>().setDetails(
          guests: int.tryParse(_guestsController.text),
          beds: int.tryParse(_bedsController.text),
          bedrooms: int.tryParse(_bedroomsController.text),
          bathrooms: int.tryParse(_bathroomsController.text),
          minDuration: int.tryParse(_minDurationController.text),
        );
  }

  @override
  void dispose() {
    _guestsController.dispose();
    _bedsController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _minDurationController.dispose();
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
            'Share some basics about your home',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.inkBlack,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          SizedBox(height: 32.h),

          Row(
            children: [
              Expanded(child: _buildNumberField('Guests', _guestsController)),
              SizedBox(width: 16.w),
              Expanded(child: _buildNumberField('Bedrooms', _bedroomsController)),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildNumberField('Beds', _bedsController)),
              SizedBox(width: 16.w),
              Expanded(child: _buildNumberField('Bathrooms', _bathroomsController)),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildNumberField('Min Duration', _minDurationController)),
              SizedBox(width: 16.w),
              const Expanded(child: SizedBox()), // Empty space for alignment
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.inkBlack)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(fontSize: 15.sp, color: AppColors.inkBlack),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.dividerGrey)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.dividerGrey)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.primaryRed, width: 1.5)),
            contentPadding: EdgeInsets.all(16.w),
          ),
        ),
      ],
    );
  }
}

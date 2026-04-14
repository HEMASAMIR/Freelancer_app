import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_form_cubit.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_cubit.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_state.dart';

class WizardStep4Location extends StatefulWidget {
  const WizardStep4Location({super.key});

  @override
  State<WizardStep4Location> createState() => _WizardStep4LocationState();
}

class _WizardStep4LocationState extends State<WizardStep4Location> {
  late TextEditingController _mapLinkController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final formState = context.read<ListingFormCubit>().state;
    _mapLinkController = TextEditingController(text: formState.googleMapsLink);
    _latController = TextEditingController(text: formState.latitude);
    _lngController = TextEditingController(text: formState.longitude);
    _addressController = TextEditingController(text: formState.address);

    _mapLinkController.addListener(_updateForm);
    _latController.addListener(_updateForm);
    _lngController.addListener(_updateForm);
    _addressController.addListener(_updateForm);
  }

  void _updateForm() {
    context.read<ListingFormCubit>().setLocationDetails(
          mapLink: _mapLinkController.text,
          lat: _latController.text,
          lng: _lngController.text,
          address: _addressController.text,
        );
  }

  @override
  void dispose() {
    _mapLinkController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListingWizardCubit, ListingWizardState>(
      builder: (context, wizardState) {
        if (wizardState is! ListingWizardLookupsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Where is your place located?',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkBlack,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 24.h),
              
              // ─── Map Placeholder ───
              Container(
                height: 180.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.dividerGrey,
                  borderRadius: BorderRadius.circular(16.r),
                  image: const DecorationImage(
                    image: NetworkImage('https://i.stack.imgur.com/HILmr.png'), // generic map placeholder
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.location_on, size: 40.sp, color: AppColors.primaryRed),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // ─── Dropdowns ───
              BlocBuilder<ListingFormCubit, ListingFormState>(
                builder: (context, formState) {
                  final countryName = wizardState.countries.where((c) => c.id.toString() == formState.countryId).firstOrNull?.name;
                  final stateName = wizardState.states.where((s) => s.id.toString() == formState.stateId).firstOrNull?.name;
                  final cityName = wizardState.cities.where((c) => c.id.toString() == formState.cityId).firstOrNull?.name;

                  return Column(
                    children: [
                      _buildSelector(
                        title: 'Country',
                        hint: 'Select country...',
                        value: countryName,
                        onTap: () => _showCountrySheet(context, wizardState.countries),
                      ),
                      _buildSelector(
                        title: 'State / Region',
                        hint: 'Select state...',
                        value: stateName,
                        onTap: () {
                          if (formState.countryId.isEmpty) return;
                          _showStateSheet(context, wizardState.states);
                        },
                      ),
                      _buildSelector(
                        title: 'City',
                        hint: 'Select city...',
                        value: cityName,
                        onTap: () {
                          if (formState.stateId.isEmpty) return;
                          _showCitySheet(context, wizardState.cities);
                        },
                      ),
                    ],
                  );
                },
              ),

              // ─── Inputs ───
              _buildInputField(
                title: 'Paste Google Maps Link',
                hint: 'Paste link to auto-fill',
                controller: _mapLinkController,
              ),
              Row(
                children: [
                  Expanded(child: _buildInputField(title: 'Lat', hint: '30.0444', controller: _latController)),
                  SizedBox(width: 16.w),
                  Expanded(child: _buildInputField(title: 'Lng', hint: '31.2357', controller: _lngController)),
                ],
              ),
              _buildInputField(
                title: 'Address',
                hint: 'eg. 123 Main St',
                controller: _addressController,
                maxLines: 4,
              ),
              
              SizedBox(height: 32.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelector({required String title, required String hint, String? value, required VoidCallback onTap}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.inkBlack)),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: onTap,
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
                    value ?? hint,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: value == null ? AppColors.greyText.withValues(alpha: 0.5) : AppColors.inkBlack,
                    ),
                  ),
                  Icon(Icons.unfold_more, color: AppColors.greyText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCountrySheet(BuildContext context, List<dynamic> items) {
    _showSearchSheet(
      context: context,
      items: items,
      hintTitle: 'Search country...',
      onSelect: (id) {
        context.read<ListingFormCubit>().setLocationGeographic(countryId: id.toString(), stateId: '', cityId: '');
        context.read<ListingWizardCubit>().fetchStates(id.toString());
      },
    );
  }

  void _showStateSheet(BuildContext context, List<dynamic> items) {
    _showSearchSheet(
      context: context,
      items: items,
      hintTitle: 'Search state...',
      onSelect: (id) {
        context.read<ListingFormCubit>().setLocationGeographic(stateId: id.toString(), cityId: '');
        context.read<ListingWizardCubit>().fetchCities(id.toString());
      },
    );
  }

  void _showCitySheet(BuildContext context, List<dynamic> items) {
    _showSearchSheet(
      context: context,
      items: items,
      hintTitle: 'Search city...',
      onSelect: (id) {
        context.read<ListingFormCubit>().setLocationGeographic(cityId: id.toString());
      },
    );
  }

  void _showSearchSheet({
    required BuildContext context,
    required List<dynamic> items,
    required String hintTitle,
    required Function(String id) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Column(
              children: [
                SizedBox(height: 16.h),
                Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.dividerGrey, borderRadius: BorderRadius.circular(2.r))),
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: hintTitle,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (ctx, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item.name, style: TextStyle(fontSize: 15.sp, color: AppColors.inkBlack)),
                        onTap: () {
                          onSelect(item.id.toString());
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required String title,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.inkBlack)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(fontSize: 15.sp, color: AppColors.inkBlack),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 15.sp, color: AppColors.greyText.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.dividerGrey)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.dividerGrey)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.primaryRed, width: 1.5)),
            contentPadding: EdgeInsets.all(16.w),
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}

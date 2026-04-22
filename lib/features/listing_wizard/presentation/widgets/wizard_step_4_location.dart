import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/listing_wizard/data/models/wizard_models.dart';
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

  String _mapImageUrl = '';
  static const double _defaultLat = 30.0444;
  static const double _defaultLng = 31.2357;

  @override
  void initState() {
    super.initState();
    final formState = context.read<ListingFormCubit>().state;
    _mapLinkController = TextEditingController(text: formState.googleMapsLink);
    _latController = TextEditingController(text: formState.latitude);
    _lngController = TextEditingController(text: formState.longitude);
    _addressController = TextEditingController(text: formState.address);

    _mapLinkController.addListener(_updateForm);
    _latController.addListener(_onCoordsChanged);
    _lngController.addListener(_onCoordsChanged);
    _addressController.addListener(_updateForm);

    // Build initial map URL
    _updateMapUrl(_defaultLat, _defaultLng);
  }

  void _updateForm() {
    context.read<ListingFormCubit>().setLocationDetails(
          mapLink: _mapLinkController.text,
          lat: _latController.text,
          lng: _lngController.text,
          address: _addressController.text,
        );
  }

  void _onCoordsChanged() {
    _updateForm();
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat != null && lng != null) {
      _updateMapUrl(lat, lng);
    }
  }

  void _updateMapUrl(double lat, double lng) {
    final url =
        'https://staticmap.openstreetmap.de/staticmap.php'
        '?center=$lat,$lng'
        '&zoom=14'
        '&size=600x300'
        '&maptype=mapnik'
        '&markers=$lat,$lng,red-pushpin';
    if (mounted) {
      setState(() {
        _mapImageUrl = url;
      });
    }
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
        final List<dynamic> countriesList = wizardState is ListingWizardLookupsLoaded ? wizardState.countries : [];
        final List<dynamic> statesList = wizardState is ListingWizardLookupsLoaded ? wizardState.states : [];
        final List<dynamic> citiesList = wizardState is ListingWizardLookupsLoaded ? wizardState.cities : [];

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
              
              // ─── Dropdowns ───
              BlocBuilder<ListingFormCubit, ListingFormState>(
                builder: (context, formState) {
                  final countryName = countriesList.where((c) => c.id.toString() == formState.countryId).firstOrNull?.name;
                  final stateName = statesList.where((s) => s.id.toString() == formState.stateId).firstOrNull?.name;
                  final cityName = citiesList.where((c) => c.id.toString() == formState.cityId).firstOrNull?.name;

                  return Column(
                    children: [
                      _buildSelector(
                        title: 'Country',
                        hint: 'Select country...',
                        value: countryName,
                        onTap: () => _showCountrySheet(context, countriesList),
                      ),
                      _buildSelector(
                        title: 'State / Region',
                        hint: 'Select state...',
                        value: stateName,
                        onTap: () {
                          if (formState.countryId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a country first'), backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          if (statesList.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Loading states or no states available'), backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          _showStateSheet(context, statesList);
                        },
                      ),
                      _buildSelector(
                        title: 'City',
                        hint: 'Select city...',
                        value: cityName,
                        onTap: () {
                          if (formState.stateId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a state first'), backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          if (citiesList.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Loading cities or no cities available'), backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          _showCitySheet(context, citiesList);
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

              // ─── Dynamic Map Preview ───
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  height: 180.h,
                  width: double.infinity,
                  color: AppColors.dividerGrey,
                  child: _mapImageUrl.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_outlined, size: 40.sp, color: AppColors.greyText),
                              SizedBox(height: 8.h),
                              Text(
                                'Select a location to preview map',
                                style: TextStyle(fontSize: 13.sp, color: AppColors.greyText),
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              _mapImageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryRed,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image_outlined, size: 36.sp, color: AppColors.greyText),
                                    SizedBox(height: 8.h),
                                    Text('Map preview unavailable', style: TextStyle(fontSize: 12.sp, color: AppColors.greyText)),
                                  ],
                                ),
                              ),
                            ),
                            // Pin overlay at center
                            Align(
                              alignment: Alignment.center,
                              child: Icon(Icons.location_on, size: 40.sp, color: AppColors.primaryRed, shadows: [
                                Shadow(blurRadius: 8, color: Colors.black38),
                              ]),
                            ),
                          ],
                        ),
                ),
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
      onSelect: (item) {
        if (!mounted) return;
        try {
          final country = item as CountryModel;
          debugPrint("📍 Selected Country: ${country.name} (Lat: ${country.latitude}, Lng: ${country.longitude})");
          
          context.read<ListingFormCubit>().setLocationGeographic(countryId: country.id, stateId: '', cityId: '');
          
          if (country.latitude != null) _latController.text = country.latitude!;
          if (country.longitude != null) _lngController.text = country.longitude!;
          
          context.read<ListingWizardCubit>().fetchStates(country.iso2 ?? country.id);
        } catch (e) {
          debugPrint("❌ Error selecting country: $e");
        }
      },
    );
  }

  void _showStateSheet(BuildContext context, List<dynamic> items) {
    _showSearchSheet(
      context: context,
      items: items,
      hintTitle: 'Search state...',
      onSelect: (item) {
        if (!mounted) return;
        try {
          final stateModel = item as StateModel;
          debugPrint("📍 Selected State: ${stateModel.name} (Lat: ${stateModel.latitude}, Lng: ${stateModel.longitude})");
          
          context.read<ListingFormCubit>().setLocationGeographic(stateId: stateModel.id, cityId: '');
          
          if (stateModel.latitude != null) _latController.text = stateModel.latitude!;
          if (stateModel.longitude != null) _lngController.text = stateModel.longitude!;
          
          context.read<ListingWizardCubit>().fetchCities(stateModel.iso2 ?? stateModel.id);
        } catch (e) {
          debugPrint("❌ Error selecting state: $e");
        }
      },
    );
  }

  void _showCitySheet(BuildContext context, List<dynamic> items) {
    _showSearchSheet(
      context: context,
      items: items,
      hintTitle: 'Search city...',
      onSelect: (item) {
        if (!mounted) return;
        try {
          final city = item as CityModel;
          debugPrint("📍 Selected City: ${city.name} (Lat: ${city.latitude}, Lng: ${city.longitude})");
          
          context.read<ListingFormCubit>().setLocationGeographic(cityId: city.id);
          
          if (city.latitude != null) _latController.text = city.latitude!;
          if (city.longitude != null) _lngController.text = city.longitude!;
        } catch (e) {
          debugPrint("❌ Error selecting city: $e");
        }
      },
    );
  }

  void _showSearchSheet({
    required BuildContext context,
    required List<dynamic> items,
    required String hintTitle,
    required Function(dynamic item) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (ctx, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item.name, style: TextStyle(fontSize: 15.sp, color: AppColors.inkBlack)),
                        onTap: () {
                          onSelect(item);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
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

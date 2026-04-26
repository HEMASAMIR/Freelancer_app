import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_cubit.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_state.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_form_cubit.dart';
import 'package:freelancer/features/listing_wizard/presentation/widgets/wizard_step_1_property_type.dart';
import 'package:freelancer/features/listing_wizard/presentation/widgets/wizard_step_2_lifestyles.dart';
import 'package:freelancer/features/listing_wizard/presentation/widgets/wizard_step_3_descriptions.dart';
import 'package:freelancer/features/listing_wizard/presentation/widgets/wizard_step_4_location.dart';
import 'package:freelancer/features/listing_wizard/presentation/widgets/wizard_step_5_details.dart';
import 'package:freelancer/features/listing_wizard/presentation/widgets/wizard_step_6_photos.dart';
import 'package:freelancer/features/listing_wizard/presentation/widgets/wizard_step_7_pricing.dart';
import 'package:freelancer/features/listing_wizard/presentation/widgets/wizard_step_8_publish.dart';
import 'package:freelancer/features/listing_wizard/presentation/view/listing_success_screen.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';

class ListingWizardScreen extends StatefulWidget {
  const ListingWizardScreen({super.key});

  @override
  State<ListingWizardScreen> createState() => _ListingWizardScreenState();
}

class _ListingWizardScreenState extends State<ListingWizardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 8; // Adjust based on final requirements

  final List<String> _stepTitles = [
    'Type',
    'Vibe',
    'Description',
    'Location',
    'Details',
    'Photos',
    'Pricing',
    'Publish',
  ];

  @override
  void initState() {
    super.initState();
    context.read<ListingWizardCubit>().fetchInitialLookups();
    // Identity verification check removed as requested
    // Users can now directly access the 9-step wizard
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  bool _isNextEnabled(ListingFormState formState) {
    switch (_currentPage) {
      case 0:
        return formState.selectedPropertyTypeId.isNotEmpty;
      case 1:
        return formState.selectedLifestyleIds.isNotEmpty;
      case 2:
        return (formState.titleEn.isNotEmpty || formState.titleAr.isNotEmpty) &&
            (formState.descriptionEn.length >= 10 ||
                formState.descriptionAr.length >= 10);
      case 3:
        return formState.countryId.isNotEmpty &&
            formState.stateId.isNotEmpty &&
            formState.cityId.isNotEmpty &&
            formState.latitude.isNotEmpty &&
            formState.address.isNotEmpty;
      case 4:
        return formState.guests > 0 &&
            formState.beds > 0 &&
            formState.bedrooms > 0 &&
            formState.bathrooms > 0 &&
            formState.minDuration > 0;
      case 5:
        return formState.photoPaths.isNotEmpty;
      case 6:
        return formState.pricePerNight > 0;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListingWizardCubit, ListingWizardState>(
      listener: (context, state) {
        if (state is ListingWizardLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) =>
                const Center(child: CircularProgressIndicator()),
          );
        } else if (state is ListingWizardSuccess) {
          // Close the loading dialog if open
          if (Navigator.canPop(context)) Navigator.pop(context);
          // Always go to success — listing saved as draft (is_published: false)
          // Admin will review and approve it
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const ListingSuccessScreen()),
          );
        } else if (state is ListingWizardError) {
          if (Navigator.canPop(context)) Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<ListingFormCubit, ListingFormState>(
        builder: (context, formState) {
          return Scaffold(
            backgroundColor: AppColors.bgColor,
            appBar: _buildAppBar(),
            body: Column(
              children: [
                _buildProgressHeader(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      WizardStep1PropertyType(),
                      WizardStep2Lifestyles(),
                      WizardStep3Descriptions(),
                      WizardStep4Location(),
                      WizardStep5Details(),
                      WizardStep6Photos(),
                      WizardStep7Pricing(),
                      WizardStep8Publish(),
                    ],
                  ),
                ),
                _buildBottomNav(formState),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.inkBlack),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildProgressHeader() {
    final stepNumber = _currentPage + 1;
    final stepTitle = _stepTitles[_currentPage];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $stepNumber of $_totalPages',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryRed,
                ),
              ),
              Text(
                stepTitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryRed,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: stepNumber / _totalPages,
            backgroundColor: AppColors.primaryRed.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
            minHeight: 4.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(ListingFormState formState) {
    final bool isLastStep = _currentPage == 7;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        border: Border(top: BorderSide(color: AppColors.dividerGrey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _prevPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF4EEED),
              foregroundColor: AppColors.inkBlack,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
            ),
            child: Text(
              _currentPage == 0 ? 'Cancel' : 'Back',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Center Indicator (Optional mini badge like in screenshot)
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              'https://flagcdn.com/w80/eg.png',
              height: 20.h,
              width: 28.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.flag_outlined,
                size: 20.r,
                color: AppColors.primaryRed,
              ),
            ),
          ),
          
          ElevatedButton(
            onPressed: () {
              if (!_isValidCurrentPage(formState)) {
                context.read<ListingFormCubit>().setValidationErrorsVisibility(true);
                return;
              }
              context.read<ListingFormCubit>().setValidationErrorsVisibility(false);

              if (isLastStep) {
                _publishListing(formState);
              } else {
                _nextPage();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A0D1D), // Dark burgundy red
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
            ),
            child: Text(
              isLastStep ? 'Publish' : 'Next',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidCurrentPage(ListingFormState state) {
    if (_currentPage == 0) return state.selectedPropertyTypeId.isNotEmpty;
    if (_currentPage == 1) return state.selectedLifestyleIds.isNotEmpty;
    if (_currentPage == 2) {
      return state.titleEn.length >= 5 &&
             state.titleAr.length >= 5 &&
             state.descriptionEn.length >= 10 &&
             state.descriptionAr.length >= 10;
    }
    if (_currentPage == 3) {
      return state.countryId.isNotEmpty && state.stateId.isNotEmpty && state.cityId.isNotEmpty;
    }
    if (_currentPage == 4) return true; // Details are mostly numbers with defaults
    if (_currentPage == 5) return state.photoPaths.isNotEmpty;
    if (_currentPage == 6) return state.pricePerNight > 0;
    if (_currentPage == 7) return true; // Review step
    return false;
  }

  void _publishListing(ListingFormState formState) {
    final authState = context.read<AuthCubit>().state;
    String userId = '';
    
    if (authState is AuthSuccess) {
      userId = authState.user.id;
    } else if (authState is AuthAdminSuccess) {
      userId = authState.user.id;
    }

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: User not authenticated")),
      );
      return;
    }

    final lat = _parseCoordinate(formState.latitude);
    final lng = _parseCoordinate(formState.longitude);

    final listingPayload = <String, dynamic>{
      'user_id': userId,
      'title': formState.titleEn,
      'description': formState.descriptionEn,
      'location': formState.address,
      'google_maps_link': formState.googleMapsLink,
      'country_id': formState.countryId,
      'state_id': formState.stateId,
      'city_id': formState.cityId,
      'property_type_id': formState.selectedPropertyTypeId,
      'price_per_night': formState.pricePerNight,
      'cleaning_fee': formState.cleaningFee,
      'max_guests': formState.guests,
      'bedrooms': formState.bedrooms,
      'beds': formState.beds,
      'bathrooms': formState.bathrooms,
      'min_nights': formState.minDuration,
      'currency': formState.currency,
      'is_published': false, // Needs admin/identity verification
      'translations': {
        'ar': {
          'title': formState.titleAr,
          'description': formState.descriptionAr,
        }
      },
    };

    if (lat != null && lng != null) {
      listingPayload['location_geo'] = 'POINT($lng $lat)';
    }

    context.read<ListingWizardCubit>().createCompleteListing(
      userId: userId,
      listingData: listingPayload,
      photoPaths: formState.photoPaths,
      lifestyleIds: formState.selectedLifestyleIds,
      conditionIds: formState.selectedConditionIds,
    );
  }

  double? _parseCoordinate(String rawValue) {
    if (rawValue.trim().isEmpty) return null;

    final arabicIndicDigits = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    var normalized = rawValue.trim();
    arabicIndicDigits.forEach((k, v) {
      normalized = normalized.replaceAll(k, v);
    });

    normalized = normalized
        .replaceAll('٫', '.')
        .replaceAll('،', '.')
        .replaceAll(',', '.');

    return double.tryParse(normalized);
  }
}

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
        return formState.titleEn.isNotEmpty && 
               formState.descriptionEn.length >= 20 &&
               formState.descriptionAr.length >= 20;
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
           showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
        } else if (state is ListingWizardSuccess) {
           Navigator.pop(context); // pop dialog
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListingSuccessScreen()));
        } else if (state is ListingWizardError) {
           Navigator.pop(context); // pop dialog
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
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
                    children: const [
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
          TextButton(
            onPressed: _prevPage,
            child: Text(
              _currentPage == 0 ? 'Cancel' : 'Back',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.inkBlack,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isNextEnabled(formState)
                ? () {
                    if (isLastStep) {
                      _publishListing(formState);
                    } else {
                      _nextPage();
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              disabledBackgroundColor: AppColors.primaryRed.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
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

  void _publishListing(ListingFormState formState) {
    context.read<ListingWizardCubit>().createCompleteListing(
      listingData: {
        'title_en': formState.titleEn,
        'description_en': formState.descriptionEn,
        'country_id': formState.countryId,
        'state_id': formState.stateId,
        'city_id': formState.cityId,
        'property_type_id': formState.selectedPropertyTypeId,
        'latitude': formState.latitude,
        'longitude': formState.longitude,
        'price_per_night': formState.pricePerNight,
        'guests': formState.guests,
        'bedrooms': formState.bedrooms,
      },
      lifestyles: formState.selectedLifestyleIds.map((id) => {'lifestyle_id': id}).toList(),
      conditions: formState.selectedConditionIds.map((id) => {'condition_id': id}).toList(),
      images: formState.photoPaths.map((path) => {'path': path}).toList(),
    );
  }
}

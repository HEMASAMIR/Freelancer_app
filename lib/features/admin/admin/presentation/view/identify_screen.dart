import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/identity_verification/logic/identity_verification_cubit.dart';
import 'package:freelancer/features/identity_verification/logic/identity_verification_state.dart';
import 'package:freelancer/features/listing_wizard/presentation/view/listing_success_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class IdentityVerificationScreen extends StatefulWidget {
  final bool fromListingWizard;
  
  const IdentityVerificationScreen({
    super.key, 
    this.fromListingWizard = false,
  });

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _idDocument;
  File? _selfie;

  Future<void> _pickImage(bool isId) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isId) {
          _idDocument = File(image.path);
        } else {
          _selfie = File(image.path);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<IdentityVerificationCubit>().checkStatus();
  }

  void _handleSubmit() {
    if (_idDocument == null || _selfie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both ID and Selfie')),
      );
      return;
    }
    context.read<IdentityVerificationCubit>().submitDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IdentityVerificationCubit, IdentityVerificationState>(
      listener: (context, state) {
        if (state is IdentityVerificationSuccess) {
          if (widget.fromListingWizard) {
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ListingSuccessScreen()),
            );
          } else {
            Navigator.pop(context);
          }
        } else if (state is IdentityVerificationError) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is IdentityVerificationPending) {
          return _buildPendingUI();
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundCream,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Identity Verification',
              style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Stepper added here
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: _VerificationStepper(
                    currentStep: (_idDocument != null && _selfie != null) 
                      ? 2 
                      : (_idDocument != null ? 1 : 0),
                  ),
                ),
              ),

              Text(
                'Confirm your identity',
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                'Please provide the following verify documents to verify your identity.',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 32.h),

              // Step 1: ID Document
              _buildUploadSection(
                title: 'Identity Document',
                subtitle: 'Upload a clear photo of your ID',
                file: _idDocument,
                onTap: () => _pickImage(true),
                isComplete: _idDocument != null,
              ),
              
              SizedBox(height: 24.h),

              // Step 2: Selfie
              _buildUploadSection(
                title: 'Selfie Photo',
                subtitle: 'Upload a clear photo of your face',
                file: _selfie,
                onTap: () => _pickImage(false),
                isComplete: _selfie != null,
              ),

              SizedBox(height: 32.h),

              // Info Box
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 20.sp, color: Colors.grey.shade400),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Why do we need this?', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4.h),
                          Text(
                            'Identity verification helps keep our community safe. Your documents are securely stored and are only reviewed by our verification team. This is required before you can book or list properties.',
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),
              
              Builder(
                builder: (context) {
                  final isSubmitting = state is IdentityVerificationSubmitting;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: isSubmitting 
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                SizedBox(width: 12.w),
                                Text('Submitting...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                              ],
                            )
                          : Text('Submit Verification', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget _buildPendingUI() {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.w, top: 16.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF), // Very light blue
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Blue clock icon
                    Icon(
                      Icons.access_time_filled_rounded,
                      size: 64.sp,
                      color: const Color(0xFF2563EB), // Blue
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Verification Pending',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E40AF), // Dark blue
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Your identity verification is being reviewed. You can list once it\'s approved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'This usually takes 1-2 business days. We\'ll notify you when complete.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 2),
            // Footer
            Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Column(
                children: [
                  Text(
                    '© 2026 QuickIn, Inc. · Terms · Sitemap · Privacy',
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.public, size: 14.sp, color: Colors.grey.shade600),
                      SizedBox(width: 4.w),
                      Text(
                        'English (US)  EGP',
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection({
    required String title,
    required String subtitle,
    required File? file,
    required VoidCallback onTap,
    required bool isComplete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_outline, size: 18.sp, color: Colors.grey.shade700),
            SizedBox(width: 8.w),
            Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
            const Spacer(),
            if (isComplete) Container(
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: Icon(Icons.check, size: 12.sp, color: Colors.green),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(subtitle, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500)),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: file != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(file, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: GestureDetector(
                          onTap: () => setState(() => file == _idDocument ? _idDocument = null : _selfie = null),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: Icon(Icons.close, size: 16.sp, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 32.sp, color: Colors.grey.shade400),
                      SizedBox(height: 8.h),
                      Text('Click to upload', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _VerificationStepper extends StatelessWidget {
  final int currentStep;
  const _VerificationStepper({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStep(true), // Always completed or at least started
        _buildLine(currentStep >= 1),
        _buildStep(currentStep >= 1),
        _buildLine(currentStep >= 2),
        _buildStep(currentStep >= 2),
      ],
    );
  }

  Widget _buildStep(bool isCompleted) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFF00C38B) : Colors.grey.shade300,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted ? const Color(0xFF00C38B) : Colors.grey.shade400,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.check,
          size: 16.sp,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLine(bool isCompleted) {
    return Container(
      width: 40.w,
      height: 2.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: isCompleted ? const Color(0xFF00C38B) : Colors.grey.shade300,
    );
  }
}

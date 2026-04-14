import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/account/logic/security_cubit.dart';
import 'package:freelancer/core/utils/animation/custom_snackbar.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _mfaCodeController = TextEditingController();

  void _updatePassword() {
    final password = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      CustomSnackBar.show(context, isError: true, message: 'Please fill both password fields');
      return;
    }
    if (password != confirm) {
      CustomSnackBar.show(context, isError: true, message: 'Passwords do not match');
      return;
    }
    if (password.length < 6) {
      CustomSnackBar.show(context, isError: true, message: 'Password must be at least 6 characters');
      return;
    }

    context.read<SecurityCubit>().updatePassword(password);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _mfaCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SecurityCubit, SecurityState>(
      listener: (context, state) {
        if (state is SecurityError) {
          CustomSnackBar.show(context, isError: true, message: state.message);
        } else if (state is PasswordUpdateSuccess) {
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          CustomSnackBar.show(context, isError: false, message: 'Password updated successfully!');
        } else if (state is MFAVerifiedSuccess) {
          CustomSnackBar.show(context, isError: false, message: '2FA Enabled successfully!');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundCream,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.inkBlack, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Login & Security',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkBlack,
                  letterSpacing: -1.0,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Manage your password and secure your account',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.greyText,
                ),
              ),
              SizedBox(height: 32.h),

              // --- Update Password Card ---
              _buildCardWrapper(
                icon: Icons.lock_outline,
                title: 'Update Password',
                subtitle: 'Ensure your account is using a long, random password to stay secure.',
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _newPasswordController,
                      label: 'New Password',
                      isPassword: true,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm New Password',
                      isPassword: true,
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<SecurityCubit, SecurityState>(
                        builder: (context, state) {
                          final isLoading = state is SecurityLoading;
                          return ElevatedButton(
                            onPressed: isLoading ? null : _updatePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBurgundy,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: 20.h,
                                    width: 20.h,
                                    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    'Update Password',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // --- 2FA Card ---
              BlocBuilder<SecurityCubit, SecurityState>(
                builder: (context, state) {
                  return _buildCardWrapper(
                    icon: Icons.security_outlined,
                    title: 'Two-Factor Authentication (2FA)',
                    subtitle: 'Add an extra layer of security to your account by requiring a code from an authenticator app.',
                    child: _build2FAContent(context, state),
                  );
                },
              ),
              
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardWrapper({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.inkBlack, size: 24.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkBlack,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.greyText,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),
          child,
        ],
      ),
    );
  }

  Widget _build2FAContent(BuildContext context, SecurityState state) {
    if (state is MFAVerifiedSuccess) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Two-factor authentication is enabled for your account.',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state is MFASetupInitiated) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set up Two-Factor Authentication',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            'Scan the QR code with your authenticator app like Google Authenticator or Authy.',
            style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.dividerGrey),
              ),
              child: QrImageView(
                data: state.qrCodeUri,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundCream,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.dividerGrey.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Text('Or enter this code manually:', style: TextStyle(fontSize: 12.sp, color: AppColors.greyText)),
                SizedBox(height: 4.h),
                SelectableText(
                  state.secret,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          _buildTextField(
            controller: _mfaCodeController,
            label: 'Verify Code',
            isPassword: false,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final code = _mfaCodeController.text.trim();
                if (code.isEmpty) {
                  CustomSnackBar.show(context, isError: true, message: 'Please enter the code');
                  return;
                }
                context.read<SecurityCubit>().verifyMFA(
                  factorId: state.factorId,
                  challengeId: '', // Assumes TOTP doesn't immediately need challenge, or you trigger it elsewhere
                  code: code,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBurgundy,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                'Verify',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    final isLoading = state is SecurityLoading;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Two-factor authentication is not enabled for your account yet.',
                style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => context.read<SecurityCubit>().enrollMFA(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBurgundy,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    'Set up 2FA',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.greyText, fontSize: 14.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
          borderSide: BorderSide(color: AppColors.primaryBurgundy, width: 1.5),
        ),
      ),
    );
  }
}

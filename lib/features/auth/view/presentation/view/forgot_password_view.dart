import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:freelancer/core/shared_helper/app_color.dart';
import 'package:freelancer/core/utils/widgets/input_box.dart';
import 'package:freelancer/core/utils/widgets/show_toast.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_state.dart';
import 'package:lottie/lottie.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _otpSent = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _onSendCode(BuildContext context) {
    if (_emailController.text.trim().isEmpty) {
      CustomToast.show(context, 'Please enter your email', ToastState.error);
      return;
    }
    context.read<AuthCubit>().recoverPassword(
      email: _emailController.text.trim(),
    );
  }

  void _onVerifyAndReset(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().verifyRecoveryOTP(
      email: _emailController.text.trim(),
      otp: _otpController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthCubitState>(
      listener: (context, state) {
        if (state is AuthRecoverSuccess) {
          setState(() => _otpSent = true);
          CustomToast.show(
            context,
            "OTP code sent to your email! 📧",
            ToastState.success,
          );
        } else if (state is AuthUpdatePasswordSuccess) {
          CustomToast.show(
            context,
            "Password reset successfully! 🚀",
            ToastState.success,
          );
          Navigator.pop(context); // Go back to Login
        } else if (state is AuthError) {
          CustomToast.show(context, state.message, ToastState.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              GestureDetector(
                onTap: isLoading ? null : () => Navigator.pop(context),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(color: Colors.black.withValues(alpha: 0.30)),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 32.h,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F0E8),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () => Navigator.pop(context),
                                  child: Icon(
                                    Icons.close,
                                    size: 20.sp,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              Text(
                                'Reset Password',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.label,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _otpSent
                                    ? 'Enter the 6-digit code sent to your email'
                                    : 'Enter your email to receive a recovery code',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.sub,
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // Email Field
                              _buildLabel('Email'),
                              SizedBox(height: 5.h),
                              InputBox(
                                hint: 'you@example.com',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) =>
                                    v!.isEmpty ? 'Enter your email' : null,
                              ),
                              SizedBox(height: 12.h),

                              if (_otpSent) ...[
                                _buildLabel('Recovery Code'),
                                SizedBox(height: 5.h),
                                InputBox(
                                  hint: '123456',
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  validator: (v) =>
                                      v!.isEmpty ? 'Enter the code' : null,
                                ),
                                SizedBox(height: 12.h),

                                _buildLabel('New Password'),
                                SizedBox(height: 5.h),
                                InputBox(
                                  hint: '••••••••',
                                  controller: _newPasswordController,
                                  obscure: _obscure,
                                  validator: (v) => v!.length < 6
                                      ? 'Must be at least 6 characters'
                                      : null,
                                  suffix: GestureDetector(
                                    onTap: () =>
                                        setState(() => _obscure = !_obscure),
                                    child: Icon(
                                      _obscure
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 18.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                              ],

                              SizedBox(
                                height: 46.h,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (_otpSent) {
                                            _onVerifyAndReset(context);
                                          } else {
                                            _onSendCode(context);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B2323),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: isLoading
                                      ? Lottie.asset(
                                          'assets/lottie/loading_lottie.json',
                                          width: 40.w,
                                        )
                                      : Text(
                                          _otpSent
                                              ? 'Reset Password'
                                              : 'Send Code',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              if (_otpSent) ...[
                                SizedBox(height: 14.h),
                                Center(
                                  child: GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : () => _onSendCode(context),
                                    child: Text(
                                      'Resend Code',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: const Color(0xFF8B2323),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.label,
      ),
    );
  }
}

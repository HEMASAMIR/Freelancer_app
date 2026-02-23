import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/app_router/app_router.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/color/app_color.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/core/utils/widgets/input_box.dart';
import 'package:freelancer/core/utils/widgets/social_button.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignUp(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signUpWithEmail(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // ✅ روح للـ Home
            Navigator.pop(context);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0E8),
              borderRadius: BorderRadius.circular(14.r),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
            // ✅ الحل - SingleChildScrollView
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── X زر الإغلاق ──
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          size: 18.sp,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // ── Sign up ──
                    Text(
                      'Sign up',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.label,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Create an account to start booking',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.sp, color: AppColors.sub),
                    ),
                    SizedBox(height: 16.h),

                    // ── Google ──
                    SocialButton(
                      icon: Icons.g_mobiledata,
                      label: 'Continue with Google',
                      onTap: () => context.read<AuthCubit>().signInWithGoogle(),
                    ),
                    SizedBox(height: 10.h),

                    // ── Apple ──
                    SocialButton(
                      icon: Icons.apple,
                      label: 'Continue with Apple',
                      onTap: () {},
                    ),
                    SizedBox(height: 12.h),

                    // ── OR ──
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: const Color(0xFFD4CEBC),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.sub,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: const Color(0xFFD4CEBC),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // ── Full name ──
                    Text(
                      'Full name',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.label,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    InputBox(
                      hint: 'John Doe',
                      controller: _nameController,
                      validator: (v) => v!.isEmpty ? 'Enter your name' : null,
                    ),
                    SizedBox(height: 10.h),

                    // ── Email ──
                    Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.label,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    InputBox(
                      hint: 'you@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty ? 'Enter your email' : null,
                    ),
                    SizedBox(height: 10.h),

                    // ── Password ──
                    Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.label,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    InputBox(
                      hint: '••••••••',
                      controller: _passwordController,
                      obscure: _obscure,
                      validator: (v) => v!.length < 6
                          ? 'Password must be at least 6 characters'
                          : null,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 17.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // ── Sign up button ──
                    SizedBox(
                      height: 44.h,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () => _onSignUp(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ed,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: state is AuthLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Text(
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // ── Already have an account ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.sub,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Log in',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.ed,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.ed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

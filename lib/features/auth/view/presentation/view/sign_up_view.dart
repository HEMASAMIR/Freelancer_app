import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/utils/widgets/show_toast.dart';
import 'package:lottie/lottie.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';
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
    return BlocProvider.value(
      value: sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAdminSuccess) {
            CustomToast.show(
              context,
              "Admin account created! 👑",
              ToastState.success,
            );
            context.read<AuthCubit>().navigateAfterLogin(context);
          } else if (state is AuthSuccess) {
            CustomToast.show(context, "Account created! 🚀", ToastState.success);
            context.read<AuthCubit>().navigateAfterLogin(context);
          } else if (state is AuthError) {
            CustomToast.show(context, state.message, ToastState.error);
          }
        },
        builder: (context, state) {
          final cubit = context.read<AuthCubit>();

          return Stack(
            children: [
              // ── Blurred backdrop ──
              GestureDetector(
                onTap: cubit.isLoading ? null : () => Navigator.pop(context),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.30),
                  ),
                ),
              ),

              // ── Sign up card — centered ──
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 32.h,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
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
                            // Close button
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: cubit.isLoading
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
                              'Sign up',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.label,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Create an account to start booking',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.sub,
                              ),
                            ),
                            SizedBox(height: 20.h),

                            SocialButton(
                              icon: Icons.g_mobiledata,
                              label: 'Continue with Google',
                              onTap: cubit.isLoading
                                  ? null
                                  : () => cubit.signInWithGoogle(),
                            ),
                            SizedBox(height: 10.h),
                            SocialButton(
                              icon: Icons.apple,
                              label: 'Continue with Apple',
                              onTap: cubit.isLoading ? null : () {},
                            ),
                            SizedBox(height: 15.h),

                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: Color(0xFFD4CEBC)),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: AppColors.sub,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: Color(0xFFD4CEBC)),
                                ),
                              ],
                            ),
                            SizedBox(height: 15.h),

                            _buildLabel('Full name'),
                            SizedBox(height: 4.h),
                            InputBox(
                              hint: 'John Doe',
                              controller: _nameController,
                              validator: (v) =>
                                  v!.isEmpty ? 'Enter your name' : null,
                            ),
                            SizedBox(height: 12.h),

                            _buildLabel('Email'),
                            SizedBox(height: 4.h),
                            InputBox(
                              hint: 'you@example.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) =>
                                  v!.isEmpty ? 'Enter your email' : null,
                            ),
                            SizedBox(height: 12.h),

                            _buildLabel('Password'),
                            SizedBox(height: 4.h),
                            InputBox(
                              hint: '••••••••',
                              controller: _passwordController,
                              obscure: _obscure,
                              validator: (v) =>
                                  v!.length < 6 ? 'Min 6 characters' : null,
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

                            SizedBox(
                              height: 46.h,
                              child: ElevatedButton(
                                onPressed: cubit.isLoading
                                    ? null
                                    : () => _onSignUp(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B2323),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: cubit.isLoading
                                    ? Lottie.asset(
                                        'assets/lottie/loading_lottie.json',
                                        width: 40.w,
                                      )
                                    : Text(
                                        'Sign up',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 14.h),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.sub,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: cubit.isLoading
                                      ? null
                                      : () => Navigator.pushReplacementNamed(
                                            context,
                                            AppRoutes.login,
                                          ),
                                  child: Text(
                                    'Log in',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xFF8B2323),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
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

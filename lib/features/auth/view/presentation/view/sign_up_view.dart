import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:freelancer/core/color/app_color.dart';
import 'package:freelancer/core/utils/widgets/input_box.dart';
import 'package:freelancer/core/utils/widgets/social_button.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:freelancer/features/auth/view/widget/custom_lable.dart';
import 'package:freelancer/features/auth/view/widget/have_an_account.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── زر الإغلاق ──
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, size: 20.sp, color: Colors.black54),
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
            SizedBox(height: 8.h),
            Text(
              'Create an account to start booking',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: AppColors.sub),
            ),
            SizedBox(height: 24.h),

            // ── أزرار السوشيال ──
            const SocialButton(
              icon: Icons.g_mobiledata,
              label: 'Continue with Google',
            ),
            SizedBox(height: 12.h),
            const SocialButton(icon: Icons.apple, label: 'Continue with Apple'),
            SizedBox(height: 20.h),

            // ── Divider ──
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFD4CEBC))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Text(
                    'OR',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.sub),
                  ),
                ),
                const Expanded(child: Divider(color: Color(0xFFD4CEBC))),
              ],
            ),
            SizedBox(height: 20.h),

            // ── المدخلات (تعديل استدعاء CustomLabel) ──
            const CustomLabel(text: 'Full name'),
            SizedBox(height: 8.h),
            InputBox(hint: 'John Doe', controller: _nameController),
            SizedBox(height: 16.h),

            const CustomLabel(text: 'Email'),
            SizedBox(height: 8.h),
            InputBox(
              hint: 'you@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.h),

            const CustomLabel(text: 'Password'),
            SizedBox(height: 8.h),
            InputBox(
              hint: '••••••••',
              controller: _passwordController,
              obscure: _obscure,
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18.sp,
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // ── منطق الـ Bloc (الزرار) ──
            BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthSuccess) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Welcome! Account Created'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: (state is AuthLoading)
                        ? null
                        : () => _handleSignUp(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B1A1A),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xFF8B1A1A,
                      ).withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: (state is AuthLoading)
                        ? Lottie.asset(
                            'assets/lottie/loading_lottie.json',
                            height: 40.h,
                          )
                        : Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                );
              },
            ),

            SizedBox(height: 16.h),

            // ── الويدجت السفلية ──
            HaveAccountWidget(
              text1: 'Already have an account? ',
              text2: 'Log in',
              onTap: () {
                Navigator.pop(context);
              },
            ),

            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _handleSignUp(BuildContext context) {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      context.read<AuthCubit>().signUpUser(
        name: name,
        email: email,
        password: password,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields (Password min 6 chars)'),
        ),
      );
    }
  }
}

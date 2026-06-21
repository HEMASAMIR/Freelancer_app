import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';
import 'package:freelancer/core/utils/widgets/show_toast.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_state.dart';

/// A passwordless, two-step Magic Link login dialog:
///
///  Step 1 ─ User enters their email address.
///            Cubit calls [sendMagicLink] → emits [AuthMagicLinkSent].
///
///  Step 2 ─ User enters the 8-digit OTP received in the email.
///            Cubit calls [verifyMagicLinkOTP] → emits [AuthSuccess] /
///            [AuthAdminSuccess] / [AuthError].
///
/// NOTE: Supabase is configured to send an 8-digit OTP.
class MagicLinkView extends StatefulWidget {
  const MagicLinkView({super.key});

  @override
  State<MagicLinkView> createState() => _MagicLinkViewState();
}

class _MagicLinkViewState extends State<MagicLinkView>
    with SingleTickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────
  final _emailKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  // Eight individual OTP digit controllers — Supabase OTP length is 8
  static const int _otpLength = 8;
  final List<TextEditingController> _otpCtrl = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocus = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  // ── State ─────────────────────────────────────────────────────────────────
  bool _onOtpStep = false;
  String _sentEmail = '';

  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _slideCtrl;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _emailCtrl.dispose();
    for (final c in _otpCtrl) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String get _otp => _otpCtrl.map((c) => c.text).join();

  void _onSendMagicLink() {
    if (!_emailKey.currentState!.validate()) return;
    context.read<AuthCubit>().sendMagicLink(email: _emailCtrl.text.trim());
  }

  void _onVerifyOtp() {
    final code = _otp;
    if (code.length < _otpLength) {
      CustomToast.show(
        context,
        'Enter the full $_otpLength-digit code',
        ToastState.error,
      );
      return;
    }
    context.read<AuthCubit>().verifyMagicLinkOTP(email: _sentEmail, otp: code);
  }

  /// Handles typing in an OTP box — advances / retreats focus automatically.
  void _onOtpDigitChanged(int index, String value) {
    // If the user pasted a full OTP (e.g. from clipboard), distribute digits
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength && i < digits.length; i++) {
        _otpCtrl[i].text = digits[i];
      }
      // Move focus to the last filled box (or beyond if complete)
      final target = (digits.length - 1).clamp(0, _otpLength - 1);
      _otpFocus[target].requestFocus();
      if (digits.length >= _otpLength) _onVerifyOtp();
      return;
    }

    if (value.isNotEmpty && index < _otpLength - 1) {
      _otpFocus[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocus[index - 1].requestFocus();
    }
  }

  void _transitionToOtp(String email) {
    setState(() {
      _sentEmail = email;
      _onOtpStep = true;
    });
    _slideCtrl.forward();
    Future.delayed(const Duration(milliseconds: 420), () {
      if (mounted) _otpFocus[0].requestFocus();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthCubitState>(
      listener: (context, state) {
        if (state is AuthMagicLinkSent) {
          _transitionToOtp(state.email);
        } else if (state is AuthAdminSuccess || state is AuthSuccess) {
          // Close the dialog first so the parent LoginView listener can handle 
          // the redirect and success toasts cleanly without duplicate navigation.
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        } else if (state is AuthError) {
          CustomToast.show(context, state.message, ToastState.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthMagicLinkLoading;

        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              // ── Blurred backdrop ──────────────────────────────────────────
              GestureDetector(
                onTap: isLoading ? null : () => Navigator.pop(context),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.black.withValues(alpha: 0.35)),
                ),
              ),

              // ── Card ─────────────────────────────────────────────────────
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 32.h,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F0E8),
                          borderRadius: BorderRadius.circular(22.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _onOtpStep
                            ? _OtpStep(
                                email: _sentEmail,
                                controllers: _otpCtrl,
                                focusNodes: _otpFocus,
                                isLoading: isLoading,
                                otpLength: _otpLength,
                                onDigitChanged: _onOtpDigitChanged,
                                onVerify: _onVerifyOtp,
                                onResend: () {
                                  for (final c in _otpCtrl) {
                                    c.clear();
                                  }
                                  context.read<AuthCubit>().sendMagicLink(
                                    email: _sentEmail,
                                  );
                                },
                                onBack: () {
                                  setState(() => _onOtpStep = false);
                                  _slideCtrl.reverse();
                                },
                              )
                            : _EmailStep(
                                formKey: _emailKey,
                                controller: _emailCtrl,
                                isLoading: isLoading,
                                onSend: _onSendMagicLink,
                                onClose: () => Navigator.pop(context),
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
}

// ─────────────────────────────────────────────────────────────────────────────
//  Step 1 – Email input
// ─────────────────────────────────────────────────────────────────────────────

class _EmailStep extends StatelessWidget {
  const _EmailStep({
    required this.formKey,
    required this.controller,
    required this.isLoading,
    required this.onSend,
    required this.onClose,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Close
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: isLoading ? null : onClose,
              child: Icon(Icons.close, size: 20.sp, color: Colors.black45),
            ),
          ),
          SizedBox(height: 4.h),

          // Magic wand icon
          Center(
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B2323), Color(0xFF5B0F16)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B2323).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 28.sp,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          Text(
            'Sign in with Magic Link',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.label,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "Enter your email and we'll send you a one-time\ncode — no password needed.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.sub,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),

          Text(
            'Email address',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.label,
            ),
          ),
          SizedBox(height: 6.h),

          TextFormField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => isLoading ? null : onSend(),
            decoration: InputDecoration(
              hintText: 'you@example.com',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 13.sp),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(
                Icons.email_outlined,
                size: 18.sp,
                color: const Color(0xFF8B2323),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: Color(0xFFD4CEBC)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: Color(0xFFD4CEBC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(
                  color: Color(0xFF8B2323),
                  width: 1.5,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your email';
              final emailRx = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
              if (!emailRx.hasMatch(v.trim())) return 'Enter a valid email';
              return null;
            },
          ),
          SizedBox(height: 20.h),

          SizedBox(
            height: 48.h,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B2323),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(
                  0xFF8B2323,
                ).withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Send Magic Link',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 14.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 12.sp,
                color: AppColors.sub,
              ),
              SizedBox(width: 4.w),
              Text(
                'Secure, passwordless login powered by Supabase',
                style: TextStyle(fontSize: 10.sp, color: AppColors.sub),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Step 2 – OTP input (6 digits)
// ─────────────────────────────────────────────────────────────────────────────

class _OtpStep extends StatelessWidget {
  const _OtpStep({
    required this.email,
    required this.controllers,
    required this.focusNodes,
    required this.isLoading,
    required this.otpLength,
    required this.onDigitChanged,
    required this.onVerify,
    required this.onResend,
    required this.onBack,
  });

  final String email;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isLoading;
  final int otpLength;
  final void Function(int index, String value) onDigitChanged;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Back
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: isLoading ? null : onBack,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 14.sp,
                  color: Colors.black45,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Email icon
        Center(
          child: Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B2323), Color(0xFF5B0F16)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B2323).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.mark_email_read_rounded,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
        ),
        SizedBox(height: 16.h),

        Text(
          'Check your inbox',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.label,
          ),
        ),
        SizedBox(height: 6.h),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.sub,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: "We sent an 8-digit code to\n"),
              TextSpan(
                text: email,
                style: const TextStyle(
                  color: Color(0xFF8B2323),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),

        // ── OTP boxes (6 digits — Supabase default) ──────────────────────────
        Row(
          children: List.generate(
            otpLength,
            (i) => Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: _OtpBox(
                  controller: controllers[i],
                  focusNode: focusNodes[i],
                  isLoading: isLoading,
                  onChanged: (v) => onDigitChanged(i, v),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // Verify button
        SizedBox(
          height: 48.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : onVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B2323),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(
                0xFF8B2323,
              ).withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user_rounded, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Verify & Sign In',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        SizedBox(height: 14.h),

        // Resend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive it? ",
              style: TextStyle(fontSize: 12.sp, color: AppColors.sub),
            ),
            GestureDetector(
              onTap: isLoading ? null : onResend,
              child: Text(
                'Resend',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF8B2323),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Single OTP digit box
// ─────────────────────────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    // AspectRatio(0.85) → each box is slightly taller than wide.
    // Flexible in the parent Row ensures all 6 boxes share available width
    // equally without ever overflowing the card.
    return AspectRatio(
      aspectRatio: 0.85,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: !isLoading,
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.label,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: Color(0xFFD4CEBC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: Color(0xFFD4CEBC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: Color(0xFF8B2323), width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

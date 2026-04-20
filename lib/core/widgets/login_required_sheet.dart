import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/features/auth/view/presentation/view/login_view.dart';
import 'package:freelancer/features/auth/view/presentation/view/sign_up_view.dart';

/// فتح Login كـ overlay فوق الشاشة الحالية مع blur effect
Future<void> showLoginOverlay(BuildContext context) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'login_overlay',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (ctx, anim1, anim2) => BlocProvider.value(
      value: sl<AuthCubit>(),
      child: const LoginView(),
    ),
    transitionBuilder: (ctx, anim1, anim2, child) {
      return FadeTransition(opacity: anim1, child: child);
    },
  );
}

/// فتح Sign Up كـ overlay فوق الشاشة الحالية مع blur effect
Future<void> showSignUpOverlay(BuildContext context) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'signup_overlay',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (ctx, anim1, anim2) => BlocProvider.value(
      value: sl<AuthCubit>(),
      child: const SignUpView(),
    ),
    transitionBuilder: (ctx, anim1, anim2, child) {
      return FadeTransition(opacity: anim1, child: child);
    },
  );
}

/// Shows a beautiful animated login dialog on top of the current screen.
/// Customise [title], [subtitle] and [icon] to match the context.
Future<bool> showLoginRequiredSheet(
  BuildContext context, {
  String title = 'Save your favorites',
  String subtitle = 'Log in to save properties to your wishlists\nand access them anytime.',
  IconData icon = Icons.favorite_rounded,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'login_required',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (ctx, anim1, anim2) => _LoginRequiredSheet(
      title: title,
      subtitle: subtitle,
      icon: icon,
    ),
    transitionBuilder: (ctx, anim1, anim2, child) {
      return FadeTransition(opacity: anim1, child: child);
    },
  );
  return result ?? false;
}

class _LoginRequiredSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _LoginRequiredSheet({
    this.title = 'Save your favorites',
    this.subtitle = 'Log in to save properties to your wishlists\nand access them anytime.',
    this.icon = Icons.favorite_rounded,
  });

  @override
  State<_LoginRequiredSheet> createState() => _LoginRequiredSheetState();
}

class _LoginRequiredSheetState extends State<_LoginRequiredSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred + dimmed background — tapping it dismisses the dialog
        GestureDetector(
          onTap: () => Navigator.pop(context, false),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              color: Colors.black.withValues(alpha: 0.30),
            ),
          ),
        ),

        // Centered card
        Center(
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated heart icon
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryRed.withValues(alpha: 0.12),
                                AppColors.primaryBurgundy.withValues(alpha: 0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            widget.icon,
                            color: AppColors.primaryRed,
                            size: 34,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.sub.withValues(alpha: 0.85),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Log in button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                            showLoginOverlay(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Sign up button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                            showSignUpOverlay(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: AppColors.dividerGrey.withValues(alpha: 0.6)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Skip
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Not now',
                          style: TextStyle(
                            color: AppColors.sub.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
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
  }
}

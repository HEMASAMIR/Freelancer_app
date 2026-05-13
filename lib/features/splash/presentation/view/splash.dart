import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/cache_helper/shared_pref.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────
  late AnimationController _logoController;
  late AnimationController _glowController;
  late AnimationController _textController;
  late AnimationController _dotsController;
  late AnimationController _fadeOutController;

  // ── Animations ───────────────────────────────────────────────────────────
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _glowRadius;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _fadeOut;

  static const _burgundy = Color(0xFF5B0F16);
  static const _cream = Color(0xFFF7F3F0);

  @override
  void initState() {
    super.initState();
    // Hide system UI for true full-screen feel
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _setupAnimations();

    final bool isSplashSeen = CacheHelper.getData(key: 'splash_seen') ?? false;

    if (isSplashSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _skipSplash();
      });
    } else {
      CacheHelper.setData(key: 'splash_seen', value: true);
      _startSequence();
    }
  }

  void _skipSplash() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAdminSuccess) {
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  void _setupAnimations() {
    // 1. Logo: scale + fade in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // 2. Glow pulse
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowRadius = Tween<double>(begin: 20, end: 60).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // 3. Text slide up + fade in
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    // 4. Loading dots
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 5. Fade out whole screen before navigate
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startSequence() async {
    // Step 1: Logo pops in
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _logoController.forward();

    // Step 2: Glow pulses
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _glowController.repeat(reverse: true);

    // Step 3: Text slides up
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _textController.forward();

    // Step 4: Dots animate
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _dotsController.repeat();

    // Step 5: Fade out & navigate after 3s total
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    _glowController.stop();
    _dotsController.stop();

    // بدء الـ fade-out وفي نفس الوقت عمل navigate — بدون انتظار الـ fade ينتهي
    // عشان متظهرش شاشة سوداء
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final authState = context.read<AuthCubit>().state;
    _fadeOutController.forward(); // مش await — بنبدأها بس

    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    if (authState is AuthAdminSuccess) {
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _textController.dispose();
    _dotsController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // نلف الكل في Container كريم عشان لما opacity تبقى 0
    // الخلفية تبقى كريم مش سودا
    return ColoredBox(
      color: _cream,
      child: FadeTransition(
        opacity: _fadeOut,
        child: Scaffold(
          backgroundColor: _cream,
          body: SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Background decorative circles ────────────────────────────
                Positioned(
                  top: -size.width * 0.3,
                  right: -size.width * 0.3,
                  child: Container(
                    width: size.width * 0.8,
                    height: size.width * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _burgundy.withOpacity(0.04),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -size.width * 0.4,
                  left: -size.width * 0.3,
                  child: Container(
                    width: size.width * 0.9,
                    height: size.width * 0.9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _burgundy.withOpacity(0.04),
                    ),
                  ),
                ),

                // ── Center content ───────────────────────────────────────────
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with glow
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _logoController,
                        _glowController,
                      ]),
                      builder: (context, _) {
                        return Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: _burgundy.withOpacity(0.25),
                                    blurRadius: _glowRadius.value,
                                    spreadRadius: _glowRadius.value * 0.2,
                                  ),
                                  const BoxShadow(
                                    color: Colors.white,
                                    blurRadius: 0,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(28),
                              child: Image.asset(
                                'assets/images/logo_512x512.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // App name + tagline
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFF8B1A1A),
                                  Color(0xFF5B0F16),
                                  Color(0xFF3D0A10),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: const Text(
                                'QuickIn',
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Find It. Book It. Live It.',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: _burgundy.withOpacity(0.55),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Animated loading dots
                    FadeTransition(
                      opacity: _textOpacity,
                      child: _AnimatedDots(controller: _dotsController),
                    ),
                  ],
                ),

                // ── Bottom brand line ─────────────────────────────────────────
                Positioned(
                  bottom: 48,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Text(
                      '© 2026 QuickIn, Inc.',
                      style: TextStyle(
                        fontSize: 12,
                        color: _burgundy.withOpacity(0.3),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated 3-dot loader ────────────────────────────────────────────────────
class _AnimatedDots extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Each dot has a phase offset
            final phase = (controller.value - i * 0.2).clamp(0.0, 1.0);
            final bounce = Curves.easeInOut.transform(
              (phase < 0.5 ? phase * 2 : (1 - phase) * 2).clamp(0.0, 1.0),
            );
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.translate(
                offset: Offset(0, -8 * bounce),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFF5B0F16,
                    ).withOpacity(0.3 + 0.7 * bounce),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

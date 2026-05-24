import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_state.dart';
import 'package:freelancer/features/notifications/data/services/host_foreground_service.dart';
import 'package:freelancer/features/notifications/logic/host_notification_cubit.dart';
import 'package:freelancer/core/utils/widgets/elegant_toast.dart';

/// Wraps the app tree and automatically:
/// 1. Starts the Android Foreground Service (Supabase Realtime in background)
///    → fires OS push notifications even when the app is fully killed.
/// 2. Starts the in-app Realtime listener → populates the Notifications page.
///
/// Both start on login and stop on logout.
class AuthAwareNotificationWrapper extends StatefulWidget {
  final Widget child;
  const AuthAwareNotificationWrapper({super.key, required this.child});

  @override
  State<AuthAwareNotificationWrapper> createState() => _AuthAwareNotificationWrapperState();
}

class _AuthAwareNotificationWrapperState extends State<AuthAwareNotificationWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startIfLoggedIn();
    });
  }

  void _startIfLoggedIn() async {
    if (!mounted) return;
    final authCubit = context.read<AuthCubit>();
    final state = authCubit.state;
    if (state is AuthSuccess || state is AuthAdminSuccess) {
      final userId = state is AuthSuccess
          ? state.user.id
          : (state as AuthAdminSuccess).user.id;

      await HostForegroundService.instance.startForHost(userId);
      await HostForegroundService.instance.requestBatteryOptimizationExemption();

      if (mounted) {
        sl<HostNotificationCubit>().startForHost(userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<HostNotificationCubit>(),
      child: BlocListener<AuthCubit, AuthCubitState>(
        listener: (context, state) async {
          if (state is AuthSuccess || state is AuthAdminSuccess) {
            final userId = state is AuthSuccess
                ? state.user.id
                : (state as AuthAdminSuccess).user.id;

            // ── 1. Start OS-level foreground service (survives app kill) ──
            await HostForegroundService.instance.startForHost(userId);

            // Ask for battery exemption so Android doesn't throttle us
            await HostForegroundService.instance
                .requestBatteryOptimizationExemption();

            // ── 2. Start in-app listener (populates Notifications page) ───
            if (context.mounted) {
              context.read<HostNotificationCubit>().startForHost(userId);
            }
          } else if (state is AuthSignedOut) {
            // ── Stop everything on logout ──────────────────────────────────
            await HostForegroundService.instance.stop();
            if (context.mounted) {
              context.read<HostNotificationCubit>().stop();
            }
          }
        },
        child: BlocListener<HostNotificationCubit, HostNotificationState>(
          listener: (context, notifState) {
            if (notifState is HostNewNotificationReceived) {
              ElegantToast.show(
                context,
                '🎉 Great news! ${notifState.notification.guestName} wants to book!',
                icon: Icons.notifications_active_rounded,
              );
            }
          },
          child: widget.child,
        ),
      ),
    );
  }
}

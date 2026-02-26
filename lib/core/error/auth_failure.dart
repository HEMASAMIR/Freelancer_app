import 'package:freelancer/core/error/failures_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

AuthFailure mapAuthException(AuthException e) {
  final msg = e.message.toLowerCase();

  // ✅ أمان — رسالة موحدة لأي غلط في بيانات الدخول
  if (msg.contains('invalid login credentials') ||
      msg.contains('user not found') ||
      msg.contains('invalid email') ||
      msg.contains('wrong password')) {
    return const WrongPasswordFailure();
  }

  if (msg.contains('already registered')) {
    return const EmailAlreadyInUseFailure();
  }

  if (msg.contains('invalid format')) {
    return const InvalidEmailFailure();
  }

  if (msg.contains('weak password') || msg.contains('should be at least')) {
    return const WeakPasswordFailure();
  }

  if (msg.contains('email not confirmed')) {
    return const EmailNotConfirmedFailure();
  }

  if (msg.contains('too many requests') || msg.contains('rate limit')) {
    return const TooManyRequestsFailure();
  }

  if (msg.contains('session') || msg.contains('jwt') || msg.contains('token')) {
    return const SessionExpiredFailure();
  }

  if (msg.contains('network') ||
      msg.contains('connection') ||
      msg.contains('socket') ||
      msg.contains('timeout')) {
    return const NetworkFailure();
  }

  if (msg.contains('server') || msg.contains('500') || msg.contains('503')) {
    return const ServerFailure();
  }

  return UnknownFailure(e.message);
}

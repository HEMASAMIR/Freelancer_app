abstract class AuthFailure {
  final String message;
  const AuthFailure(this.message);
}

// ─────────────────────────────────────────────
//  Email & Password
// ─────────────────────────────────────────────

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure() : super('البريد الإلكتروني غير صحيح');
}

class WrongPasswordFailure extends AuthFailure {
  // ✅ رسالة عامة للأمان — مش بنفرق بين إيميل أو باسورد
  const WrongPasswordFailure()
    : super('البريد الإلكتروني أو كلمة المرور غير صحيحة');
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure() : super('البريد الإلكتروني مستخدم بالفعل');
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure()
    : super('البريد الإلكتروني أو كلمة المرور غير صحيحة');
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure()
    : super('كلمة المرور ضعيفة — استخدم 8 أحرف على الأقل');
}

class EmailNotConfirmedFailure extends AuthFailure {
  const EmailNotConfirmedFailure() : super('يرجى تأكيد بريدك الإلكتروني أولاً');
}

class TooManyRequestsFailure extends AuthFailure {
  const TooManyRequestsFailure()
    : super('محاولات كتير — انتظر قليلاً وحاول مرة أخرى');
}

class SessionExpiredFailure extends AuthFailure {
  const SessionExpiredFailure() : super('انتهت الجلسة — سجّل دخولك مرة أخرى');
}

// ─────────────────────────────────────────────
//  Google
// ─────────────────────────────────────────────

class GoogleSignInFailure extends AuthFailure {
  const GoogleSignInFailure() : super('فشل تسجيل الدخول بـ Google');
}

class GoogleSignInCancelledFailure extends AuthFailure {
  const GoogleSignInCancelledFailure() : super('تم إلغاء تسجيل الدخول');
}

class GoogleTokenFailure extends AuthFailure {
  const GoogleTokenFailure()
    : super('فشل الحصول على بيانات Google — حاول مرة أخرى');
}

// ─────────────────────────────────────────────
//  Network & Server
// ─────────────────────────────────────────────

class NetworkFailure extends AuthFailure {
  const NetworkFailure([String? msg])
    : super(msg ?? 'تحقق من اتصالك بالإنترنت');
}

class ServerFailure extends AuthFailure {
  const ServerFailure() : super('خطأ في الخادم — حاول مرة أخرى لاحقاً');
}

// ─────────────────────────────────────────────
//  Unknown
// ─────────────────────────────────────────────

class UnknownFailure extends AuthFailure {
  const UnknownFailure([String msg = 'حدث خطأ غير متوقع']) : super(msg);
}

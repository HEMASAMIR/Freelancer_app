// lib/features/auth/data/models/auth_failure.dart

abstract class AuthFailure {
  final String message;
  const AuthFailure(this.message);
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure() : super("البريد الإلكتروني غير صحيح");
}

class WrongPasswordFailure extends AuthFailure {
  const WrongPasswordFailure() : super("كلمة المرور غير صحيحة");
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure() : super("البريد الإلكتروني مستخدم بالفعل");
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure() : super("المستخدم غير موجود");
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure() : super("تحقق من اتصالك بالإنترنت");
}

class GoogleSignInFailure extends AuthFailure {
  const GoogleSignInFailure() : super("فشل تسجيل الدخول بـ Google");
}

class UnknownFailure extends AuthFailure {
  const UnknownFailure(String msg) : super(msg);
}

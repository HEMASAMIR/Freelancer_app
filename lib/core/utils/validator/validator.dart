class AppValidators {
  AppValidators._();

  // ✅ اسم
  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your name';
    if (v.trim().length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  // ✅ إيميل
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your email';
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  // ✅ باسورد
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Enter your password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // ✅ تأكيد الباسورد
  static String? Function(String?) confirmPassword(String password) {
    return (String? v) {
      if (v == null || v.isEmpty) return 'Confirm your password';
      if (v != password) return 'Passwords do not match';
      return null;
    };
  }
}

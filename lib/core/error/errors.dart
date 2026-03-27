import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String? message])
    : super(message ?? 'خطأ في السيرفر، حاول مجدداً');
}

class NetworkFailure extends Failure {
  const NetworkFailure([String? message])
    : super(message ?? 'لا يوجد اتصال بالإنترنت');
}

// الكلاس اللي ناقص عندك:
class UnknownFailure extends Failure {
  const UnknownFailure([String? message])
    : super(message ?? 'حدث خطأ غير متوقع');
}

class CacheFailure extends Failure {
  const CacheFailure([String? message])
    : super(message ?? 'خطأ في حفظ البيانات محلياً');
}

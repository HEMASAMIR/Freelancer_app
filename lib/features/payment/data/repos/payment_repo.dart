import 'dart:io';
import 'package:dartz/dartz.dart';

abstract class PaymentRepository {
  Future<Either<String, String>> uploadReceipt({
    required String bookingId,
    required File receiptFile,
  });
}

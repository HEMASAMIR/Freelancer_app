import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/payment_repo.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository repository;

  PaymentCubit(this.repository) : super(PaymentInitial());

  Future<void> uploadReceipt(String bookingId, File receiptFile) async {
    emit(PaymentLoading());
    final result = await repository.uploadReceipt(
      bookingId: bookingId,
      receiptFile: receiptFile,
    );

    result.fold(
      (error) => emit(PaymentError(error)),
      (url) => emit(PaymentSuccess(url)),
    );
  }
}

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'payment_repo.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final SupabaseClient supabase;

  PaymentRepositoryImpl({required this.supabase});

  @override
  Future<Either<String, String>> uploadReceipt({
    required String bookingId,
    required File receiptFile,
  }) async {
    try {
      final fileName = '$bookingId-receipt.jpg';
      
      // Upload using Supabase Storage API which maps directly to the /storage/v1/object/receipts/... endpoint
      await supabase.storage.from('receipts').upload(
        fileName,
        receiptFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      // Get the public URL for the uploaded receipt
      final String publicUrl = supabase.storage.from('receipts').getPublicUrl(fileName);
      
      return Right(publicUrl);
      
    } on StorageException catch (e) {
      debugPrint("❌ Storage Error uploading receipt: ${e.message}");
      return Left(e.message);
    } catch (e) {
      debugPrint("❌ Unexpected Error uploading receipt: $e");
      return Left("خطأ غير متوقع: ${e.toString()}");
    }
  }
}

import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:freelancer/core/costant/constant.dart'; // تأكد أن SupabaseKeys داخل هذا الملف
import '../search_model/listing_model.dart';
import '../search_model/search_params_model.dart';
import 'search_repo.dart';

class SearchRepositoryImpl implements SearchRepository {
  final Dio dio;

  SearchRepositoryImpl({required this.dio});

  @override
  Future<Either<String, List<ListingModel>>> searchListings(
    SearchParamsModel params,
  ) async {
    final result = await _fetchListings({});

    return result.fold((error) => Left(error), (listings) {
      print("Total items received from RPC: ${listings.length}");
      final filteredList = _filterLocally(listings, params);
      print("Items after local filter: ${filteredList.length}");
      return Right(filteredList);
    });
  }

  @override
  Future<Either<String, ListingModel>> getListingDetails(String id) async {
    try {
      final response = await dio.get(
        SupabaseKeys.listingsRest,
        queryParameters: {
          'select': '*,listing_images(*)', // Join لجلب الصور مع بيانات العقار
          'id': 'eq.$id',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        if (data.isNotEmpty) {
          // استخدام ListingModel.fromJson اللي عملناه عشان يحول الـ Nested JSON (Images)
          return Right(ListingModel.fromJson(data.first));
        } else {
          return const Left("عذراً، لم يتم العثور على هذا العقار.");
        }
      }
      return const Left("فشل الاتصال بالسيرفر، حاول مرة أخرى.");
    } on DioException catch (e) {
      // التعامل مع أخطاء Dio بشكل احترافي
      return Left(
        e.response?.data?['message'] ?? e.message ?? "حدث خطأ في الشبكة",
      );
    } catch (e) {
      return Left("خطأ غير متوقع: ${e.toString()}");
    }
  }

  // --- دالة داخلية للتعامل مع الـ RPC الخاص بـ Supabase ---
  Future<Either<String, List<ListingModel>>> _fetchListings(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await dio.post(SupabaseKeys.searchRpc, data: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        return Right(data.map((e) => ListingModel.fromJson(e)).toList());
      }
      return const Left("فشل في جلب البيانات من السيرفر");
    } on DioException catch (e) {
      return Left(
        e.response?.data?['message'] ?? e.message ?? "خطأ في الاتصال",
      );
    } catch (e) {
      return Left("خطأ غير متوقع: ${e.toString()}");
    }
  }

  List<ListingModel> _filterLocally(
    List<ListingModel> listings,
    SearchParamsModel params,
  ) {
    return listings.where((l) {
      final searchKey = (params.location ?? '').trim().toLowerCase();

      bool matches = true;

      if (searchKey.isNotEmpty) {
        final title = (l.title ?? '').toLowerCase();
        final city = (l.city ?? '').toLowerCase();
        final country = (l.country ?? '').toLowerCase();
        final locationString = (l.location ?? '').toLowerCase();
        final state = (l.state ?? '').toLowerCase();

        final fullData = "$title $city $country $locationString $state";
        matches = fullData.contains(searchKey);
      }

      // 2. فلترة بناءً على عدد الضيوف (Max Guests)
      if (params.guests != null && params.guests! > 0) {
        if ((l.maxGuests ?? 0) < params.guests!) {
          matches = false;
        }
      }

      return matches;
    }).toList();
  }
}

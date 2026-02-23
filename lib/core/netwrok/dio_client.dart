import 'package:dio/dio.dart';
import 'package:freelancer/core/costant/constant.dart';

class ApiServices {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: SupabaseKeys.supabaseUrl,
      headers: {
        "apiKey": SupabaseKeys.supabaseAnonKey,
        "Authorization": "Bearer ${SupabaseKeys.supabaseAnonKey}",
      },
    ),
  );

  Future<Response> getData(String path) async {
    return await _dio.get(path);
  }

  Future<Response> postData(String path, Map<String, dynamic> data) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> patchData(String path, Map<String, dynamic> data) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> deleteData(String path) async {
    return await _dio.delete(path);
  }
}

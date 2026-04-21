import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freelancer/core/constant/constant.dart';

class AuthInterceptor extends Interceptor {
  final SharedPreferences sharedPreferences;
  final Dio baseDio;

  AuthInterceptor({required this.sharedPreferences, required this.baseDio});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Always attach anonKey to apikey header
    options.headers['apikey'] = SupabaseKeys.supabaseAnonKey;

    // 1️⃣ Try live session from Supabase client (always fresh / auto-refreshed)
    String? accessToken = Supabase.instance.client.auth.currentSession?.accessToken;

    // 2️⃣ Fallback to SharedPreferences (for startup before Supabase is ready)
    accessToken ??= sharedPreferences.getString('supabase_access_token');

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    } else {
      // Public / anonymous request
      options.headers['Authorization'] = 'Bearer ${SupabaseKeys.supabaseAnonKey}';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If request is unauthorized, attempt a refresh
    if (err.response?.statusCode == 401) {
      final refreshToken = sharedPreferences.getString('supabase_refresh_token');
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Attempt to refresh the token
          final response = await baseDio.post(
            '${SupabaseKeys.authBaseUrl}token?grant_type=refresh_token',
            data: {'refresh_token': refreshToken},
          );
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            final newAccessToken = response.data['access_token'];
            final newRefreshToken = response.data['refresh_token'];
            
            // Save new tokens
            await sharedPreferences.setString('supabase_access_token', newAccessToken);
            if (newRefreshToken != null) {
              await sharedPreferences.setString('supabase_refresh_token', newRefreshToken);
            }

            // Retry the original request
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';
            
            final retryResponse = await baseDio.fetch(opts);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // If refresh fails, clear token to force re-login
          await sharedPreferences.remove('supabase_access_token');
          await sharedPreferences.remove('supabase_refresh_token');
          await sharedPreferences.remove('supabase_user');
        }
      }
    }
    return handler.next(err);
  }
}

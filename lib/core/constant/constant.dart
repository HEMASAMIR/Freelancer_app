import 'package:flutter/material.dart';

class SupabaseKeys {
  SupabaseKeys._();

  static const String supabaseUrl = 'https://xpvrgdpsvffmttlwwfuo.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_aCMcsxno9Z3X5O3ktGQ4VQ_IPqpp53z';

  static const String restBaseUrl = '$supabaseUrl/rest/v1/';

  static const String searchRpc = 'rpc/search_listings';
  static const String listingsRest = 'listings';
  static const String wishlists = 'wishlists';
  static const String wishlistItems = 'wishlist_items';
  static const String bookingsRest = 'bookings';
  static const String profilesRest = 'profiles';
  static const String commissionRatesRest = 'commission_rates';
  static const String checkAvailabilityRpc = 'rpc/check_listing_availability';
  static const String hostBalanceRpc = 'rpc/get_host_balance';
}

class AppColors {
  AppColors._();

  static const Color primaryBurgundy = Color(0xFF5B0F16);
  static const Color backgroundCream = Color(0xFFF6F1E6);
  static const Color cardWhite = Colors.white;
  static const Color greyText = Color(0xFF717171);
  static const Color dividerGrey = Color(0xFFDDDDDD);
  static const Color inkBlack = Color(0xFF222222);
  static const Color selectedBg = Color(0xFFF5ECEC);
  
  // Aliases for compatibility with legacy code
  static const Color sub = greyText;
  static const Color grey = greyText;
  static const Color ink = inkBlack;
  static const Color primaryRed = primaryBurgundy;
  static const Color bgColor = backgroundCream;
  static const Color white = cardWhite;

  // Icon colors for Admin Dashboard
  static const Color iconGreen = Color(0xFF4CAF50);
  static const Color iconBlue = Color(0xFF2196F3);
  static const Color iconRed = Color(0xFFF44336);
  static const Color iconGrey = Color(0xFF9E9E9E);
}

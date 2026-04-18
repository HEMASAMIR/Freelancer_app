import 'package:flutter/material.dart';

class SupabaseKeys {
  SupabaseKeys._();

  static const String supabaseUrl = 'https://xpvrgdpsvffmttlwwfuo.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_aCMcsxno9Z3X5O3ktGQ4VQ_IPqpp53z';

  static const String restBaseUrl = '$supabaseUrl/rest/v1/';
  static const String adminApiBaseUrl = '$supabaseUrl/api/admin/';
  static const String authBaseUrl = '$supabaseUrl/auth/v1/';


  static const String searchRpc = 'rpc/search_listings';
  static const String listingsRest = 'listings';
  static const String wishlists = 'wishlists';
  static const String wishlistItems = 'wishlist_items';
  static const String bookingsRest = 'bookings';
  static const String profilesRest = 'profiles';
  static const String commissionRatesRest = 'commission_rates';
  static const String checkAvailabilityRpc = 'rpc/check_listing_availability';
  static const String hostBalanceRpc = 'rpc/get_host_balance';

  // Listing Wizard endpoints
  static const String propertyTypes = 'property_types';
  static const String lifestyleCategories = 'lifestyle_categories';
  static const String listingConditions = 'listing_conditions';
  static const String countries = 'countries';
  static const String states = 'states';
  static const String cities = 'cities';
  static const String listingImagesRest = 'listing_images';
  static const String listingLifestylesRest = 'listing_lifestyles';
  static const String listingConditionAssignmentsRest = 'listing_condition_assignments';

  // Host Management endpoints
  static const String userBalanceRpc = 'rpc/get_user_balance';
  static const String listingAvailabilityRest = 'listing_availability';
  static const String reviewsRest = 'reviews';

  // Admin specialized endpoints
  static const String adminListingsStatus = 'listings/status';
  static const String adminPayoutsProcess = 'payouts/process';

  // Amenities endpoints
  static const String amenitiesRest = 'amenities';
  static const String amenityCategoriesRest = 'amenity_categories';
  static const String listingAmenitiesRest = 'listing_amenities';

  // Custom conditions (pending approval)
  static const String customConditionsRest = 'custom_listing_conditions';

  // Wallet
  static const String withdrawalRequestsRest = 'withdrawal_requests';
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

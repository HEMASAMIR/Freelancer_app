import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../search_model/listing_model.dart';
import '../search_model/search_params_model.dart';
import 'search_repo.dart';

/// Uses the Supabase Flutter client directly — handles anonymous access
/// automatically without needing a valid JWT. Works for guests (not logged in)
/// AND for logged-in users.
class SearchRepositoryImpl implements SearchRepository {
  final SupabaseClient supabase;

  SearchRepositoryImpl({required this.supabase});

  static const Duration _timeout = Duration(seconds: 30);

  // ── Search listings — Direct query (fast) with RPC fallback ─────────────

  @override
  Future<Either<String, List<ListingModel>>> searchListings(
    SearchParamsModel params,
  ) async {
    try {
      debugPrint('🔍 [SearchRepo] searching listings directly...');

      // Build a direct query — include joins for location names
      var query = supabase
          .from('listings')
          .select('*, listing_images(*), city:cities(name), country:countries(name)');

      // Apply best_offer filter at DB level if requested
      if (params.bestOffer == true) {
        query = query.eq('is_best_offer', true);
      }

      // Apply guest count filter at DB level
      if (params.guests != null && params.guests! > 0) {
        query = query.gte('max_guests', params.guests!);
      }

      // Apply price filters at DB level
      if (params.priceMin != null) {
        query = query.gte('price_per_night', params.priceMin!);
      }
      if (params.priceMax != null) {
        query = query.lte('price_per_night', params.priceMax!);
      }

      // Apply limit at the final call (limit returns PostgrestTransformBuilder)
      final dynamic result = await query.limit(params.limit).timeout(_timeout);

      final List<dynamic> data = result as List<dynamic>? ?? [];
      debugPrint('✅ [SearchRepo] direct query got ${data.length} listings');

      final listings = data.map((e) => ListingModel.fromJson(e)).toList();
      // Apply any remaining local filters (e.g. text search on location/title)
      final filtered = _filterLocally(listings, params);
      return Right(filtered);
    } on TimeoutException {
      debugPrint('⏱️ [SearchRepo] direct query timed out, falling back to RPC...');
      return _searchViaRpc(params);
    } catch (e) {
      debugPrint('❌ [SearchRepo] direct query error: $e — falling back to RPC...');
      return _searchViaRpc(params);
    }
  }

  // ── RPC fallback ─────────────────────────────────────────────────────────

  Future<Either<String, List<ListingModel>>> _searchViaRpc(
    SearchParamsModel params,
  ) async {
    try {
      final body = params.toRequestBody();
      debugPrint('🔁 [SearchRepo] calling rpc/search_listings: $body');

      final dynamic result = await supabase
          .rpc('search_listings', params: body)
          .timeout(_timeout);

      final List<dynamic> data = result as List<dynamic>? ?? [];
      debugPrint('✅ [SearchRepo] RPC got ${data.length} listings');

      final listings = data.map((e) => ListingModel.fromJson(e)).toList();
      final filtered = _filterLocally(listings, params);
      return Right(filtered);
    } on TimeoutException {
      return const Left('التحميل أخذ وقتاً أطول من المتوقع. حاول مجدداً.');
    } catch (e) {
      debugPrint('❌ [SearchRepo] RPC error: $e');
      return Left('خطأ في تحميل البيانات: ${e.toString()}');
    }
  }

  // ── Get listing details ──────────────────────────────────────────────────

  @override
  Future<Either<String, ListingModel>> getListingDetails(String id) async {
    try {
      debugPrint('ℹ️ [SearchRepo] fetching details for ID: $id');

      final data = await supabase
          .from('listings')
          .select('*, listing_images(*), city:cities(name), country:countries(name)')
          .eq('id', id)
          .maybeSingle()
          .timeout(_timeout);

      if (data == null) {
        return const Left('عذراً، لم يتم العثور على هذا العقار.');
      }
      return Right(ListingModel.fromJson(data));
    } on TimeoutException {
      return const Left('انتهت مهلة الطلب. تأكد من الاتصال وحاول مرة أخرى.');
    } catch (e) {
      debugPrint('❌ [SearchRepo] error: $e');
      return Left('خطأ غير متوقع: ${e.toString()}');
    }
  }

  // ── Local filter (same as before) ───────────────────────────────────────

  List<ListingModel> _filterLocally(
    List<ListingModel> listings,
    SearchParamsModel params,
  ) {
    return listings.where((l) {
      final searchKey = (params.location ?? '').trim().toLowerCase();
      bool matches = true;

      if (searchKey.isNotEmpty && searchKey != 'best offers') {
        final fullData = [
          l.title ?? '',
          l.city ?? '',
          l.country ?? '',
          l.location ?? '',
          l.state ?? '',
        ].join(' ').toLowerCase();
        matches = fullData.contains(searchKey);
      }

      if (params.guests != null && params.guests! > 0) {
        if ((l.maxGuests ?? 0) < params.guests!) matches = false;
      }

      return matches;
    }).toList();
  }
}

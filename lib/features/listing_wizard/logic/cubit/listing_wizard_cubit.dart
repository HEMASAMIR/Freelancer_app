import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/listing_wizard_repo.dart';
import 'listing_wizard_state.dart';

class ListingWizardCubit extends Cubit<ListingWizardState> {
  final ListingWizardRepository _repository;

  ListingWizardCubit(this._repository) : super(ListingWizardInitial());

  void _emitIfOpen(ListingWizardState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  // 1-3 & 4a. Fetch Initial Lookups (silently — wizard opens immediately)
  Future<void> fetchInitialLookups() async {
    _emitIfOpen(
      ListingWizardLookupsLoading(),
    ); // lightweight, NOT the full-screen loading

    final typesResult = await _repository.getPropertyTypes();
    final lifestylesResult = await _repository.getLifestyleCategories();
    final conditionsResult = await _repository.getListingConditions();
    final countriesResult = await _repository.getCountries();

    // Use dartz fold to handle results
    typesResult.fold((error) => _emitIfOpen(ListingWizardError(error)), (
      types,
    ) {
      lifestylesResult.fold((error) => _emitIfOpen(ListingWizardError(error)), (
        lifestyles,
      ) {
        conditionsResult.fold(
          (error) => _emitIfOpen(ListingWizardError(error)),
          (conditions) {
            countriesResult.fold(
              (error) => _emitIfOpen(ListingWizardError(error)),
              (countries) {
                _emitIfOpen(
                  ListingWizardLookupsLoaded(
                    propertyTypes: types,
                    lifestyleCategories: lifestyles,
                    listingConditions: conditions,
                    countries: countries,
                  ),
                );
              },
            );
          },
        );
      });
    });
  }

  // 4b. Fetch States
  Future<void> fetchStates(String countryIso2) async {
    try {
      final result = await _repository.getStates(countryIso2: countryIso2);
      result.fold(
        (error) {
          // Log error but don't emit ListingWizardError(error)
          // as it wipes the whole lookup state and crashes/pops the wizard.
          print("Geographic Lookup Error (States): $error");
        },
        (states) {
          if (!isClosed && state is ListingWizardLookupsLoaded) {
            _emitIfOpen(
              (state as ListingWizardLookupsLoaded).copyWith(
                states: states,
                cities: [],
              ),
            ); // clear cities on new state
          }
        },
      );
    } on DioException catch (e) {
      debugPrint("❌ Dio Error fetching states: ${e.message}");
    } catch (e, stack) {
      debugPrint("❌ CRITICAL Unexpected Error fetching states: $e");
      debugPrint(stack.toString());
    }
  }

  // 4c. Fetch Cities
  Future<void> fetchCities(String stateIso2) async {
    try {
      final result = await _repository.getCities(stateIso2: stateIso2);
      result.fold(
        (error) {
          print("Geographic Lookup Error (Cities): $error");
        },
        (cities) {
          if (!isClosed && state is ListingWizardLookupsLoaded) {
            _emitIfOpen(
              (state as ListingWizardLookupsLoaded).copyWith(cities: cities),
            );
          }
        },
      );
    } catch (e) {
      print("Unhandled Exception in fetchCities: $e");
    }
  }

  // 5. Upload Photo
  Future<void> uploadPhoto(String userId, File imageFile) async {
    _emitIfOpen(ListingWizardLoading());
    final result = await _repository.uploadListingPhoto(
      userId: userId,
      imageFile: imageFile,
    );
    result.fold(
      (error) => _emitIfOpen(ListingWizardError(error)),
      (url) => _emitIfOpen(ListingWizardImageUploaded(url)),
    );
  }

  // 6-9. Complete Listing Process (Orchestrated Flow)
  Future<void> createCompleteListing({
    required Map<String, dynamic> listingData,
    required String userId,
    required List<String> photoPaths,
    required List<String> lifestyleIds,
    required List<String> conditionIds,
  }) async {
    _emitIfOpen(ListingWizardLoading());

    // 6. Create Primary Listing
    final primaryResult = await _repository.createPrimaryListing(listingData);

    await primaryResult.fold(
      (error) async {
        _emitIfOpen(ListingWizardError(error));
      },
      (newListing) async {
        try {
          final listingId = newListing.id.toString();

          // 7. Upload Photos & Prepare Image Links
          final List<Map<String, dynamic>> imageLinks = [];
          for (final path in photoPaths) {
            final uploadResult = await _repository.uploadListingPhoto(
              userId: userId,
              imageFile: File(path),
            );

            uploadResult.fold(
              (error) => debugPrint("Failed to upload image $path: $error"),
              (url) => imageLinks.add({'listing_id': listingId, 'url': url}),
            );
          }

          // Execute bulk links in parallel for better performance
          final futures = <Future>[];

          if (imageLinks.isNotEmpty) {
            futures.add(_repository.bulkLinkImages(imageLinks));
          }

          if (lifestyleIds.isNotEmpty) {
            final lifestylePayload = lifestyleIds
                .map((id) => {'listing_id': listingId, 'lifestyle_id': id})
                .toList();
            futures.add(_repository.bulkLinkLifestyleTags(lifestylePayload));
          }

          if (conditionIds.isNotEmpty) {
            final conditionPayload = conditionIds
                .map((id) => {'listing_id': listingId, 'condition_id': id})
                .toList();
            futures.add(_repository.bulkLinkConditions(conditionPayload));
          }

          if (futures.isNotEmpty) {
            await Future.wait(futures);
          }

          _emitIfOpen(ListingWizardSuccess(newListing));
        } catch (e) {
          _emitIfOpen(
            ListingWizardError(
              "An error occurred during bulk linking: ${e.toString()}",
            ),
          );
        }
      },
    );
  }
}

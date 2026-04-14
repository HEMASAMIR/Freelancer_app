import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/listing_wizard_repo.dart';
import 'listing_wizard_state.dart';

class ListingWizardCubit extends Cubit<ListingWizardState> {
  final ListingWizardRepository _repository;

  ListingWizardCubit(this._repository) : super(ListingWizardInitial());

  // 1-3 & 4a. Fetch Initial Lookups
  Future<void> fetchInitialLookups() async {
    emit(ListingWizardLoading());
    
    final typesResult = await _repository.getPropertyTypes();
    final lifestylesResult = await _repository.getLifestyleCategories();
    final conditionsResult = await _repository.getListingConditions();
    final countriesResult = await _repository.getCountries();

    // Use dartz fold to handle results
    typesResult.fold(
      (error) => emit(ListingWizardError(error)),
      (types) {
        lifestylesResult.fold(
          (error) => emit(ListingWizardError(error)),
          (lifestyles) {
            conditionsResult.fold(
              (error) => emit(ListingWizardError(error)),
              (conditions) {
                countriesResult.fold(
                  (error) => emit(ListingWizardError(error)),
                  (countries) {
                    emit(ListingWizardLookupsLoaded(
                      propertyTypes: types,
                      lifestyleCategories: lifestyles,
                      listingConditions: conditions,
                      countries: countries,
                    ));
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // 4b. Fetch States
  Future<void> fetchStates(String countryId) async {
    final result = await _repository.getStates(countryId: countryId);
    result.fold(
      (error) => emit(ListingWizardError(error)),
      (states) {
        if (state is ListingWizardLookupsLoaded) {
           emit((state as ListingWizardLookupsLoaded).copyWith(states: states, cities: [])); // clear cities on new state
        }
      },
    );
  }

  // 4c. Fetch Cities
  Future<void> fetchCities(String stateId) async {
    final result = await _repository.getCities(stateId: stateId);
    result.fold(
      (error) => emit(ListingWizardError(error)),
      (cities) {
        if (state is ListingWizardLookupsLoaded) {
           emit((state as ListingWizardLookupsLoaded).copyWith(cities: cities));
        }
      },
    );
  }

  // 5. Upload Photo
  Future<void> uploadPhoto(String userId, File imageFile) async {
    emit(ListingWizardLoading());
    final result = await _repository.uploadListingPhoto(userId: userId, imageFile: imageFile);
    result.fold(
      (error) => emit(ListingWizardError(error)),
      (url) => emit(ListingWizardImageUploaded(url)),
    );
  }

  // 6-9. Complete Listing Process (Simplified example of orchestration)
  Future<void> createCompleteListing({
    required Map<String, dynamic> listingData,
    List<Map<String, dynamic>>? images,
    List<Map<String, dynamic>>? lifestyles,
    List<Map<String, dynamic>>? conditions,
  }) async {
    emit(ListingWizardLoading());
    
    final result = await _repository.createPrimaryListing(listingData);
    
    result.fold(
      (error) => emit(ListingWizardError(error)),
      (newListing) async {
        // Parallel bulk inserts if data provided
        if (images != null) await _repository.bulkLinkImages(images);
        if (lifestyles != null) await _repository.bulkLinkLifestyleTags(lifestyles);
        if (conditions != null) await _repository.bulkLinkConditions(conditions);
        
        emit(ListingWizardSuccess(newListing));
      },
    );
  }
}

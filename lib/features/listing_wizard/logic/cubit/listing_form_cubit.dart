import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:freelancer/features/listing_wizard/data/models/wizard_models.dart';

class ListingFormState extends Equatable {
  final String selectedPropertyTypeId;
  final List<String> selectedLifestyleIds;
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;
  final List<String> selectedConditionIds;

  // Step 4: Geographic Location
  final String countryId;
  final String stateId;
  final String cityId;
  final String googleMapsLink;
  final String latitude;
  final String longitude;
  final String address;

  // Step 5: Details
  final int guests;
  final int beds;
  final int bedrooms;
  final int bathrooms;
  final int minDuration;

  // Step 6: Photos
  final List<String> photoPaths;

  // Step 7: Pricing
  final String currency;
  final double pricePerNight;
  final double cleaningFee;

  // Validation
  final bool showValidationErrors;

  const ListingFormState({
    this.selectedPropertyTypeId = '',
    this.selectedLifestyleIds = const [],
    this.titleEn = '',
    this.titleAr = '',
    this.descriptionEn = '',
    this.descriptionAr = '',
    this.selectedConditionIds = const [],
    this.countryId = '',
    this.stateId = '',
    this.cityId = '',
    this.googleMapsLink = '',
    this.latitude = '',
    this.longitude = '',
    this.address = '',
    this.guests = 1,
    this.beds = 1,
    this.bedrooms = 1,
    this.bathrooms = 1,
    this.minDuration = 1,
    this.photoPaths = const [],
    this.currency = 'EGP',
    this.pricePerNight = 0.0,
    this.cleaningFee = 0.0,
    this.showValidationErrors = false,
  });

  ListingFormState copyWith({
    String? selectedPropertyTypeId,
    List<String>? selectedLifestyleIds,
    String? titleEn,
    String? titleAr,
    String? descriptionEn,
    String? descriptionAr,
    List<String>? selectedConditionIds,
    String? countryId,
    String? stateId,
    String? cityId,
    String? googleMapsLink,
    String? latitude,
    String? longitude,
    String? address,
    int? guests,
    int? beds,
    int? bedrooms,
    int? bathrooms,
    int? minDuration,
    List<String>? photoPaths,
    String? currency,
    double? pricePerNight,
    double? cleaningFee,
    bool? showValidationErrors,
  }) {
    return ListingFormState(
      selectedPropertyTypeId: selectedPropertyTypeId ?? this.selectedPropertyTypeId,
      selectedLifestyleIds: selectedLifestyleIds ?? this.selectedLifestyleIds,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      selectedConditionIds: selectedConditionIds ?? this.selectedConditionIds,
      countryId: countryId ?? this.countryId,
      stateId: stateId ?? this.stateId,
      cityId: cityId ?? this.cityId,
      googleMapsLink: googleMapsLink ?? this.googleMapsLink,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      guests: guests ?? this.guests,
      beds: beds ?? this.beds,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      minDuration: minDuration ?? this.minDuration,
      photoPaths: photoPaths ?? this.photoPaths,
      currency: currency ?? this.currency,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      cleaningFee: cleaningFee ?? this.cleaningFee,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
    );
  }

  @override
  List<Object?> get props => [
        selectedPropertyTypeId,
        selectedLifestyleIds,
        titleEn,
        titleAr,
        descriptionEn,
        descriptionAr,
        selectedConditionIds,
        countryId,
        stateId,
        cityId,
        googleMapsLink,
        latitude,
        longitude,
        address,
        guests,
        beds,
        bedrooms,
        bathrooms,
        minDuration,
        photoPaths,
        currency,
        pricePerNight,
        cleaningFee,
        showValidationErrors,
      ];
}

class ListingFormCubit extends Cubit<ListingFormState> {
  ListingFormCubit() : super(const ListingFormState());

  void setValidationErrorsVisibility(bool show) {
    emit(state.copyWith(showValidationErrors: show));
  }

  void setPropertyType(String typeId) {
    emit(state.copyWith(selectedPropertyTypeId: typeId));
  }

  void toggleLifestyle(String categoryId) {
    final current = List<String>.from(state.selectedLifestyleIds);
    if (current.contains(categoryId)) {
      current.remove(categoryId);
    } else {
      if (current.length < 2) {
        current.add(categoryId);
      }
    }
    emit(state.copyWith(selectedLifestyleIds: current));
  }

  void setTitles({required String en, required String ar}) {
    emit(state.copyWith(titleEn: en, titleAr: ar));
  }

  void setDescriptions({required String en, required String ar}) {
    emit(state.copyWith(descriptionEn: en, descriptionAr: ar));
  }

  void toggleCondition(String conditionId) {
    final current = List<String>.from(state.selectedConditionIds);
    if (current.contains(conditionId)) {
      current.remove(conditionId);
    } else {
      current.add(conditionId);
    }
    emit(state.copyWith(selectedConditionIds: current));
  }

  void setLocationGeographic({String? countryId, String? stateId, String? cityId}) {
    emit(state.copyWith(
      countryId: countryId ?? state.countryId,
      stateId: stateId ?? state.stateId,
      cityId: cityId ?? state.cityId,
    ));
  }

  void setLocationDetails({String? mapLink, String? lat, String? lng, String? address}) {
    emit(state.copyWith(
      googleMapsLink: mapLink ?? state.googleMapsLink,
      latitude: lat ?? state.latitude,
      longitude: lng ?? state.longitude,
      address: address ?? state.address,
    ));
  }

  void addPhotos(List<String> paths) {
    emit(state.copyWith(photoPaths: [...state.photoPaths, ...paths]));
  }

  void removePhoto(String path) {
    final current = List<String>.from(state.photoPaths);
    current.remove(path);
    emit(state.copyWith(photoPaths: current));
  }

  void setDetails({int? guests, int? beds, int? bedrooms, int? bathrooms, int? minDuration}) {
    emit(state.copyWith(
      guests: guests ?? state.guests,
      beds: beds ?? state.beds,
      bedrooms: bedrooms ?? state.bedrooms,
      bathrooms: bathrooms ?? state.bathrooms,
      minDuration: minDuration ?? state.minDuration,
    ));
  }

  void setPricing({String? currency, double? pricePerNight, double? cleaningFee}) {
    emit(state.copyWith(
      currency: currency ?? state.currency,
      pricePerNight: pricePerNight ?? state.pricePerNight,
      cleaningFee: cleaningFee ?? state.cleaningFee,
    ));
  }
}

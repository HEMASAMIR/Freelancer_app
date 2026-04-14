import 'package:equatable/equatable.dart';
import '../../data/models/wizard_models.dart';
import '../../../../features/search/data/search_model/listing_model.dart';

abstract class ListingWizardState extends Equatable {
  const ListingWizardState();

  @override
  List<Object?> get props => [];
}

class ListingWizardInitial extends ListingWizardState {}

class ListingWizardLoading extends ListingWizardState {}

class ListingWizardLookupsLoaded extends ListingWizardState {
  final List<PropertyTypeModel> propertyTypes;
  final List<LifestyleCategoryModel> lifestyleCategories;
  final List<ListingConditionModel> listingConditions;
  final List<CountryModel> countries;

  const ListingWizardLookupsLoaded({
    required this.propertyTypes,
    required this.lifestyleCategories,
    required this.listingConditions,
    required this.countries,
  });

  @override
  List<Object?> get props => [propertyTypes, lifestyleCategories, listingConditions, countries];
}

class ListingWizardLocationsLoaded extends ListingWizardState {
  final List<StateModel>? states;
  final List<CityModel>? cities;

  const ListingWizardLocationsLoaded({this.states, this.cities});

  @override
  List<Object?> get props => [states, cities];
}

class ListingWizardImageUploaded extends ListingWizardState {
  final String imageUrl;
  const ListingWizardImageUploaded(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}

class ListingWizardSuccess extends ListingWizardState {
  final ListingModel listing;
  const ListingWizardSuccess(this.listing);

  @override
  List<Object?> get props => [listing];
}

class ListingWizardError extends ListingWizardState {
  final String message;
  const ListingWizardError(this.message);

  @override
  List<Object?> get props => [message];
}

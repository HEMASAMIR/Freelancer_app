class PropertyTypeModel {
  final int id;
  final String name;

  PropertyTypeModel({required this.id, required this.name});

  factory PropertyTypeModel.fromJson(Map<String, dynamic> json) => PropertyTypeModel(
        id: json['id'],
        name: json['name'] ?? '',
      );
}

class LifestyleCategoryModel {
  final int id;
  final String name;
  final String? iconUrl;

  LifestyleCategoryModel({required this.id, required this.name, this.iconUrl});

  factory LifestyleCategoryModel.fromJson(Map<String, dynamic> json) => LifestyleCategoryModel(
        id: json['id'],
        name: json['name'] ?? '',
        iconUrl: json['icon_url'],
      );
}

class ListingConditionModel {
  final int id;
  final String name;
  final String? description;

  ListingConditionModel({required this.id, required this.name, this.description});

  factory ListingConditionModel.fromJson(Map<String, dynamic> json) => ListingConditionModel(
        id: json['id'],
        name: json['name'] ?? '',
        description: json['description'],
      );
}

class CountryModel {
  final int id;
  final String name;
  final String? iso2;
  final String? emoji;

  CountryModel({required this.id, required this.name, this.iso2, this.emoji});

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        id: json['id'],
        name: json['name'] ?? '',
        iso2: json['iso2'],
        emoji: json['emoji'],
      );
}

class StateModel {
  final int id;
  final String name;
  final String? iso2;

  StateModel({required this.id, required this.name, this.iso2});

  factory StateModel.fromJson(Map<String, dynamic> json) => StateModel(
        id: json['id'],
        name: json['name'] ?? '',
        iso2: json['iso2'],
      );
}

class CityModel {
  final int id;
  final String name;

  CityModel({required this.id, required this.name});

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        id: json['id'],
        name: json['name'] ?? '',
      );
}

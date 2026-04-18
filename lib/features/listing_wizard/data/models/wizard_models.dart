class PropertyTypeModel {
  final String id;
  final String name;

  PropertyTypeModel({required this.id, required this.name});

  factory PropertyTypeModel.fromJson(Map<String, dynamic> json) => PropertyTypeModel(
        id: json['id'].toString(),
        name: json['name'] ?? '',
      );
}

class LifestyleCategoryModel {
  final String id;
  final String name;
  final String? iconUrl;

  LifestyleCategoryModel({required this.id, required this.name, this.iconUrl});

  factory LifestyleCategoryModel.fromJson(Map<String, dynamic> json) => LifestyleCategoryModel(
        id: json['id'].toString(),
        name: json['name'] ?? '',
        iconUrl: json['icon_url'],
      );
}

class ListingConditionModel {
  final String id;
  final String name;
  final String? description;

  ListingConditionModel({required this.id, required this.name, this.description});

  factory ListingConditionModel.fromJson(Map<String, dynamic> json) => ListingConditionModel(
        id: json['id'].toString(),
        name: json['name'] ?? '',
        description: json['description'],
      );
}

class CountryModel {
  final String id;
  final String name;
  final String? iso2;
  final String? emoji;
  final String? latitude;
  final String? longitude;

  CountryModel({required this.id, required this.name, this.iso2, this.emoji, this.latitude, this.longitude});

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        id: json['id'].toString(),
        name: json['name'] ?? '',
        iso2: json['iso2'],
        emoji: json['emoji'],
        latitude: json['latitude']?.toString(),
        longitude: json['longitude']?.toString(),
      );
}

class StateModel {
  final String id;
  final String name;
  final String? iso2;
  final String? latitude;
  final String? longitude;

  StateModel({required this.id, required this.name, this.iso2, this.latitude, this.longitude});

  factory StateModel.fromJson(Map<String, dynamic> json) => StateModel(
        id: json['id'].toString(),
        name: json['name'] ?? '',
        iso2: json['iso2'],
        latitude: json['latitude']?.toString(),
        longitude: json['longitude']?.toString(),
      );
}

class CityModel {
  final String id;
  final String name;
  final String? latitude;
  final String? longitude;

  CityModel({required this.id, required this.name, this.latitude, this.longitude});

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        id: json['id'].toString(),
        name: json['name'] ?? '',
        latitude: json['latitude']?.toString(),
        longitude: json['longitude']?.toString(),
      );
}

// ── Amenities ──────────────────────────────────────────────────────────────

class AmenityCategoryModel {
  final String id;
  final String name;
  final String? icon;
  final List<AmenityModel> amenities;

  AmenityCategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.amenities = const [],
  });

  factory AmenityCategoryModel.fromJson(Map<String, dynamic> json) =>
      AmenityCategoryModel(
        id: json['id'].toString(),
        name: json['name'] ?? '',
        icon: json['icon'],
      );
}

class AmenityModel {
  final String id;
  final String name;
  final String? icon;
  final String? categoryId;

  AmenityModel({
    required this.id,
    required this.name,
    this.icon,
    this.categoryId,
  });

  factory AmenityModel.fromJson(Map<String, dynamic> json) => AmenityModel(
        id: json['id'].toString(),
        name: json['name'] ?? '',
        icon: json['icon'],
        categoryId: json['category_id']?.toString(),
      );
}

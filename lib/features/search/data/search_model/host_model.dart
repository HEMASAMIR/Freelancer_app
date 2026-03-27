class HostModel {
  final String? id;
  final String? fullName;
  final String? email;
  final String? selfieUrl;
  final int? verificationStatusId;

  HostModel({
    this.id,
    this.fullName,
    this.email,
    this.selfieUrl,
    this.verificationStatusId,
  });

  factory HostModel.fromJson(Map<String, dynamic> json) {
    return HostModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      selfieUrl: json['selfie_url'],
      verificationStatusId: json['verification_status_id'],
    );
  }
}

class PropertyTypeModel {
  final String? id;
  final String? name;
  final String? icon;

  PropertyTypeModel({this.id, this.name, this.icon});

  factory PropertyTypeModel.fromJson(Map<String, dynamic> json) {
    return PropertyTypeModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
    );
  }
}

class ListingImage {
  final String? url;
  final int? order;

  ListingImage({this.url, this.order});

  factory ListingImage.fromJson(Map<String, dynamic> json) {
    return ListingImage(
      url: json['url'] ?? json['image_url'] ?? json['listing_image_url'] ?? json['image'], 
      order: json['order'] ?? json['sort_order']
    );
  }
}

class LifestyleModel {
  final bool? isPrimary;
  final String? name;

  LifestyleModel({this.isPrimary, this.name});

  factory LifestyleModel.fromJson(Map<String, dynamic> json) {
    return LifestyleModel(
      isPrimary: json['is_primary'],
      name:
          json['lifestyle_category']?['translations']?['ar'] ??
          json['lifestyle_category']?['name'],
    );
  }
}

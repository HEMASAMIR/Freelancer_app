class AccountProfileModel {
  final String? id;
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final String? phone;
  final String? country;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  AccountProfileModel({
    this.id,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.phone,
    this.country,
    this.createdAt,
    this.metadata,
  });

  factory AccountProfileModel.fromJson(Map<String, dynamic> json) {
    return AccountProfileModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      phone: json['phone'],
      country: json['country'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (phone != null) 'phone': phone,
      if (country != null) 'country': country,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

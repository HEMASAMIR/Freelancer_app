import 'package:equatable/equatable.dart';

enum UserRole { user, admin }

class UserModel extends Equatable {
  final String id;
  final String email;
  final Map<String, dynamic> userMetadata;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.email,
    required this.userMetadata,
    this.role = UserRole.user,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      userMetadata: json['user_metadata'] ?? {},
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.user,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    Map<String, dynamic>? userMetadata,
    UserRole? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      userMetadata: userMetadata ?? this.userMetadata,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_metadata': userMetadata,
      'role': role == UserRole.admin ? 'admin' : 'user',
    };
  }

  @override
  List<Object?> get props => [id, email, userMetadata, role];
}

class UserSession extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final UserModel user;

  const UserSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      expiresIn: json['expires_in'] ?? 3600,
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn, user];
}
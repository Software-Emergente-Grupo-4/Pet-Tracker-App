import 'package:pet_tracker/features/auth/domain/entities/user_profile.dart';

class UserProfileMapper {
  static UserProfile fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      roles: List<String>.from(json['roles']),
    );
  }

  static Map<String, dynamic> toJson(UserProfile userProfile) {
    return {
      'id': userProfile.id,
      'username': userProfile.username,
      'email': userProfile.email,
      'firstName': userProfile.firstName,
      'lastName': userProfile.lastName,
      'roles': userProfile.roles,
    };
  }
}

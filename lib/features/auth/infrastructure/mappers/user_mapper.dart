import '../../domain/entities/authenticated_user.dart';

class UserMapper {
  static AuthenticatedUser userJsonToEntity(Map<String, dynamic> json) {
    return AuthenticatedUser(
      id: json['id'],
      username: json['username'],
      token: json['token'],
    );
  }
}

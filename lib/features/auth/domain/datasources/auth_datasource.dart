import 'package:pet_tracker/features/auth/domain/entities/authenticated_user.dart';
import 'package:pet_tracker/features/auth/domain/entities/register_request.dart';
import 'package:pet_tracker/features/auth/domain/entities/user_profile.dart';
abstract class AuthDatasource {
  Future<AuthenticatedUser> login(String username, String password);
  Future<AuthenticatedUser> register(RegisterRequest request);
  Future<AuthenticatedUser> checkAuthStatus(String token);
  Future<UserProfile> fetchUserProfile(int userId);
}

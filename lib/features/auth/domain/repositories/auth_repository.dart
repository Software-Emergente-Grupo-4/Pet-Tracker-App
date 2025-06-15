import 'package:pet_tracker/features/auth/domain/entities/authenticated_user.dart';
import 'package:pet_tracker/features/auth/domain/entities/user_profile.dart';

abstract class AuthRepository {
  Future<AuthenticatedUser> login(String username, String password);
  Future<AuthenticatedUser> register(String username, String password, List<String> roles, String email, String firstName, String lastName);
  Future<AuthenticatedUser> checkAuthStatus(String token);
  Future<UserProfile> fetchUserProfile(int userId);
}

import 'package:pet_tracker/features/auth/domain/domain.dart';
import 'package:pet_tracker/features/auth/domain/entities/register_request.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl({required this.datasource});

  @override
  Future<AuthenticatedUser> checkAuthStatus(String token) {
    return datasource.checkAuthStatus(token);
  }

  @override
  Future<AuthenticatedUser> login(String username, String password) {
    return datasource.login(username, password);
  }

  @override
  Future<AuthenticatedUser> register(RegisterRequest request) {
    return datasource.register(request);
  }

  @override
  Future<UserProfile> fetchUserProfile(int userId) {
    return datasource.fetchUserProfile(userId);
  }
}

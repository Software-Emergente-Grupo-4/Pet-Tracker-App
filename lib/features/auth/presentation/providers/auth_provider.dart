import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/auth/domain/domain.dart';
import 'package:pet_tracker/features/auth/domain/entities/register_request.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';
import '../../infrastructure/infrastructure.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthState {
  final AuthStatus authStatus;
  final AuthenticatedUser? user;
  final UserProfile? userProfile;
  final String errorMessage;

  AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.userProfile,
    this.errorMessage = '',
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    AuthenticatedUser? user,
    UserProfile? userProfile,
    String? errorMessage,
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
      user: user ?? this.user,
      userProfile: userProfile ?? this.userProfile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;

  AuthNotifier({
    required this.authRepository,
    required this.keyValueStorageService,
  }) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> loginUser(String username, String password) async {
    try {
      final authenticatedUser = await authRepository.login(username, password);
      _setLoggedUser(authenticatedUser);

      final userProfile =
          await authRepository.fetchUserProfile(authenticatedUser.id);
      state = state.copyWith(userProfile: userProfile);
    } catch (e) {
      logout('Login failed');
    }
  }

  Future<void> registerUser({
    required String username,
    required String password,
    required String email,
    required String firstName,
    required String lastName,
    List<String> roles = const ['ROLE_ADMIN'],
  }) async {
    try {
      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        roles: roles,
      );

      await authRepository.register(request);
    } catch (e) {
      logout('Registration failed');
    }
  }

  void checkAuthStatus() async {
    final token = await keyValueStorageService.getValue<String>('token');
    if (token == null) {
      return logout();
    }

    try {
      final authenticatedUser = await authRepository.checkAuthStatus(token);
      _setLoggedUser(authenticatedUser);

      final userProfile =
          await authRepository.fetchUserProfile(authenticatedUser.id);
      state = state.copyWith(userProfile: userProfile);
    } catch (e) {
      logout('Session expired');
    }
  }

  void _setLoggedUser(AuthenticatedUser user) async {
    await keyValueStorageService.setKeyValue('token', user.token);
    await keyValueStorageService.setKeyValue(
        'selectedDeviceRecordId', '123456789');
    await keyValueStorageService.setKeyValue('selectedApiKey', '123456789');
    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: '',
    );
  }

  Future<void> logout([String? errorMessage]) async {
    await keyValueStorageService.removeAllKeys();
    state = state.copyWith(
      authStatus: AuthStatus.unauthenticated,
      user: null,
      userProfile: null,
      errorMessage: errorMessage ?? '',
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final keyValueStorageService = ref.read(keyValueStorageServiceProvider);
  final authRepository = AuthRepositoryImpl(
    datasource: AuthDatasourceImpl(storageService: keyValueStorageService),
  );

  return AuthNotifier(
    authRepository: authRepository,
    keyValueStorageService: keyValueStorageService,
  );
});
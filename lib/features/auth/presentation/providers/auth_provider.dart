import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/auth/domain/domain.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
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
      await _setLoggedUser(authenticatedUser);
      final userProfile =
          await authRepository.fetchUserProfile(authenticatedUser.id);
      state = state.copyWith(userProfile: userProfile);
    } catch (e) {
      logout('Login failed');
    }
  }

  Future<void> registerUser(
    String username,
    String password,
    List<String> roles,
    String email,
    String firstName,
    String lastName,
  ) async {
    try {
      final authenticatedUser = await authRepository.register(
        username,
        password,
        roles,
        email,
        firstName,
        lastName,
      );
      await _setLoggedUser(authenticatedUser);
      final userProfile =
          await authRepository.fetchUserProfile(authenticatedUser.id);
      state = state.copyWith(userProfile: userProfile);
    } catch (e) {
      logout('Registration failed');
    }
  }

  void checkAuthStatus() async {
    final token = await keyValueStorageService.getValue<String>('token');
    if (token == null) return logout();

    try {
      final authenticatedUser = await authRepository.checkAuthStatus(token);
      await _setLoggedUser(authenticatedUser);
      final userProfile =
          await authRepository.fetchUserProfile(authenticatedUser.id);
      state = state.copyWith(userProfile: userProfile);
    } catch (e) {
      logout('Session expired');
    }
  }

  Future<void> _setLoggedUser(AuthenticatedUser user) async {
    await keyValueStorageService.setKeyValue('token', user.token);
    await keyValueStorageService.setKeyValue('userId', user.id.toString());

    // 🔍 Log del token para usarlo en Swagger
    print('🟢 TOKEN COPIA PARA SWAGGER: Bearer ${user.token}');

    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: '',
    );
  }

  Future<void> logout([String? errorMessage]) async {
    await keyValueStorageService.removeKey('token');
    await keyValueStorageService.removeKey('userId');
    await keyValueStorageService.removeKey('selectedDeviceRecordId');
    await keyValueStorageService.removeKey('selectedApiKey');
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

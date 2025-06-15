import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:pet_tracker/shared/shared.dart';
import 'auth_provider.dart';

// Define el estado del formulario
class LoginFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Username username;
  final Password password;

  LoginFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.username = const Username.pure(),
    this.password = const Password.pure(),
  });

  LoginFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Username? username,
    Password? password,
  }) {
    return LoginFormState(
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}

// Define el StateNotifier para manejar los cambios en el formulario
class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final Function(String, String) loginUserCallback;

  LoginFormNotifier({required this.loginUserCallback})
      : super(LoginFormState());

  void onUsernameChanged(String value) {
    final newUsername = Username.dirty(value);
    state = state.copyWith(
        username: newUsername,
        isValid: Formz.validate([newUsername, state.password]));
  }

  onPasswordChanged(String value) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
        password: newPassword,
        isValid: Formz.validate([newPassword, state.username]));
  }

  void onFormSubmit() async {
    _touchAllFields();
    if (!state.isValid) return;

    state = state.copyWith(isPosting: true);

    await loginUserCallback(state.username.value, state.password.value);

    if (mounted) {
      state = state.copyWith(isPosting: false);
    }
  }

  void _touchAllFields() {
    final username = Username.dirty(state.username.value);
    final password = Password.dirty(state.password.value);

    state = state.copyWith(
        isFormPosted: true,
        username: username,
        password: password,
        isValid: Formz.validate([username, password]));
  }
}

final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
  final loginUserCallback = ref.watch(authProvider.notifier).loginUser;
  return LoginFormNotifier(loginUserCallback: loginUserCallback);
});

// El autoDispose es para que se elimine el provider cuando no se use, en este caso cuando se cierre la pantalla de login y ya haya ingresado a la app, no se necesita el provider, por lo que se elimina
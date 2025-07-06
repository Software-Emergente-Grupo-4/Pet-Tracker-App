// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_tracker/shared/shared.dart';
import 'package:pet_tracker/features/auth/presentation/providers/auth_provider.dart';

class RegisterFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final bool termsAccepted;
  final Email email;
  final Password password;
  final Username username;
  final String firstName;
  final String lastName;

  RegisterFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.termsAccepted = false,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.username = const Username.pure(),
    this.firstName = '',
    this.lastName = '',
  });

  RegisterFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    bool? termsAccepted,
    Email? email,
    Password? password,
    Username? username,
    String? firstName,
    String? lastName,
  }) {
    return RegisterFormState(
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      email: email ?? this.email,
      password: password ?? this.password,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }
}

class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  final AuthNotifier authNotifier;

  RegisterFormNotifier({required this.authNotifier})
      : super(RegisterFormState());

  void onEmailChanged(String value) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: _validateForm(
            email: newEmail,
            password: state.password,
            username: state.username,
          ) &&
          state.termsAccepted,
    );
  }

  void onPasswordChanged(String value) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
      password: newPassword,
      isValid: _validateForm(
            email: state.email,
            password: newPassword,
            username: state.username,
          ) &&
          state.termsAccepted,
    );
  }

  void onUsernameChanged(String value) {
    final newUsername = Username.dirty(value);
    state = state.copyWith(
      username: newUsername,
      isValid: _validateForm(
            email: state.email,
            password: state.password,
            username: newUsername,
          ) &&
          state.termsAccepted,
    );
  }

  void onFirstNameChanged(String value) {
    state = state.copyWith(firstName: value);
  }

  void onLastNameChanged(String value) {
    state = state.copyWith(lastName: value);
  }

  void onTermsAcceptedChanged(bool isAccepted) {
    state = state.copyWith(
      termsAccepted: isAccepted,
      isValid: _validateForm(
            email: state.email,
            password: state.password,
            username: state.username,
          ) &&
          isAccepted,
    );
  }

  Future<void> onFormSubmit(BuildContext context) async {
    _touchAllFields();

    if (!state.isValid || state.password.value.isEmpty) {
      state = state.copyWith(
        isFormPosted: true,
        isValid: false,
      );
      return;
    }

    state = state.copyWith(isPosting: true);

    try {
      await authNotifier.registerUser(
        email: state.email.value,
        username: state.username.value,
        password: state.password.value,
        firstName: state.firstName,
        lastName: state.lastName,
      );

      if (mounted) {
        state = state.copyWith(isPosting: false);
        context.go('/login');
      }
    } catch (e) {
      state = state.copyWith(isPosting: false);
    }
  }

  void _touchAllFields() {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    final username = Username.dirty(state.username.value);

    state = state.copyWith(
      email: email,
      password: password,
      username: username,
      isFormPosted: true,
      isValid: _validateForm(
            email: email,
            password: password,
            username: username,
          ) &&
          state.termsAccepted,
    );
  }

  bool _validateForm({
    required Email email,
    required Password password,
    required Username username,
  }) {
    final isFirstNameValid = state.firstName.isNotEmpty;
    final isLastNameValid = state.lastName.isNotEmpty;

    return Formz.validate([email, password, username]) &&
        isFirstNameValid &&
        isLastNameValid;
  }
}

final registerFormProvider =
    StateNotifierProvider<RegisterFormNotifier, RegisterFormState>((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  return RegisterFormNotifier(authNotifier: authNotifier);
});

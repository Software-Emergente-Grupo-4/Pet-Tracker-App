import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/auth/presentation/providers/providers.dart';
import 'package:pet_tracker/shared/shared.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(registerFormProvider, (previous, current) {
      if (current.isFormPosted && !current.isValid) {
        showSnackBar(context, "Please correct the errors in the form.");
      }
    });

    final registerForm = ref.watch(registerFormProvider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/login_img.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Sign up to",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "PetTracker",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Basic User Information",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _EmailInput(),
                      const SizedBox(height: 20),
                      const _UsernameInput(),
                      const SizedBox(height: 20),
                      const _PasswordInput(),
                      const SizedBox(height: 20),
                      const _FirstNameInput(),
                      const SizedBox(height: 20),
                      const _LastNameInput(),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: registerForm.termsAccepted,
                            onChanged: (value) {
                              ref
                                  .read(registerFormProvider.notifier)
                                  .onTermsAcceptedChanged(value ?? false);
                            },
                          ),
                          const Expanded(
                            child: Text(
                              "I accept the Terms and Conditions and Privacy Policy of PetTracker, ensuring the responsible and secure use of my personal data.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const _RegisterButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailInput extends ConsumerWidget {
  const _EmailInput();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerForm = ref.watch(registerFormProvider);

    return CustomTextFormField(
      label: 'Email',
      keyboardType: TextInputType.emailAddress,
      onChanged: ref.read(registerFormProvider.notifier).onEmailChanged,
      errorMessage:
          registerForm.isFormPosted ? registerForm.email.errorMessage : null,
    );
  }
}

class _UsernameInput extends ConsumerWidget {
  const _UsernameInput();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerForm = ref.watch(registerFormProvider);
    return CustomTextFormField(
      label: 'Username',
      keyboardType: TextInputType.text,
      onChanged: ref.read(registerFormProvider.notifier).onUsernameChanged,
      errorMessage:
          registerForm.isFormPosted ? registerForm.username.errorMessage : null,
    );
  }
}

class _PasswordInput extends ConsumerWidget {
  const _PasswordInput();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerForm = ref.watch(registerFormProvider);
    return CustomTextFormField(
      label: 'Password',
      obscureText: true,
      onChanged: ref.read(registerFormProvider.notifier).onPasswordChanged,
      errorMessage:
          registerForm.isFormPosted ? registerForm.password.errorMessage : null,
    );
  }
}

class _FirstNameInput extends ConsumerWidget {
  const _FirstNameInput();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomTextFormField(
      label: 'First Name',
      onChanged: ref.read(registerFormProvider.notifier).onFirstNameChanged,
    );
  }
}

class _LastNameInput extends ConsumerWidget {
  const _LastNameInput();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomTextFormField(
      label: 'Last Name',
      onChanged: ref.read(registerFormProvider.notifier).onLastNameChanged,
    );
  }
}

class _RegisterButton extends ConsumerWidget {
  const _RegisterButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerForm = ref.watch(registerFormProvider);

    return SizedBox(
      width: double.infinity,
      child: CustomFilledButton(
        text: 'Register',
        buttonColor: registerForm.isValid && registerForm.termsAccepted
            ? const Color(0xFF08273A)
            : Colors.grey,
        onPressed: registerForm.isPosting || !registerForm.isValid
            ? null
            : () =>
                ref.read(registerFormProvider.notifier).onFormSubmit(context),
      ),
    );
  }
}

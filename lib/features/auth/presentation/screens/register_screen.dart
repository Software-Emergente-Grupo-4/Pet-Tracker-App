import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_tracker/features/auth/presentation/providers/register_form_provider.dart';
import 'package:pet_tracker/shared/widgets/widgets.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerForm = ref.watch(registerFormProvider);
    final registerNotifier = ref.read(registerFormProvider.notifier);

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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                          "Create your account",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500),
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
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        label: 'Username',
                        onChanged: registerNotifier.onUsernameChanged,
                        errorMessage: registerForm.isFormPosted ? registerForm.username.errorMessage : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        label: 'Email',
                        onChanged: registerNotifier.onEmailChanged,
                        errorMessage: registerForm.isFormPosted ? registerForm.email.errorMessage : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        label: 'First Name',
                        onChanged: registerNotifier.onFirstNameChanged,
                        errorMessage: registerForm.isFormPosted ? registerForm.firstName.errorMessage : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        label: 'Last Name',
                        onChanged: registerNotifier.onLastNameChanged,
                        errorMessage: registerForm.isFormPosted ? registerForm.lastName.errorMessage : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        label: 'Password',
                        obscureText: true,
                        onChanged: registerNotifier.onPasswordChanged,
                        errorMessage: registerForm.isFormPosted ? registerForm.password.errorMessage : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        label: 'Confirm Password',
                        obscureText: true,
                        onChanged: registerNotifier.onConfirmPasswordChanged,
                        errorMessage: registerForm.isFormPosted ? registerForm.confirmPassword.errorMessage : null,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: CustomFilledButton(
                          text: 'Register',
                          buttonColor: const Color(0xFF08273A),
                          onPressed: registerForm.isPosting
                              ? null
                              : () async {
                                  await registerNotifier.onFormSubmit();
                                  if (registerForm.isValid) {
                                    if (context.mounted) {
                                      showSnackBar(context, 'User registered successfully');
                                      context.go('/login');
                                    }
                                  }
                                },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(color: Colors.black54),
                          ),
                          TextButton(
                            onPressed: () {
                              context.go('/login');
                            },
                            child: const Text(
                              'Sign in here',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
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

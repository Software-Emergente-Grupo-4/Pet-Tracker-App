import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:pet_tracker/features/settings/presentation/widgets/save_change_modal.dart';
import 'package:pet_tracker/shared/infrastructure/inputs/inputs.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _obscurePassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = ref.watch(authProvider);
    final userProfile = authState.userProfile;

    if (userProfile != null) {
      _emailController.text = userProfile.email;
      _nameController.text = userProfile.firstName;
      _surnameController.text = userProfile.lastName;
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _validateAndSave() {
    final newPassword = Password.dirty(_newPasswordController.text);
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.error == PasswordError.empty) {
      _showSnackBar(context, 'New Password is required');
      return;
    }
    if (newPassword.error == PasswordError.length) {
      _showSnackBar(context, 'New Password must be at least 6 characters');
      return;
    }
    if (newPassword.error == PasswordError.format) {
      _showSnackBar(context,
          'New Password must contain uppercase, lowercase, and a number');
      return;
    }

    if (newPassword.value != confirmPassword) {
      _showSnackBar(context, 'New Password and Confirm Password do not match');
      return;
    }

    _showSaveChangesModal(context);
  }

  void _showSaveChangesModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SaveChangesModal(
        onCancel: () {
          _resetFields();
        },
        onSave: () {
          // TODO: Implementar el onSave cuando el Backend esté listo
          context.pop();
        },
      ),
    );
  }

  void _resetFields() {
    final authState = ref.read(authProvider);
    final userProfile = authState.userProfile;

    if (userProfile != null) {
      _emailController.text = userProfile.email;
      _passwordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _nameController.text = userProfile.firstName;
      _surnameController.text = userProfile.lastName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userProfile = authState.userProfile;

    if (userProfile == null) {
      return const Center(child: Text('User not authenticated'));
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings',
              style: TextStyle(
                  color: Color(0xFF08273A),
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Selector de imagen de perfil
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFE8F7FF),
                      radius: 60,
                      child: SvgPicture.asset(
                        'assets/images/user.svg',
                        width: 80,
                        height: 80,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF08273A),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          // Implementar selección de imagen
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Text(
                            'SELECT IMAGE',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  icon: Icons.email,
                  isObscure: false,
                  isEnabled: true,
                ),
                const SizedBox(height: 10),
                _buildPasswordField(
                  label: 'Password',
                  controller: _passwordController,
                  isObscure: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildPasswordField(
                  label: 'New Password',
                  controller: _newPasswordController,
                  isObscure: _obscureNewPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildPasswordField(
                  label: 'Confirm Password',
                  controller: _confirmPasswordController,
                  isObscure: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  label: 'Name',
                  controller: _nameController,
                  icon: Icons.person,
                  isObscure: false,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  label: 'Surnames',
                  controller: _surnameController,
                  icon: Icons.person_outline,
                  isObscure: false,
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _validateAndSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF08273A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isObscure,
    bool isEnabled = true,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      enabled: isEnabled,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }
}

import 'package:calolect/user%20controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    final TextEditingController _nameController = TextEditingController(text: userController.userName);
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    final _obscurePassword = true.obs;

    Future<void> _loadUserData() async {
      final user = userController.supabase.auth.currentUser;
      if (user != null) {
        _emailController.text = user.email ?? 'No email available';
      } else {
        _emailController.text = 'Not logged in';
      }
    }

    Future<void> _saveProfile() async {
      if (!_formKey.currentState!.validate()) return;

      try {
        final updatedName = _nameController.text.trim();
        final updatedPassword = _passwordController.text.trim();

        if (updatedPassword.isNotEmpty && updatedPassword.length >= 6) {
          await userController.supabase.auth.updateUser(
            UserAttributes(password: updatedPassword),
          );
        }

        await userController.updateUserName(updatedName);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        Get.back();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }

    _loadUserData();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF184542), Color(0xFF3B6265)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      Image.asset('assets/logo.png', height: 40),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildInputField(_nameController, 'Full name'),
                  const SizedBox(height: 15),
                  _buildInputField(_emailController, 'Email', readOnly: true),
                  const SizedBox(height: 20),
                  Obx(
                        () => _buildInputField(
                      _passwordController,
                      'New Password',
                      password: true,
                      obscurePassword: _obscurePassword.value,
                      onToggleObscure: () => _obscurePassword.value = !_obscurePassword.value,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(120, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                      Obx(
                            () => ElevatedButton(
                          onPressed: userController.isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: userController.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller,
      String label, {
        bool email = false,
        bool password = false,
        bool readOnly = false,
        bool? obscurePassword,
        VoidCallback? onToggleObscure,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(readOnly ? 0.3 : 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        obscureText: password && obscurePassword == true,
        keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: readOnly ? Colors.black54 : Colors.black87,
            fontWeight: readOnly ? FontWeight.normal : FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: password
              ? IconButton(
            icon: Icon(
              obscurePassword == true ? Icons.visibility_off : Icons.visibility,
              color: Colors.black87,
            ),
            onPressed: onToggleObscure,
          )
              : null,
        ),
        style: TextStyle(
          color: readOnly ? Colors.black54 : Colors.black87,
          fontWeight: readOnly ? FontWeight.normal : FontWeight.w400,
        ),
        validator: (value) {
          if (label == 'Full name' && (value == null || value.isEmpty)) {
            return 'Please enter $label';
          }
          if (password && value != null && value.isNotEmpty && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }
}
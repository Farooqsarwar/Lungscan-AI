import 'package:calolect/homepage.dart';
import 'package:calolect/login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final supabase = Supabase.instance.client;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Supabase signup
      final authResponse = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'name': _fullNameController.text.trim(),
        },
      );

      final user = authResponse.user;

      if (user != null) {
        // Insert into custom users table (if needed)
        final existingUser = await supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (existingUser == null) {
          await supabase.from('users').insert({
            'id': user.id,
            'name': _fullNameController.text.trim(),
            'email': _emailController.text.trim(),
            'created_at': DateTime.now().toIso8601String(),
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup successful! Please login.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF184542), Color(0xFF6AB4BC)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  Center(
                    child: Image.asset('assets/logo.png', height: 100),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Full Name'),
                        _buildInput(_fullNameController, 'Enter your full name'),
                        SizedBox(height: 20),
                        _buildLabel('Email'),
                        _buildInput(_emailController, 'Enter your email',
                            email: true),
                        SizedBox(height: 20),
                        _buildLabel('Password'),
                        _buildInput(_passwordController, 'Enter your password',
                            password: true),
                        SizedBox(height: 40),
                        _buildSignupButton(),
                        SizedBox(height: 24),
                        Center(
                          child: Text("Already have an Account?",
                              style: TextStyle(color: Colors.white)),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => LoginScreen()),
                              );
                            },
                            child: Text('Login',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _buildInput(TextEditingController controller, String hint,
      {bool email = false, bool password = false}) {
    return TextFormField(
      controller: controller,
      obscureText: password ? _obscurePassword : false,
      keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        suffixIcon: password
            ? IconButton(
          icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.grey),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        )
            : null,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required field';
        if (email &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Enter a valid email';
        }
        if (password && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF184542),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isLoading
            ? CircularProgressIndicator(
            color: Color(0xFF184542), strokeWidth: 2)
            : Text('Sign Up',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

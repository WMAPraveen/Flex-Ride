import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final bool isSignIn;
  final bool isLoading;
  final bool obscurePassword;
  final VoidCallback onTogglePasswordVisibility;
  final Function(String email, String password) onSubmit;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  const AuthForm({
    super.key,
    required this.isSignIn,
    this.isLoading = false,
    required this.obscurePassword,
    required this.onTogglePasswordVisibility,
    required this.onSubmit,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
  });

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _confirmPasswordController = TextEditingController();
  bool _obscureConfirmPassword = true; // For Confirm Password toggle

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          const Text("Email", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              hintText: 'example@gmail.com',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password Field
          const Text("Password", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.passwordController,
            obscureText: widget.obscurePassword,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  widget.obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white54,
                ),
                onPressed: widget.isLoading
                    ? null
                    : widget.onTogglePasswordVisibility,
              ),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (!widget.isSignIn && value.length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password Field (only if signing up)
          if (!widget.isSignIn) ...[
            const Text("Confirm Password", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              enabled: !widget.isLoading,
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white54,
                  ),
                  onPressed: widget.isLoading
                      ? null
                      : () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                ),
              ),
              style: const TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != widget.passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

import 'package:flex_ride/features/lister/listerdashboardscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../widgets/authform.dart';
import './signup.dart';
import './forgetpassword.dart';
import '../../home/home.dart';
import '../../admin/admin.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuthNavigation(UserCredential userCredential) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    final data = userDoc.data();
    final isAdmin = data?['isAdmin'] ?? false;
    final role = data?['role'] ?? 'renter';

    Widget destinationScreen;

    if (isAdmin) {
      destinationScreen = const AdminDashboardScreen();
    } else if (role == 'lister') {
      destinationScreen =  DashboardScreen();
    } else {
      destinationScreen = const HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destinationScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Sign In',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hi! Welcome back, you\'ve been missed',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 32),
                AuthForm(
                  isSignIn: true,
                  isLoading: _isLoading,
                  obscurePassword: true,
                  onTogglePasswordVisibility: () {},
                  onSubmit: (_, __) {}, // handled manually below
                  emailController: _emailController,
                  passwordController: _passwordController,
                  formKey: _formKey,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: _isLoading ? null : (value) => setState(() => _rememberMe = value ?? false),
                          activeColor: const Color(0xFFE74D3D),
                          checkColor: Colors.white,
                        ),
                        const Text('Remember me', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ForgetPasswordScreen()),
                              ),
                      child: const Text('Forgot password...', style: TextStyle(color: Color(0xFFE74D3D))),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            final email = _emailController.text.trim();
                            final password = _passwordController.text;

                            setState(() => _isLoading = true);
                            try {
                              final userCredential = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(email: email, password: password);
                              _handleAuthNavigation(userCredential);
                            } on FirebaseAuthException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.message ?? 'Sign-in failed')),
                              );
                            } finally {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74D3D),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Sign In', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?", style: TextStyle(color: Colors.white)),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignUpScreen()),
                              ),
                      child: const Text('Sign up', style: TextStyle(color: Color(0xFFE74D3D))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

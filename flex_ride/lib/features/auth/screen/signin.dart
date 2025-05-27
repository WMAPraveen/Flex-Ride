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
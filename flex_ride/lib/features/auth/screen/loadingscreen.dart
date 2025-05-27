import 'package:flutter/material.dart';
import './welcomescreen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to WelcomeScreen after 10 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder image from assets with error handling
            Image.asset(
              'assets/loading.jpg',
              width: 300,
              height: 300,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  'Image failed to load',
                  style: TextStyle(color: Colors.white),
                );
              },
            ),
            // const SizedBox(height: 24),
            // Loading text
            // const Text(
            //   'Loading...',
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // const SizedBox(height: 16),
            // Pink CircularProgressIndicator
            // const CircularProgressIndicator(
            //   valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE74D3D)),
            //   strokeWidth: 3,
            // ),
          ],
        ),
      ),
    );
  }
}
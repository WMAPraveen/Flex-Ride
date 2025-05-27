
import 'package:flex_ride/features/auth/screen/Loadingscreen.dart';
// import 'package:car_rental_app/features/auth/screen/location_screen.dart';
// import 'package:car_rental_app/features/auth/screen/signin.dart';

// import 'package:car_rental_app/features/auth/screen/Loadingscreen.dart';
// import 'package:car_rental_app/features/auth/screen/location_screen.dart';
// import 'package:car_rental_app/features/auth/screen/signin.dart';

// import 'package:car_rental_app/features/auth/screen/welcomescreen.dart';
// import 'package:car_rental_app/features/home/home.dart';
// import 'package:car_rental_app/features/lister/listerdashboardscreen.dart';
// import 'package:car_rental_app/features/home/home.dart';
// import 'package:car_rental_app/features/auth/screen/dashboard_screen.dart';
// import 'package:car_rental_app/features/lister/listerdashboardscreen.dart';

// import 'package:car_rental_app/features/home/home.dart';
// import 'package:car_rental_app/features/vehicledetails/vehicledetailsscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_ride/features/auth/screen/loadingscreen.dart';
import 'package:flutter/material.dart';
// import 'features/auth/screen/signin.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flex Ride',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          // backgroundColor: Colors.transparent,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.transparent,
        ),
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      // home: const DashboardScreen(),
      // home: const VehicleDetailsScreen(),
      // home: const SignInScreen(),
      // home:HomeScreen()
      home:LoadingScreen(),

     
    );
  }
}

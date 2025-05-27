import 'package:flex_ride/services/get_loaction.dart';
import 'package:flutter/material.dart';

 // your location file

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Location")),
      body: FutureBuilder<String>(
        future: GetLocationServices().getCityNameFromCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error getting location"));
          }

          
import 'package:flutter/material.dart';
import 'bookpage.dart';

class VehicleDetails extends StatelessWidget {
  final String vehicleName;

  const VehicleDetails({Key? key, required this.vehicleName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cover Image with Back Button
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 220,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Text(
                      'Cover Image',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: ClipOval(
                    child: Material(
                      color: Colors.black.withOpacity(0.7),
                      child: InkWell(
                        splashColor: Colors.white.withOpacity(0.2),
                        onTap: () => Navigator.pop(context),
                        child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
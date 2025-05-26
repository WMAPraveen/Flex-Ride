
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'bookpage.dart';

class VehicleDetails extends StatelessWidget {
  final String vehicleId;
  final String vehicleName;
  final String? imageBase64;

  const VehicleDetails({
    Key? key,
    required this.vehicleId,
    required this.vehicleName,
    this.imageBase64,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ImageProvider? coverImage;
    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      try {
        final imageBytes = base64Decode(imageBase64!);
        coverImage = MemoryImage(imageBytes);
      } catch (e) {
        print('Error decoding vehicle image: $e');
      }
    }

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
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    image: coverImage != null
                        ? DecorationImage(
                            image: coverImage,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: coverImage == null
                      ? const Center(
                          child: Text(
                            'No Image Available',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
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

            const SizedBox(height: 24),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Name
                  Text(
                    vehicleName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Fetch Dynamic Description
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('vehicles')
                        .doc(vehicleId)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                        return const Text(
                          'Description: Not available',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        );
                      }
                      final vehicleData = snapshot.data!.data() as Map<String, dynamic>;
                      final description = vehicleData['description'] ?? 'No description';
                      final pricePerDay = vehicleData['pricePerDay']?.toStringAsFixed(2) ?? 'N/A';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description: $description',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price: \$$pricePerDay/day',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Vehicle Specs Grid
                  const Text(
                    'Vehicle Specs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.5,
                    children: const [
                      _SpecCard(title: '320 hp', subtitle: 'Max Power'),
                      _SpecCard(title: '550 km', subtitle: 'Fuel'),
                      _SpecCard(title: '2.8 sec', subtitle: '0-60 mph'),
                      _SpecCard(title: '177 mph', subtitle: 'Max Speed'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Car Features
                  const Text(
                    'Car Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 24,
                    children: const [
                      _FeatureIcon(icon: Icons.ac_unit, label: 'Snow Tires'),
                      _FeatureIcon(icon: Icons.people, label: '5 Passengers'),
                      _FeatureIcon(icon: Icons.door_front_door, label: '4 Doors'),
                      _FeatureIcon(icon: Icons.gps_fixed, label: 'GPS'),
                      _FeatureIcon(icon: Icons.bluetooth, label: 'Bluetooth'),
                      _FeatureIcon(icon: Icons.directions_car, label: 'Auto'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Book Now Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookNowPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Spec Card Widget
class _SpecCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SpecCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// Feature Icon Widget
class _FeatureIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.black),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
      ],
    );
  }
}

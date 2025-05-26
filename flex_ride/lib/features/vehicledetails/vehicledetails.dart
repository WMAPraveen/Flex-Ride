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

            const SizedBox(height: 24),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Specs Grid
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

                  const Text(
                    'Car Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Car Features Grid
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
                      _FeatureIcon(
                        icon: Icons.door_front_door,
                        label: '4 Doors',
                      ),
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
                        // Navigate to BookNowPage when Book Now is pressed
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookNowPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
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
        Icon(icon, size: 32, color: const Color.fromARGB(255, 0, 0, 0)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
      ],
    );
  }
}
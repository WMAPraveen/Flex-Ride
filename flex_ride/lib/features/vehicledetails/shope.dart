import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_rental_app/features/vehicledetails/ratingpage.dart';
import 'package:car_rental_app/features/vehicledetails/vehicledetails.dart';
import 'package:flutter/material.dart';

class Shope extends StatefulWidget {
  final String title;
  final String location;
  final String? coverPicture;

  const Shope({
    Key? key,
    required this.title,
    required this.location,
    this.coverPicture,
  }) : super(key: key);

  @override
  State<Shope> createState() => _ShopeState();
}

class _ShopeState extends State<Shope> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> tabs = ['All', 'Car', 'Van', 'SUV', 'Bike', 'Truck'];
  String? _listerUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _fetchListerUserId();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchListerUserId() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: widget.title)
          .limit(1)
          .get();
      if (userSnapshot.docs.isNotEmpty) {
        setState(() {
          _listerUserId = userSnapshot.docs.first.id;
        });
      }
    } catch (e) {
      print('Error fetching lister userId: $e');
    }
  }

  Widget buildTabContent(String tabName) {
    if (_listerUserId == null) {
      return const Center(child: Text('Loading lister data...'));
    }

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('vehicles')
        .where('userId', isEqualTo: _listerUserId);

    if (tabName != 'All') {
      query = query.where('type', isEqualTo: tabName);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No $tabName vehicles available'));
        }

        final vehicles = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicleData = vehicles[index].data() as Map<String, dynamic>;
              final vehicleId = vehicles[index].id;
              final vehicleName = vehicleData['name'] ?? 'Unknown Vehicle';
              final vehicleDescription = vehicleData['description'] ?? 'No description';
              final imageBase64 = vehicleData['imageBase64'] as String?;

              ImageProvider? vehicleImage;
              if (imageBase64 != null && imageBase64.isNotEmpty) {
                try {
                  final imageBytes = base64Decode(imageBase64);
                  vehicleImage = MemoryImage(imageBytes);
                } catch (e) {
                  print('Error decoding vehicle image: $e');
                }
              }

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VehicleDetails(
                        vehicleName: vehicleName,
                        // Pass vehicleId instead of userId
                        // Assuming VehicleDetails can use vehicleId to fetch details
                      ),
                    ),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: Text(vehicleName),
                    subtitle: Text(vehicleDescription),
                    leading: vehicleImage != null
                        ? Image(image: vehicleImage, width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.directions_car),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

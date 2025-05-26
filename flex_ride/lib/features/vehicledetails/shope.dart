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

  @override
  Widget build(BuildContext context) {
    ImageProvider? coverImage;
    if (widget.coverPicture != null && widget.coverPicture!.isNotEmpty) {
      try {
        final imageBytes = base64Decode(widget.coverPicture!);
        coverImage = MemoryImage(imageBytes);
      } catch (e) {
        print('Error decoding cover image: $e');
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
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
                                  'Cover Image',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        right: 16,
                        bottom: -10,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minimumSize: const Size(60, 30),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RatingPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'More Info',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Location: ${widget.location}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: const Color(0xFFE74D3D),
                      unselectedLabelColor: Colors.black,
                      indicatorColor: const Color(0xFFE74D3D),
                      indicatorWeight: 3,
                      labelStyle:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                      tabs: tabs.map((tab) => Tab(text: tab)).toList(),
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: tabs.map((tab) => buildTabContent(tab)).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
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
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

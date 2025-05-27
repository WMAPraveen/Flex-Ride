import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flex_ride/features/auth/screen/profile_screen.dart';
import 'package:flex_ride/features/home/bookmark_page.dart';
import 'package:flex_ride/models/vehicle.dart';
import 'package:flex_ride/widgets/customer_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flex_ride/features/vehicledetails/shope.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    BookmarkPage(),
    const Placeholder(),
    const HomeContent(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleLogout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(onLogout: _handleLogout),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ScrollController _scrollController = ScrollController();
  late Timer _scrollTimer;
  double _scrollPosition = 0;
  final double _cardWidth = 300;
  final double _cardSpacing = 12;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final nextPosition = _scrollPosition + _cardWidth + _cardSpacing;

        if (nextPosition > maxScroll) {
          _scrollPosition = 0;
        } else {
          _scrollPosition = nextPosition;
        }

        _scrollController.animateTo(
          _scrollPosition,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          return userDoc.data() ?? {};
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
    return {};
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Widget _buildProfileAvatar(String? profileImageBase64) {
    if (profileImageBase64 != null && profileImageBase64.isNotEmpty) {
      try {
        final imageBytes = base64Decode(profileImageBase64);
        return CircleAvatar(
          radius: 20,
          backgroundImage: MemoryImage(imageBytes),
          backgroundColor: Colors.grey,
        );
      } catch (e) {
        print('Error decoding profile image: $e');
      }
    }
    return const CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey,
      child: Icon(Icons.person, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FutureBuilder<Map<String, dynamic>>(
                        future: _getCurrentUserData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            );
                          }
                          final userData = snapshot.data ?? {};
                          final profileImage = userData['profilePicture'] as String?;
                          return _buildProfileAvatar(profileImage);
                        },
                      ),
                      const SizedBox(width: 8),
                      FutureBuilder<Map<String, dynamic>>(
                        future: _getCurrentUserData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text(
                              'Hello...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                          final userData = snapshot.data ?? {};
                          final userName = userData['name'] ?? 'User';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello $userName,',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getTimeBasedGreeting(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for cars, locations...',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        suffixIcon: Icon(Icons.mic, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'RECOMMENDED LOCATIONS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 200,
                child: ListView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFixedSizeCard('assets/images/I1.png'),
                    const SizedBox(width: 12),
                    _buildFixedSizeCard('assets/images/I2.png'),
                    const SizedBox(width: 12),
                    _buildFixedSizeCard('assets/images/I3.png'),
                    const SizedBox(width: 12),
                    _buildFixedSizeCard('assets/images/I4.png'),
                    const SizedBox(width: 300),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'MOST RENTED VEHICLES',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('vehicles').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    print('Stream error: ${snapshot.error}');
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Error loading vehicles: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'No vehicles available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  final vehicles = snapshot.data!.docs
                      .map((doc) => Vehicle.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                      .toList();

                  // Group by userId and select earliest vehicle
                  final Map<String, Vehicle> firstVehiclesByLister = {};
                  for (var vehicle in vehicles) {
                    if (vehicle.userId.isNotEmpty) {
                      if (!firstVehiclesByLister.containsKey(vehicle.userId) ||
                          vehicle.id.compareTo(firstVehiclesByLister[vehicle.userId]!.id) < 0) {
                        firstVehiclesByLister[vehicle.userId] = vehicle;
                      }
                    }
                  }

                  return Column(
                    children: firstVehiclesByLister.values.map((vehicle) {
                      return Column(
                        children: [
                          _buildVehicleCard(vehicle),
                          const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedSizeCard(String imagePath) {
    return SizedBox(
      width: _cardWidth,
      height: 180,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Image not found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
  if (vehicle.userId.isEmpty) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('Invalid lister ID')),
      ),
    );
  }

  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('users').doc(vehicle.userId).get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }
      if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
        print('Error fetching lister: ${snapshot.error ?? 'Lister not found'}');
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text('Error: ${snapshot.error ?? 'Lister not found'}')),
          ),
        );
      }

      final listerData = snapshot.data!.data() as Map<String, dynamic>;
      final listerName = listerData['name'] as String? ?? 'Unknown Lister';
      final listerLocation = listerData['location'] as String? ?? 'Unknown Location';
      final listerCoverPicture = listerData['coverPicture'] as String?;

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Shope(
                title: listerName,
                location: listerLocation,
                coverPicture: listerCoverPicture,
              ),
            ),
          );
        },
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  child: listerCoverPicture != null && listerCoverPicture.isNotEmpty
                      ? Image.memory(
                          base64Decode(listerCoverPicture),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error decoding lister cover image: $error');
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   vehicle.name,
                    //   style: const TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                    const SizedBox(height: 4),
                    Text(
                      listerName,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 36, 0, 0),
                         fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\Rs:${vehicle.pricePerDay.toStringAsFixed(2)}/day',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 70, 70, 70),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Color.fromARGB(255, 70, 70, 70),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listerLocation,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[300],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
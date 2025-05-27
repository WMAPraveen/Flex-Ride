import 'dart:ui';
import 'package:flex_ride/features/auth/screen/signin.dart';
import 'package:flex_ride/features/lister/add_vehicle_screen.dart';
import 'package:flex_ride/features/lister/edit_profile_screen.dart';
// Make sure the file path and class name are correct. If the class is named differently, update it accordingly.
import 'package:flex_ride/features/lister/vehicle_list_screen.dart';
import 'package:flex_ride/models/vehicle.dart' as vehicle_model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<vehicle_model.Vehicle> vehicles = [];
  int totalVehicles = 0;
  int rentedVehicles = 0;
  int availableVehicles = 0;
  int maintenanceVehicles = 0;
  bool _isMenuOpen = false;
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    Container(), // Placeholder for dashboard content
    AddVehicleScreen(),
    EditProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchVehicles(); // Fetch vehicles when the screen initializes
  }

  // Fetch vehicles from Firestore for the current user
  Future<void> _fetchVehicles() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You must be logged in to view vehicles')),
        );
        return;
      }

      final vehicleSnapshot =
          await FirebaseFirestore.instance
              .collection('vehicles')
              .where('userId', isEqualTo: user.uid)
              .get();
      final fetchedVehicles =
          vehicleSnapshot.docs
              .map((doc) => vehicle_model.Vehicle.fromJson(doc.data(), doc.id))
              .toList();

      setState(() {
        vehicles = fetchedVehicles;
        _updateVehicleStats();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching vehicles: $e')));
    }
  }

  void _navigateToAddVehicleScreen() async {
    final newVehicle = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddVehicleScreen()),
    );

    if (newVehicle != null && newVehicle is vehicle_model.Vehicle) {
      // Refresh the vehicle list from Firestore after adding a new vehicle
      await _fetchVehicles();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${newVehicle.name} added successfully')),
      );
    }
  }

  void _updateVehicleStats() {
    setState(() {
      totalVehicles = vehicles.length;
      rentedVehicles = vehicles.where((v) => v.isRented).length;
      availableVehicles =
          vehicles.where((v) => !v.isRented && !v.isUnderMaintenance).length;
      maintenanceVehicles = vehicles.where((v) => v.isUnderMaintenance).length;
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  List<FlSpot> getRentalData() {
    return [
      FlSpot(1, 2),
      FlSpot(5, 4),
      FlSpot(10, 3),
      FlSpot(15, 6),
      FlSpot(20, 5),
      FlSpot(25, 7),
      FlSpot(30, 4),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              'Welcome to Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No new notifications')),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: _toggleMenu,
              ),
            ],
          ),
          body:
              _currentIndex == 0
                  ? _buildDashboardContent()
                  : _tabs[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              if (index == 1) {
                _navigateToAddVehicleScreen(); // Handle "Add Vehicle" separately
              } else {
                setState(() => _currentIndex = index);
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle),
                label: 'Add Vehicle',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
        if (_isMenuOpen) ...[
          GestureDetector(
            onTap: () => setState(() => _isMenuOpen = false),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.black.withOpacity(0.3),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                padding: EdgeInsets.fromLTRB(20, 100, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMenuItem('Revenue Insights', Icons.pie_chart),
                    SizedBox(height: 20),
                    _buildMenuItem('Booking Management', Icons.calendar_today),
                    SizedBox(height: 20),
                    _buildMenuItem('Vehicle Status', Icons.car_rental),
                    SizedBox(height: 20),
                    _buildMenuItem('Customer Info', Icons.person_outline),
                    SizedBox(height: 20),
                    _buildMenuItem('Profile', Icons.account_circle),
                    Spacer(),
                    Divider(color: Colors.grey),
                    ListTile(
                      leading: Icon(Icons.arrow_back, color: Colors.black),
                      title: Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => setState(() => _isMenuOpen = false),
                    ),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => SignInScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildStatCard(
                'Total Vehicles',
                totalVehicles,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => VehicleListScreen(
                            vehicles: vehicles,
                            onEdit: (vehicle) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Edit feature not yet implemented',
                                  ),
                                ),
                              );
                            },
                            onDelete: (vehicle) async {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('vehicles')
                                    .doc(vehicle.id)
                                    .delete();
                                await _fetchVehicles(); // Refresh the vehicle list
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${vehicle.name} deleted'),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error deleting vehicle: $e'),
                                  ),
                                );
                              }
                            },
                          ),
                    ),
                  );
                },
              ),
              _buildStatCard('Rented Vehicles', rentedVehicles),
              _buildStatCard('Available Vehicles', availableVehicles),
              _buildStatCard('Maintenance Vehicles', maintenanceVehicles),
            ],
          ),
          SizedBox(height: 20),
          _buildChartCard(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.black,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        setState(() => _isMenuOpen = false);
        if (title == 'Profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProfileScreen()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$title selected')));
        }
      },
    );
  }

  Widget _buildChartCard() {
    return Card(
      color: Colors.black,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Rental Analysis',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(height: 270, child: _buildLineChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: getRentalData(),
            isCurved: true,
            barWidth: 2,
            color: Colors.greenAccent,
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) {
                final days = ['1', '5', '10', '15', '20', '25', '30'];
                if (days.contains(value.toInt().toString())) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine:
              (value) => FlLine(color: Colors.black, strokeWidth: 1),
          getDrawingVerticalLine:
              (value) => FlLine(color: Colors.black, strokeWidth: 0),
        ),
      ),
    );
  }
}

import 'package:flex_ride/features/auth/screen/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flex_ride/features/auth/screen/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomDrawer extends StatelessWidget {
  
  final VoidCallback? onLogout;

  const CustomDrawer({Key? key, this.onLogout}) : super(key: key);
  Future<String> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      return userDoc.data()?['name'] ?? 'User';
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 10),
                 FutureBuilder<String>(
  future: _getUserName(),
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

    final userName = snapshot.data ?? 'User';
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
        
        
      ],
    );
  },
),

                
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close the drawer

              // Get the current route
              final navigator = Navigator.of(context);
              final currentRoute = ModalRoute.of(context)?.settings.name;

              // If not on the home page, navigate to it
              if (currentRoute != '/home') {
                navigator.pushNamedAndRemoveUntil('/home', (route) => false);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Bookmarks'),
            onTap: () {
              Navigator.pop(context); // Close the drawer

              // Navigate to bookmarks
              Navigator.pop(context); // Close drawer first

              // Since we can't directly access private state (_HomeScreenState),
              // use a general approach
              final currentScaffold = Scaffold.of(context);
              try {
                // Try to use the existing scaffold
                currentScaffold.openEndDrawer(); // Close the drawer

                // Use Navigator to pop to first route and then push the bookmark page
                Navigator.of(context).popUntil((route) => route.isFirst);
                // Now manually handle bookmark navigation
                Navigator.of(context).pushNamed('/bookmarks');
              } catch (e) {
                // Fallback navigation
                Navigator.of(context).pushNamed('/bookmarks');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close the drawer

              // Navigate to profile
              Navigator.pop(context); // Close drawer first

              // Use a general approach instead of accessing private state
              try {
                // Navigate directly to profile
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              } catch (e) {
                // Fallback if push fails
                Navigator.of(context).pushNamed('/profile');
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close the drawer

              // Navigate to settings page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => Scaffold(
                        appBar: AppBar(
                          title: const Text('Settings'),
                          backgroundColor: Colors.black,
                        ),
                        body: const Center(child: Text('Settings Page')),
                      ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context); // Close the drawer

              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                         Navigator.of(context).pop();
                           // Close dialog
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignInScreen(),
                            ),
                          ); // Close dialog

                          // Use the provided logout callback if available
                          if (onLogout != null) {
                            onLogout!();
                          } else {
                            // Default logout behavior
                            FirebaseAuth.instance.signOut().then((_) {
                              // Navigate to login screen after logout
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            });
                          }
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _profileImage; // For mobile
  File? _coverImage; // For mobile
  Uint8List? _webProfileImage; // For web
  Uint8List? _webCoverImage; // For web
  String? _profileImageBase64; // Base64 for profile image
  String? _coverImageBase64; // Base64 for cover image
  final picker = ImagePicker();
  bool _isLoading = false;
  bool _isDataLoaded = false;
  bool _hasUnsavedChanges = false; // Track if there are unsaved changes

  // Initialize controllers without default text
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch user data when the screen initializes
    _loadUserData();

    // Add listeners to track changes
    _nameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _locationController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          setState(() {
            _nameController.text = data?['name'] ?? '';
            _emailController.text = data?['email'] ?? user.email ?? '';
            _locationController.text = data?['location'] ?? '';
            _bioController.text = data?['bio'] ?? '';
            _profileImageBase64 = data?['profilePicture'] ?? '';
            _coverImageBase64 = data?['coverPicture'] ?? '';

            // Load existing images if available
            if (_profileImageBase64 != null &&
                _profileImageBase64!.isNotEmpty) {
              try {
                _webProfileImage = base64Decode(_profileImageBase64!);
              } catch (e) {
                print('Error decoding profile image: $e');
                _profileImageBase64 = '';
              }
            }
            if (_coverImageBase64 != null && _coverImageBase64!.isNotEmpty) {
              try {
                _webCoverImage = base64Decode(_coverImageBase64!);
              } catch (e) {
                print('Error decoding cover image: $e');
                _coverImageBase64 = '';
              }
            }
            _isDataLoaded = true;
            _hasUnsavedChanges = false; // Reset after loading data
          });
        } else {
          // Handle case where document doesn't exist - create with basic info
          setState(() {
            _emailController.text = user.email ?? '';
            _profileImageBase64 = '';
            _coverImageBase64 = '';
            _isDataLoaded = true;
            _hasUnsavedChanges = false;
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isDataLoaded = true;
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage(bool isProfile) async {
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _hasUnsavedChanges = true; // Mark as changed when image is selected
        });

        if (kIsWeb) {
          var imageBytes = await pickedFile.readAsBytes();
          setState(() {
            if (isProfile) {
              _webProfileImage = imageBytes;
              _profileImageBase64 = base64Encode(imageBytes);
              _profileImage = null; // Clear mobile file
            } else {
              _webCoverImage = imageBytes;
              _coverImageBase64 = base64Encode(imageBytes);
              _coverImage = null; // Clear mobile file
            }
          });
        } else {
          setState(() {
            if (isProfile) {
              _profileImage = File(pickedFile.path);
              _webProfileImage = null; // Clear web bytes
            } else {
              _coverImage = File(pickedFile.path);
              _webCoverImage = null; // Clear web bytes
            }
          });

          // Convert to base64 for storage
          final file = isProfile ? _profileImage! : _coverImage!;
          List<int> imageBytes = await file.readAsBytes();
          setState(() {
            if (isProfile) {
              _profileImageBase64 = base64Encode(imageBytes);
            } else {
              _coverImageBase64 = base64Encode(imageBytes);
            }
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isProfile ? 'Profile image selected' : 'Cover image selected',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    // Validate input
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Email validation
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update Firestore document
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'location': _locationController.text.trim(),
            'bio': _bioController.text.trim(),
            'profilePicture': _profileImageBase64 ?? '',
            'coverPicture': _coverImageBase64 ?? '',
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true), // Merge to avoid overwriting existing fields
        );

        // Update password if provided
        if (_passwordController.text.trim().isNotEmpty) {
          if (_passwordController.text.trim().length < 6) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password must be at least 6 characters long'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }

          await user.updatePassword(_passwordController.text.trim());
          _passwordController.clear(); // Clear password field after update
        }

        // Mark changes as saved
        setState(() {
          _hasUnsavedChanges = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // User stays on the EditProfileScreen - no navigation
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No user is currently signed in'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Failed to update profile: $e');
      String errorMessage = 'Failed to update profile';

      if (e.toString().contains('weak-password')) {
        errorMessage = 'The password provided is too weak';
      } else if (e.toString().contains('requires-recent-login')) {
        errorMessage = 'Please log out and log back in to change your password';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && !_isDataLoaded) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        // appBar: AppBar(
        //   backgroundColor: Colors.black,
        //   title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
        //   iconTheme: IconThemeData(color: Colors.white),
        // ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
              SizedBox(height: 16),
              Text('Loading profile data...'),
            ],
          ),
        ),
      );
    }

    // Determine profile image to display
    ImageProvider? profileImageProvider;
    if (_profileImage != null) {
      profileImageProvider = FileImage(_profileImage!);
    } else if (_webProfileImage != null) {
      profileImageProvider = MemoryImage(_webProfileImage!);
    }

    // Determine cover image to display
    ImageProvider? coverImageProvider;
    if (_coverImage != null) {
      coverImageProvider = FileImage(_coverImage!);
    } else if (_webCoverImage != null) {
      coverImageProvider = MemoryImage(_webCoverImage!);
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Text('Edit Profile', style: TextStyle(color: Colors.white)),
            if (_hasUnsavedChanges) ...[
              SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Unsaved changes indicator
            if (_hasUnsavedChanges)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.orange[600], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'You have unsaved changes',
                      style: TextStyle(color: Colors.orange[800], fontSize: 14),
                    ),
                  ],
                ),
              ),

            // Cover and Profile Image Section
            Stack(
              children: [
                // Cover Image
                GestureDetector(
                  onTap: _isLoading ? null : () => _pickImage(false),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(12),
                      image:
                          coverImageProvider != null
                              ? DecorationImage(
                                image: coverImageProvider,
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        coverImageProvider == null
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add Cover Image',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                  ),
                ),
                // Profile Image
                Positioned(
                  bottom: -20,
                  left: 20,
                  child: GestureDetector(
                    onTap: _isLoading ? null : () => _pickImage(true),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: profileImageProvider,
                        child:
                            profileImageProvider == null
                                ? Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey[600],
                                )
                                : null,
                      ),
                    ),
                  ),
                ),
                // Camera icon for profile image
                if (profileImageProvider != null)
                  Positioned(
                    bottom: -10,
                    left: 65,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 40),

            // Form Fields
            _buildTextField(
              'Name *',
              _nameController,
              hintText: 'Enter your name',
            ),
            SizedBox(height: 16),
            _buildTextField(
              'Email *',
              _emailController,
              hintText: 'Enter your email',
            ),
            SizedBox(height: 16),
            _buildTextField(
              'Location',
              _locationController,
              hintText: 'Enter your location',
            ),
            SizedBox(height: 16),
            _buildTextField(
              'Password',
              _passwordController,
              obscure: true,
              hintText: 'Enter new password (optional)',
            ),
            SizedBox(height: 16),
            _buildTextField(
              'Bio Description',
              _bioController,
              maxLines: 3,
              hintText: 'Tell us about yourself',
            ),
            SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveChanges,
                icon:
                    _isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Icon(Icons.save),
                label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _hasUnsavedChanges ? Colors.black : Colors.grey[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    int maxLines = 1,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          maxLines: maxLines,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.black),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}

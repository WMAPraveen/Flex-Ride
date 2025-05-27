import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingPage extends StatefulWidget {
  final String title;
  final String location;
  final String? coverPicture;

  const RatingPage({
    Key? key,
    required this.title,
    required this.location,
    this.coverPicture,
  }) : super(key: key);

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String overviewText = 'Loading overview...';

  @override
  void initState() {
    super.initState();
    _fetchBioForOverview();
  }

  Future<void> _fetchBioForOverview() async {
    try {
      final query =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'lister')
              .where('name', isEqualTo: widget.title)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        setState(() {
          overviewText = data['bio'] ?? 'No overview provided.';
        });
      } else {
        setState(() {
          overviewText = 'Overview not available.';
        });
      }
    } catch (e) {
      setState(() {
        overviewText = 'Failed to load overview.';
      });
    }
  }

  void _showRatingPopup() {
    double rating = 0;
    String reviewText = "";

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Leave a Review',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 30,
                      itemBuilder:
                          (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (r) => rating = r,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) => reviewText = value,
                      decoration: InputDecoration(
                        hintText: 'Write your review...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: const Color.fromARGB(255, 211, 77, 77),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        if (rating > 0 && reviewText.isNotEmpty) {
                          final user = FirebaseAuth.instance.currentUser;
                          String userName = 'Anonymous';

                          if (user != null) {
                            final userDoc =
                                await _firestore
                                    .collection('users')
                                    .doc(user.uid)
                                    .get();
                            if (userDoc.exists) {
                              final userData = userDoc.data();
                              if (userData != null &&
                                  userData.containsKey('name')) {
                                userName = userData['name'];
                              }
                            }
                          }

                          await _firestore.collection('ratings').add({
                            'title': widget.title,
                            'location': widget.location,
                            'rating': rating,
                            'review': reviewText,
                            'userName': userName,
                            'timestamp': Timestamp.now(),
                          });

                          Navigator.of(context).pop();
                          setState(() {});
                        }
                      },
                      child: const Text('Submit Review'),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child:
                    coverImage != null
                        ? Image(
                          image: coverImage,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                        : Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Center(child: Text('No Cover Image')),
                        ),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "📍 ${widget.location}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              'Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(overviewText, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'User Reviews',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 240, 114, 114),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.rate_review),
                  label: const Text("Rate"),
                  onPressed: _showRatingPopup,
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('ratings')
                      .where('title', isEqualTo: widget.title)
                      //.orderBy('timestamp', descending: true) // requires index
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error loading reviews.');
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('No reviews yet.'),
                  );
                }

                return Column(
                  children:
                      snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(
                                    data['rating'].toInt(),
                                    (index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  data['review'] ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    '- ${data['userName'] ?? "Anonymous"}',
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

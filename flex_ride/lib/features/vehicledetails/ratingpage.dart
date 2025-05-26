import 'package:flutter/material.dart';

void main() {
  runApp(RatingPage());
}

class RatingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Danusha Rent Cars',
      theme: ThemeData.dark(),
      home: RatingPagePage(),
    );
  }
}

class RatingPagePage extends StatefulWidget {
  @override
  _RatingPagePageState createState() => _RatingPagePageState();
}

class _RatingPagePageState extends State<RatingPagePage> {
  int _selectedTabIndex = 0;

  void _showReviewDialog(BuildContext context) {
    int selectedStars = 0;
    TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Danusha Rent Cars"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedStars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedStars = index + 1;
                      });
                    },
                  );
                }),
              ),
              TextField(
                controller: reviewController,
                decoration: InputDecoration(
                  hintText: 'Share your own experience',
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              TextButton.icon(
                icon: Icon(Icons.add_photo_alternate),
                label: Text("Add photos & video"),
                onPressed: () {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Save review logic here
                Navigator.pop(context);
              },
              child: Text("Post"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.location_pin),
          title: Text('No 207/1 Kandalanda, Highlevel Road, Homagama 10206'),
        ),
        ListTile(
          leading: Icon(Icons.access_time),
          title: Text('Open 24 Hours'),
        ),
        ListTile(leading: Icon(Icons.phone), title: Text('077 123 6567')),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(Icons.star, color: Colors.amber);
          }),
        ),
        SizedBox(height: 10),
        Text("5.0 (1 review)"),
        SizedBox(height: 10),
        ListTile(
          leading: CircleAvatar(child: Text('P')),
          title: Text('Prasanna Wijesooriya'),
          subtitle: Text('★★★★★\n6 months ago'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _showReviewDialog(context),
          child: Text("Write a review"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Danusha rent cars")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              'https://images.pexels.com/photos/358070/pexels-photo-358070.jpeg',
              height: 180,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
            Text(
              "Danusha rent cars",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text("5.0 (01)"),
              ],
            ),
            Text("Car rental agency"),
            Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedTabIndex = 0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color:
                            _selectedTabIndex == 0 ? Colors.blue : Colors.grey,
                      ),
                      Text(
                        "Overview",
                        style: TextStyle(
                          color:
                              _selectedTabIndex == 0
                                  ? Colors.blue
                                  : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selectedTabIndex = 1),
                  child: Column(
                    children: [
                      Icon(
                        Icons.reviews,
                        color:
                            _selectedTabIndex == 1 ? Colors.red : Colors.grey,
                      ),
                      Text(
                        "Reviews",
                        style: TextStyle(
                          color:
                              _selectedTabIndex == 1 ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child:
                    _selectedTabIndex == 0
                        ? _buildOverviewSection()
                        : _buildReviewsSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileDetailPage extends StatefulWidget {
  final Map<String, dynamic> userProfile;

  ProfileDetailPage({required this.userProfile});

  @override
  _ProfileDetailPageState createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  bool isFriend = false;
  bool isFavorite = false;

  // Dummy function for starting messaging
  void _startMessaging() {
    // Add logic to start messaging
    // For demonstration purposes, a simple snackbar is shown here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Start messaging with ${widget.userProfile['displayName']}'),
      ),
    );
  }

  void _addToFriendsAndFavorites() {
    // Add logic to check if the user is already in friends and favorites
    // For demonstration purposes, a simple snackbar is shown here

    if (isFriend && isFavorite) {
      // If already a friend and favorite, show a snackbar or handle as needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User is already in your friends and favorites list.'),
        ),
      );
    } else {
      // If not a friend or favorite, add to friends and favorites
      setState(() {
        isFriend = true;
        isFavorite = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${widget.userProfile['displayName']} to friends and favorites'),
        ),
      );
    }
  }

  String _calculateAge(String dob) {
    if (dob.isNotEmpty) {
      DateTime birthDate = DateFormat('yyyy-MM-dd').parse(dob);
      DateTime now = DateTime.now();
      int age = now.year - birthDate.year - ((now.month > birthDate.month || (now.month == birthDate.month && now.day >= birthDate.day)) ? 0 : 1);

      return age.toString();
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.message),
            onPressed: _startMessaging,
          ),
          IconButton(
            icon: Icon(isFriend ? Icons.person : Icons.person_add),
            onPressed: () {
              // Check if the user is already a friend
              if (!isFriend) {
                // If not a friend, add to friends and favorites
                _addToFriendsAndFavorites();
              } else {
                // If already a friend, show a snackbar or handle as needed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User is already in your friends list.'),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              // Check if the user is already a favorite
              if (!isFavorite) {
                // If not a favorite, add to favorites
                setState(() {
                  isFavorite = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${widget.userProfile['displayName']} to favorites'),
                  ),
                );
              } else {
                // If already a favorite, show a snackbar or handle as needed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User is already in your favorites list.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.userProfile['photoURL'] ?? ''),
              radius: 50,
            ),
            SizedBox(height: 20),
            Text('Name: ${widget.userProfile['displayName'] ?? ''}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Gender: ${widget.userProfile['gender'] ?? ''}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Location: ${widget.userProfile['location'] ?? ''}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Age: ${_calculateAge(widget.userProfile['dob'] ?? '')}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Date of Birth: ${widget.userProfile['dob'] ?? ''}',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

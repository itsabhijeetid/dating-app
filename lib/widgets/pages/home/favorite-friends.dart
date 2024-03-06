import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/widgets/pages/home/profile-detail-page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FavoriteFriendsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Favorite Friends'),
    ),
    body: Material(
      child: FutureBuilder(
        // Fetch user's favorite friends from Firebase
        future: _getFavoriteFriends(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for data, show a loading indicator
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // If there is an error, display it
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.data!.isEmpty) {
            // If there are no favorite friends, display a message
            return Center(
              child: Text('No favorite friends found.'),
            );
          } else {
            // If data is available, display it using ListView.builder
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var user = snapshot.data![index];

                DateTime dob = DateFormat('yyyy-MM-dd').parse(user['dob']);
                Timestamp dobTimestamp = Timestamp.fromDate(dob);

                // Handle missing fields gracefully
                String displayName = user['displayName'] ?? 'User $index';
                String age = user['dob'] != null ? _calculateAge(dobTimestamp) : '';
                String location = user['location'] ?? '';
                String photoURL = user['photoURL'] ?? 'assets/images/default_user.jpg';

                return ListTile(
                  title: Text(displayName),
                  subtitle: Text('Age: $age, Location: $location'),
                  leading: CircleAvatar(
                    // Display the fetched profile photo or a default one
                    backgroundImage: photoURL.startsWith('http')
                        ? NetworkImage(photoURL as String)
                        : AssetImage(photoURL as String) as ImageProvider<Object>,
                  ),
                  onTap: () {
                    // Navigate to ProfileDetailPage with user profile data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileDetailPage(userProfile: user),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    ),
    );
  }

  // Function to calculate age from date of birth
  String _calculateAge(Timestamp dob) {
    DateTime now = DateTime.now();
    DateTime dateOfBirth = dob.toDate();
    int age = now.year -
        dateOfBirth.year -
        ((now.month > dateOfBirth.month ||
            (now.month == dateOfBirth.month && now.day >= dateOfBirth.day))
            ? 0
            : 1);
    return age.toString();
  }

  // Function to get the list of favorite friends
  Future<List<Map<String, dynamic>>> _getFavoriteFriends() async {
    try {
      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Use the current user's UID
        String currentUserUID = currentUser.uid;

        // Fetch the list of favorite friends from the favorites subcollection
        QuerySnapshot favoritesSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUID)
            .collection('favorites')
            .get();

        // Map the documents to a list of user data
        List<Map<String, dynamic>> favoriteFriendsList = favoritesSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        return favoriteFriendsList;
      } else {
        // Handle the case when there is no authenticated user
        print('No authenticated user found.');
        return [];
      }
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error fetching favorite friends: $e');
      return [];
    }
  }
}

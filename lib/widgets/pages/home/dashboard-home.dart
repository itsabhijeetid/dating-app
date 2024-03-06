import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/widgets/pages/home/profile-detail-page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatelessWidget {
  bool sortByLocation;
  bool sortByAge;

  Dashboard({
    Key? key,
    required this.sortByLocation,
    required this.sortByAge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      // Fetch the current user
      future: Future.value(FirebaseAuth.instance.currentUser),
      builder: (context, snapshotCurrentUser) {
        if (snapshotCurrentUser.connectionState == ConnectionState.waiting) {
          // While waiting for current user data, show a loading indicator
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        User? currentUser = snapshotCurrentUser.data;

        return FutureBuilder<QuerySnapshot>(
          // Fetch user data from Firebase collection named 'users'
          future: FirebaseFirestore.instance.collection('users').get(),
          builder: (context, snapshotUsers) {
            if (snapshotUsers.connectionState == ConnectionState.waiting) {
              // While waiting for data, show a loading indicator
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshotUsers.hasError) {
              // If there is an error, display it
              return Center(
                child: Text('Error: ${snapshotUsers.error}'),
              );
            } else if (snapshotUsers.data!.docs.isEmpty) {
              // If there are no users, display a message
              return Center(
                child: Text('No users found.'),
              );
            } else {
              // Sort the user list based on the selected sorting option
              List<Map<String, dynamic>> sortedUserList = snapshotUsers
                  .data!.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();

              // Filter out the current user's data
              sortedUserList = sortedUserList
                  .where((user) => user['userId'] != currentUser?.uid)
                  .toList();

              if (sortByLocation) {
                sortedUserList.sort(
                  (a, b) =>
                      (a['location'] ?? '').compareTo(b['location'] ?? ''),
                );
              } else if (sortByAge) {
                sortedUserList.sort((a, b) {
                  DateTime dobA = DateFormat('yyyy-MM-dd').parse(a['dob']);
                  DateTime dobB = DateFormat('yyyy-MM-dd').parse(b['dob']);
                  return dobA.compareTo(dobB);
                });
              }

              // If data is available, display it using ListView.builder
              return ListView.builder(
                itemCount: sortedUserList.length,
                itemBuilder: (context, index) {
                  var user = sortedUserList[index];

                  DateTime dob = DateFormat('yyyy-MM-dd').parse(user['dob']);
                  Timestamp dobTimestamp = Timestamp.fromDate(dob);

                  // Handle missing fields gracefully
                  String displayName = user['displayName'] ?? 'User $index';
                  String age =
                      user['dob'] != null ? _calculateAge(dobTimestamp) : '';
                  String location = user['location'] ?? '';
                  String photoURL =
                      user['photoURL'] ?? 'assets/images/default_user.jpg';

                  return ListTile(
                    title: Text(displayName),
                    subtitle: Text('Age: $age, Location: $location'),
                    leading: CircleAvatar(
                      // Display the fetched profile photo or a default one
                      backgroundImage: photoURL.startsWith('http')
                          ? NetworkImage(photoURL as String)
                          : AssetImage(photoURL as String)
                              as ImageProvider<Object>,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () {
                        // Add user to favorites
                        _addToFavorites(context, user);
                      },
                    ),
                    onTap: () {
                      // Navigate to ProfileDetailPage with user profile data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileDetailPage(userProfile: user),
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        );
      },
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

  // Function to add a user to the favorites list
  void _addToFavorites(BuildContext context, Map<String, dynamic> user) async {
    try {
      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Use the current user's UID
        String currentUserUID = currentUser.uid;

        // Create a reference to the user's favorites subcollection
        CollectionReference favoritesCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUID)
            .collection('favorites');

        // Check if the user is already in favorites
        QuerySnapshot existingFavorites = await favoritesCollection
            .where('userId', isEqualTo: user['userId'])
            .get();

        if (existingFavorites.docs.isEmpty) {
          // User is not in favorites, add to favorites
          await favoritesCollection.add(user);

          // Show a success message using SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User added to favorites successfully!'),
            ),
          );
        } else {
          // User is already in favorites, show a message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User is already in your favorites list.'),
            ),
          );
        }
      } else {
        // Handle the case when there is no authenticated user
        print('No authenticated user found.');
      }
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error adding user to favorites: $e');
    }
  }
}

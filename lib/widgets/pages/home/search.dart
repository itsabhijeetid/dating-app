import 'package:dating_app/widgets/pages/home/profile-detail-page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<Map<String, dynamic>> userList = [];
  List<Map<String, dynamic>> filteredUserList = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    QuerySnapshot<Map<String, dynamic>> usersSnapshot =
    await FirebaseFirestore.instance.collection('users').get();

    setState(() {
      userList = usersSnapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> doc) => doc.data()!)
          .toList();
      filteredUserList = userList;
    });
  }

  void _searchUsers(String query) {
    setState(() {
      filteredUserList = userList
          .where((user) =>
      user['displayName']
          .toLowerCase()
          .contains(query.toLowerCase()) ||
          user['location']
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _navigateToProfileDetail(Map<String, dynamic> userProfile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailPage(userProfile: userProfile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _searchUsers,
              decoration: InputDecoration(
                labelText: 'Search Users',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUserList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredUserList[index]['displayName'] ?? ''),
                  subtitle: Text(filteredUserList[index]['location'] ?? ''),
                  onTap: () {
                    _navigateToProfileDetail(filteredUserList[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

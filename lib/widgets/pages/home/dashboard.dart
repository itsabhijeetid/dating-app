import 'package:dating_app/widgets/pages/home/search.dart';
import 'package:dating_app/widgets/pages/profile/Profile.dart';
import 'package:flutter/material.dart';
import 'dashboard-home.dart';
import 'favorite-friends.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  // Declare sorting options
  bool sortByLocation = false;
  bool sortByAge = false;

  late List<Widget> _children;

  @override
  void initState() {
    super.initState();
    _children = [
      Dashboard(sortByLocation: sortByLocation, sortByAge: sortByAge),
      const Search(),
      ProfilePage(),
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Function to toggle sorting options
  void toggleSort(String option) {
    setState(() {
      sortByLocation = option == 'location' ? !sortByLocation : false;
      sortByAge = option == 'age' ? !sortByAge : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dating App'),
        actions: [
          if (_currentIndex == 1) // Show search icon only in the Search tab
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Search()),
                );
              },
            ),
          // Added sorting icons and functionality
          if (_currentIndex ==
              0) // Show sorting icons only in the Dashboard tab
            Row(
              children: [
                IconButton(
                  icon: Icon(
                      sortByLocation ? Icons.location_on : Icons.location_off),
                  onPressed: () => toggleSort('location'),
                ),
                IconButton(
                  icon: Icon(sortByAge ? Icons.sort : Icons.work_off),
                  onPressed: () => toggleSort('age'),
                ),
                IconButton(
                  icon: Icon(Icons.favorite),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FavoriteFriendsPage()),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

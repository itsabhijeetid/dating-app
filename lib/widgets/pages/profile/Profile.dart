import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:intl/intl.dart';
import 'dart:async';

import '../Login.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  late String _photoURL;
  final ImagePicker _imagePicker = ImagePicker();

  // Define the gender options
  List<String> _genderOptions = ['Male', 'Female', 'Others'];

  // List of Indian states
  List<String> _stateOptions = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana',
    'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Andaman and Nicobar Islands',
    'Chandigarh', 'Dadra and Nagar Haveli and Daman and Diu', 'Lakshadweep', 'Delhi', 'Puducherry',
  ];

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
      await _firestore.collection('users').doc(user.uid).get();

      setState(() {
        _user = user;
        _displayNameController.text = user.displayName ?? '';
        _photoURL = userDoc.data()?['photoURL'] ?? '';
        _dobController.text = userDoc.data()?['dob'] ?? '';
        _locationController.text = userDoc.data()?['location'] ?? '';
        _genderController.text = userDoc.data()?['gender'] ?? '';

        // Calculate age from date of birth
        _calculateAge();
      });
    }
  }

  void _calculateAge() {
    if (_dobController.text.isNotEmpty) {
      DateTime dob = DateFormat('yyyy-MM-dd').parse(_dobController.text);
      DateTime now = DateTime.now();
      int age = now.year -
          dob.year -
          (now.month > dob.month ||
              (now.month == dob.month && now.day >= dob.day)
              ? 0
              : 1);

      setState(() {
        _ageController.text = age.toString();
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      await _user!.updateDisplayName(_displayNameController.text);
      await _firestore.collection('users').doc(_user!.uid).set({
        'displayName': _displayNameController.text,
        'photoURL': _photoURL,
        'dob': _dobController.text,
        'location': _locationController.text,
        'gender': _genderController.text, // Add gender field
      });
      _getUser(); // Refresh user data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage =
    await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      await _uploadImage(pickedImage);
    }
  }

  Future<void> _uploadImage(XFile pickedImage) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_images/${_user!.uid}');
      await ref.putFile(File(pickedImage.path));
      String imageURL = await ref.getDownloadURL();

      setState(() {
        _photoURL = imageURL;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
        ),
      );
    }
  }

  Future<void> _pickDateOfBirth() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        _calculateAge(); // Recalculate age when date of birth is updated
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()), // Replace LoginPage with the actual login page class
              );

            },
          ),
        ],
      ),
      body: _user == null
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _photoURL.isNotEmpty
                            ? NetworkImage(_photoURL)
                            : null,
                        child: _photoURL.isEmpty
                            ? Icon(Icons.camera_alt, size: 50)
                            : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Welcome, ${_user!.displayName ?? 'User'}!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _displayNameController,
                      decoration:
                      InputDecoration(labelText: 'Display Name'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Date of Birth',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickDateOfBirth,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _dobController,
                          decoration:
                          InputDecoration(labelText: 'Date of Birth'),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Display age in read-only format
                    Text(
                      'Age: ${_ageController.text}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(),
                    SizedBox(height: 20),
                    Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    // DropdownButton for selecting gender
                    DropdownButtonFormField<String>(
                      value: _genderController.text.isEmpty
                          ? null
                          : _genderController.text,
                      onChanged: (String? newValue) {
                        setState(() {
                          _genderController.text = newValue ?? '';
                        });
                      },
                      items: _genderOptions
                          .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                          .toList(),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    // DropdownButton for selecting state
                    DropdownButtonFormField<String>(
                      value: _locationController.text.isEmpty
                          ? null
                          : _locationController.text,
                      onChanged: (String? newValue) {
                        setState(() {
                          _locationController.text = newValue ?? '';
                        });
                      },
                      items: _stateOptions
                          .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Update Profile'),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:dating_app/widgets/pages/Login.dart';
import 'package:dating_app/widgets/pages/Signup.dart';
import 'package:dating_app/widgets/pages/home/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dating App',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.deepPurple,
          onSurface: Colors.black,
        ),
        primaryColor: Colors.deepPurple, // Set the primary color
        primaryColorBrightness:
            Brightness.light, // Set the brightness of the primary color
        textTheme: TextTheme(
          bodyText1: TextStyle(
              color: Colors.black), // Set the text color on the primary color
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app_firebase/screens/notes_list.dart';
import 'login_screen.dart';
import 'package:shimmer/shimmer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), checkUser);
  }

  void checkUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NotesListScreen()),
      );
    } else {
      // User is not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Shimmer.fromColors(
          baseColor: const Color.fromARGB(255, 102, 101, 101),
          highlightColor: const Color.fromARGB(255, 214, 213, 213),
          child: Text(
            'Personal Notes',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

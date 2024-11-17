import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/screens/auth/login_screen.dart';
import 'package:hisaab_kitaab/screens/dashboards/userdashboard_screen.dart';
import 'package:hisaab_kitaab/screens/dashboards/admindashboard_screen.dart';

class SplashServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void isLogin(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user != null) {
      // Fetch user data from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      String username = userDoc['username'];
      String role = userDoc['role'];

      // Navigate to the appropriate dashboard without delay
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDashboardScreen(username: username),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserDashboardScreen(username: username),
          ),
        );
      }
    } else {
      // Navigate to LoginScreen after a short delay if the user is not logged in
      Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        ),
      );
    }
  }
}

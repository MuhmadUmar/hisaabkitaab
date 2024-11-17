import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hisaab_kitaab/screens/auth/login_screen.dart';
import 'package:hisaab_kitaab/screens/dashboards/userdashboard_screen.dart';
import 'package:hisaab_kitaab/screens/dashboards/admindashboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Check user authentication status
  final auth = FirebaseAuth.instance;
  final user = auth.currentUser;

  runApp(MyApp(user: user));
}

class MyApp extends StatelessWidget {
  final User? user;

  const MyApp({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hisaab Kitaab',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.white24,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: user != null ? UserOrAdminDashboard(user!) : const LoginScreen(),
    );
  }
}

class UserOrAdminDashboard extends StatelessWidget {
  final User user;

  const UserOrAdminDashboard(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for data
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          // Handle error
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (snapshot.hasData && snapshot.data!.exists) {
          String role = snapshot.data!['role'];
          String username = snapshot.data!['username'];

          // Navigate to the appropriate dashboard based on the role
          if (role == 'admin') {
            return AdminDashboardScreen(username: username);
          } else {
            return UserDashboardScreen(username: username);
          }
        } else {
          // Handle case where user document does not exist
          return Scaffold(
            body: Center(child: Text('User data not found')),
          );
        }
      },
    );
  }
}

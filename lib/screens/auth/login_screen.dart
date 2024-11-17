import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/screens/auth/forgot_password.dart';
import 'package:hisaab_kitaab/screens/auth/signup_screen.dart';
import 'package:hisaab_kitaab/screens/dashboards/admindashboard_screen.dart';
import 'package:hisaab_kitaab/screens/dashboards/userdashboard_screen.dart';
import 'package:hisaab_kitaab/utils/utils.dart';
import 'package:hisaab_kitaab/widgets/round_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;
  bool _obscureText = true;
  final _formkey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void login() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: emailController.text.toString(),
            password: passwordController.text.toString());

        // Fetch user data from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        String username = userDoc['username']; // Get username from Firestore
        String role = userDoc['role']; // Get role from Firestore

        if (role == 'admin') {
          Utils().toastMessage("Welcome Admin");
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminDashboardScreen(
                      username:
                          username))); // Assuming you have AdminDashboardScreen
        } else {
          Utils().toastMessage("Welcome user");
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => UserDashboardScreen(
                      username: username))); // Pass username here
        }
      } catch (error) {
        Utils().toastMessage(error.toString());
      } finally {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white24,
        automaticallyImplyLeading: false,
        title: const Text('LOG IN'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
                key: _formkey,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: const InputDecoration(
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.alternate_email)),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Email";
                        }
                        String pattern =
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                        RegExp regex = RegExp(pattern);
                        if (!regex.hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Password";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],
                )),
            const SizedBox(
              height: 10,
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen()));
                    },
                    child: const Text('Forgot Password?'))),
            const SizedBox(
              height: 10,
            ),
            RoundButton(
              title: 'Log in',
              loading: loading,
              onTap: () {
                login();
              },
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreen()));
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}

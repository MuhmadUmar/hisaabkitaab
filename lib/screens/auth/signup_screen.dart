import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/screens/auth/login_screen.dart';
import 'package:hisaab_kitaab/screens/dashboards/admindashboard_screen.dart';
import 'package:hisaab_kitaab/screens/dashboards/userdashboard_screen.dart';
import 'package:hisaab_kitaab/utils/utils.dart';
import 'package:hisaab_kitaab/widgets/round_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool loading = false;
  bool _obscureText = true;

  final _formkey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void signUp() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        loading = true;
      });

      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text.toString(),
          password: passwordController.text.toString(),
        );

        String umarEmail = 'malikumarmalik719@gmail.com';
        String userEmail = emailController.text.toString();
        String username = usernameController.text.toString();

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userEmail,
          'username': username, // Add the username here
          'role': userEmail == umarEmail ? 'admin' : 'user',
        });

        if (userEmail == umarEmail) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AdminDashboardScreen(username: username)),
          );
          Utils().toastMessage("Welcome Umar");
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => UserDashboardScreen(
                      username: username,
                    )),
          );
          Utils().toastMessage('Welcome $username');
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
        title: const Text(
          'SIGNUP',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
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
                      controller: usernameController,
                      decoration: const InputDecoration(
                        hintText: 'Username',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Username";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: const InputDecoration(
                          hintText: 'Email',
                          // helperText: 'john@gmail.com',
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
              height: 50,
            ),
            RoundButton(
              title: 'Sign up',
              loading: loading,
              onTap: () {
                signUp();
              },
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
                    },
                    child: const Text(
                      "Log in",
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

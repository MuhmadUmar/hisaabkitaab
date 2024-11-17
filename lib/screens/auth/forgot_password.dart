import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/utils/utils.dart';
import 'package:hisaab_kitaab/widgets/round_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: "Email",
              ),
            ),
            const SizedBox(height: 15),
            RoundButton(
                onTap: () {
                  auth
                      .sendPasswordResetEmail(email: emailController.text)
                      .then((onValue) {
                    Utils().toastMessage(
                        "We have sent you a password reset email");
                  }).onError(
                    (error, stackTrace) {
                      Utils().toastMessage(error.toString());
                    },
                  );
                },
                title: "Send OTP")
          ],
        ),
      ),
    );
  }
}

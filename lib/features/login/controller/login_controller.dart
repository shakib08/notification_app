import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      // Perform Firebase Authentication
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Navigate to the home screen
      Get.offAllNamed('/home');
    } catch (e) {
      // Show error dialog if login fails
      Get.dialog(
        AlertDialog(
          title: const Text("Login Failed"),
          content: const Text("Invalid email or password"),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }
}

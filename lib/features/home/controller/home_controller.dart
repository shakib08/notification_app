import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  TextEditingController message = TextEditingController();
  TextEditingController receiverEmail = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _verifyAndUpdateDeviceToken();
  }

  Future<void> _verifyAndUpdateDeviceToken() async {
    try {
      // Request notification permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get current user
        User? currentUser = _auth.currentUser;

        if (currentUser != null) {
          String? newDeviceToken = await _messaging.getToken();

          if (newDeviceToken != null) {
            // Fetch user data from Firestore
            DocumentSnapshot userDoc =
                await _firestore.collection("users").doc(currentUser.uid).get();

            String? existingDeviceToken = userDoc["device_token"];

            if (existingDeviceToken != newDeviceToken) {
              // Update Firestore with new device token
              await _firestore.collection("users").doc(currentUser.uid).update({
                "device_token": newDeviceToken,
              });
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating device token: $e");
      }
    }
  }

  Future<void> logoutUser() async {
    try {
      // Sign out user
      await _auth.signOut();

      // Navigate to login screen
      Get.offAllNamed('/login');
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text("Logout Failed"),
          content: Text(e.toString()),
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

  Future<void> sendMessage() async {
    try {
      String currentUserEmail = _auth.currentUser?.email ?? "";
      String receiver = receiverEmail.text.trim();
      String messageContent = message.text.trim();

      if (receiver.isEmpty || messageContent.isEmpty) {
        Get.dialog(
          AlertDialog(
            title: const Text("Error"),
            content: const Text("Please fill in all fields."),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }

      // Check if receiver email exists in Firestore
      QuerySnapshot userSnapshot = await _firestore
          .collection("users")
          .where("email", isEqualTo: receiver)
          .get();

      if (userSnapshot.docs.isEmpty) {
        // Email not found
        Get.dialog(
          AlertDialog(
            title: const Text("Error"),
            content: const Text("The email is not registered."),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        // Email exists, store message
        await _firestore.collection("messages").add({
          "date_and_time": DateTime.now().toIso8601String(),
          "sender_email": currentUserEmail,
          "receiver_email": receiver,
          "message": messageContent,
        });

        Get.dialog(
          AlertDialog(
            title: const Text("Success"),
            content: const Text("Message sent successfully."),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("OK"),
              ),
            ],
          ),
        );

        // Clear the input fields
        message.clear();
        receiverEmail.clear();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending message: $e");
      }
      Get.dialog(
        AlertDialog(
          title: const Text("Error"),
          content: Text("Failed to send the message. Please try again."),
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

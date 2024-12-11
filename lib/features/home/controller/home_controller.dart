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
}

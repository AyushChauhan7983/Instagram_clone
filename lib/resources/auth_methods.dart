import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/models/user.dart' as model;
import 'package:social_media_app/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user details from Firestore
  Future<model.User> getUserDetails() async {
    try {
      User currentUser = _auth.currentUser!;
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (snap.exists) {
        return model.User.fromSnap(snap);
      } else {
        throw Exception("User not found in database");
      }
    } catch (e) {
      throw Exception("Failed to fetch user details: $e");
    }
  }

  // Sign up user with email and password
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty &&
          file.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        model.User user = model.User(
          email: email,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          username: username,
          bio: bio,
          followers: [],
          following: [],
        );

        await _firestore.collection('users').doc(cred.user!.uid).set(
              user.toJson(),
            );
        return "success";
      } else {
        return "One or more fields are empty";
      }
    } catch (e) {
      return "Failed to sign up: $e";
    }
  }

  // Login user with email and password
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return "success";
      } else {
        return "Email or password is empty";
      }
    } catch (e) {
      return "Failed to log in: $e";
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

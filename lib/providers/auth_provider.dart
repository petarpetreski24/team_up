import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Add this import
import '../models/user.dart' as app;

class AuthProvider with ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  app.User? _currentUser;
  app.User? get currentUser => _currentUser;

  AuthProvider() {
    // Listen to authentication state changes
    _auth.authStateChanges().listen((firebase_auth.User? firebaseUser) {
      if (firebaseUser != null) {
        _fetchUserData(firebaseUser.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        _currentUser = app.User.fromMap({
          'id': uid,
          ...userDoc.data() ?? {},
        });
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _fetchUserData(userCredential.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final newUser = app.User(
          id: userCredential.user!.uid,
          name: name,
          email: email,
        );

        await _firestore.collection('users').doc(newUser.id).set({
          'name': name,
          'email': email,
          'sportsLevels': {},
          'hostedEvents': [],
          'participatedEvents': [],
        });

        _currentUser = newUser;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<void> updateProfile({
    required String name,
    required Map<String, String> sportsLevels,
  }) async {
    if (_currentUser == null || _auth.currentUser == null) {
      throw Exception('No user logged in');
    }

    try {
      final userRef = _firestore.collection('users').doc(_currentUser!.id);

      await userRef.update({
        'name': name,
        'sportsLevels': sportsLevels,
      });

      _currentUser = _currentUser!.copyWith(
        name: name,
        sportsLevels: Map<String, String>.from(sportsLevels),
      );

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<app.User?> getUserById(String id) async {
    try {
      final userDoc = await _firestore.collection('users').doc(id).get();

      if (userDoc.exists) {
        return app.User.fromMap({
          'id': id,
          ...userDoc.data() ?? {},
        });
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    if (_currentUser == null) {
      throw Exception('User not logged in');
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'profile_images/${_currentUser!.id}_$timestamp.jpg';

      final storageRef = _storage.ref().child(path);

      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      uploadTask.snapshotEvents.listen((taskSnapshot) {
        final progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
        print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      }, onError: (e) {
        print('Upload error: $e');
      });

      // Wait for the upload to complete
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _firestore.collection('users').doc(_currentUser!.id).update({
        'profileImageUrl': downloadUrl,
      });

      _currentUser = _currentUser!.copyWith(profileImageUrl: downloadUrl);
      notifyListeners();

      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase error uploading profile image: $e');
      if (e.code == 'object-not-found') {
        print('Storage bucket not found or inaccessible. Check Firebase Console.');
      }
      return null;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }
}
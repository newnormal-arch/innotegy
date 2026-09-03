import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<
  AuthService
>
authService = ValueNotifier(
  AuthService(),
);

class AuthService {
  // Define your authentication methods here
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<
    User?
  >
  get authStateChanges => firebaseAuth.authStateChanges();

  // Sign in with email and password

  // Future<
  //   UserCredential
  // >
  // signIn({
  //   required String email,
  //   required String password,
  // }) async {
  //   return await firebaseAuth.signInWithEmailAndPassword(
  //     email: email,
  //     password: password,
  //   );
  // }

  Future<
    UserCredential
  >
  signIn({
    required String email,
    required String password,
    required String requiredCollection, // e.g., 'farmer'
  }) async {
    // 1. Authenticate user credentials
    UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final String? uid = userCredential.user?.uid;

    if (uid ==
        null) {
      await firebaseAuth.signOut();
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Failed to retrieve user ID.',
      );
    }

    // 2. Check if document exists by UID
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection(
          requiredCollection,
        )
        .doc(
          uid,
        )
        .get();

    // Fallback: If document ID is not UID, query by email
    if (!userDoc.exists) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(
            requiredCollection,
          )
          .where(
            'email',
            isEqualTo: email,
          )
          .limit(
            1,
          )
          .get();

      if (querySnapshot.docs.isEmpty) {
        // 3. Document does not exist in this collection -> Revoke session
        await firebaseAuth.signOut();
        throw FirebaseAuthException(
          code: 'unauthorized-role',
          message: 'No record exists for this account.',
        );
      }
    }

    return userCredential;
  }

  // Sign up with email and password
  Future<
    UserCredential
  >
  signUp({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Save farmer data to Firestore
  Future<
    void
  >
  saveUserData({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    await FirebaseFirestore.instance
        .collection(
          'farmer',
        )
        .doc(
          firebaseAuth.currentUser!.uid,
        )
        .set(
          {
            'fullName': fullName,
            'email': email,
            'phone': phone,
            'status': 'inactive',
            'role': '',
            'allocatedFarm': '',
          },
        );
  }

  // Save manager data to Firestore
  Future<
    void
  >
  saveConsultantData({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    await FirebaseFirestore.instance
        .collection(
          'consultant',
        )
        .doc(
          firebaseAuth.currentUser!.uid,
        )
        .set(
          {
            'fullName': fullName,
            'email': email,
            'phone': phone,
            'role': '',
            'status': 'Inactive',
            'allocatedFarms': {
              '',
            },
          },
        );
  }

  // Save farmer data to Firestore
  Future<
    void
  >
  saveFarmData({
    required String farmName,
    required String farmArea,
    required String farmLocation,
    required String farmSize,
    required String farmOwner,
  }) async {
    await FirebaseFirestore.instance
        .collection(
          'farms',
        )
        .doc()
        .set(
          {
            'farmOwner': farmOwner,
            'farmName': farmName,
            'farmArea': farmArea,
            'farmLocation': farmLocation,
            'farmSize': farmSize,
            'farmStatus': 'Inactive',
            'allocatedFarmers': {
              'farmerName': '',
            },
          },
        );
  }

  // Sign out
  Future<
    void
  >
  signOut() async {
    await firebaseAuth.signOut();
  }

  // Reset password
  Future<
    void
  >
  resetPassword({
    required String email,
  }) async {
    await firebaseAuth.sendPasswordResetEmail(
      email: email,
    );
  }
}

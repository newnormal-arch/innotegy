import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthenticationService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth =
           auth ??
           FirebaseAuth.instance,
       _firestore =
           firestore ??
           FirebaseFirestore.instance;

  /// Expose current user stream for auth state listening
  Stream<
    User?
  >
  get authStateChanges => _auth.authStateChanges();

  /// Expose current user object
  User? get currentUser => _auth.currentUser;

  /// Sign Up with Email, Password & Metadata
  Future<
    UserCredential
  >
  signUpWithEmailAndPassword({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // 1. Create User in Firebase Auth
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;

      if (user !=
          null) {
        // Update Firebase Auth Display Name
        await user.updateDisplayName(
          fullName.trim(),
        );

        final now = FieldValue.serverTimestamp();

        // 2. Write User Metadata to Firestore 'users' collection
        await _firestore
            .collection(
              'users',
            )
            .doc(
              user.uid,
            )
            .set(
              {
                'uid': user.uid,
                'fullName': fullName.trim(),
                'email': email.trim(),
                'phoneNumber': phoneNumber.trim(),
                'isActive': false, // Default inactive status
                'userRole': '', // Blank role for future RBAC setup
                'farms':
                    <
                      String
                    >[], // Array of assigned farm names from Google My Maps
                'createdAt': now,
                'lastLoginAt': now,
              },
            );
      }

      return credential;
    } on FirebaseAuthException catch (
      e
    ) {
      throw _handleAuthException(
        e,
      );
    } catch (
      e
    ) {
      throw Exception(
        'An unexpected error occurred during sign up: $e',
      );
    }
  }

  /// Sign In with Email and Password
  Future<
    UserCredential
  >
  signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;

      if (user !=
          null) {
        // Update last logged on timestamp in Firestore
        await _firestore
            .collection(
              'users',
            )
            .doc(
              user.uid,
            )
            .update(
              {
                'lastLoginAt': FieldValue.serverTimestamp(),
              },
            );
      }

      return credential;
    } on FirebaseAuthException catch (
      e
    ) {
      throw _handleAuthException(
        e,
      );
    } catch (
      e
    ) {
      throw Exception(
        'An unexpected error occurred during sign in: $e',
      );
    }
  }

  /// Password Reset Request
  Future<
    void
  >
  sendPasswordResetEmail(
    String email,
  ) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (
      e
    ) {
      throw _handleAuthException(
        e,
      );
    } catch (
      e
    ) {
      throw Exception(
        'An unexpected error occurred while sending reset email: $e',
      );
    }
  }

  /// Assign a single farm by name (pulled from Google My Maps)
  Future<
    void
  >
  assignFarmToUser(
    String uid,
    String farmName,
  ) async {
    try {
      await _firestore
          .collection(
            'users',
          )
          .doc(
            uid,
          )
          .update(
            {
              'farms': FieldValue.arrayUnion(
                [
                  farmName,
                ],
              ),
            },
          );
    } catch (
      e
    ) {
      throw Exception(
        'Failed to assign farm to user: $e',
      );
    }
  }

  /// Remove a farm by name from user
  Future<
    void
  >
  removeFarmFromUser(
    String uid,
    String farmName,
  ) async {
    try {
      await _firestore
          .collection(
            'users',
          )
          .doc(
            uid,
          )
          .update(
            {
              'farms': FieldValue.arrayRemove(
                [
                  farmName,
                ],
              ),
            },
          );
    } catch (
      e
    ) {
      throw Exception(
        'Failed to remove farm from user: $e',
      );
    }
  }

  /// Update the entire farm names array for a user
  Future<
    void
  >
  updateUserFarms(
    String uid,
    List<
      String
    >
    farmNames,
  ) async {
    try {
      await _firestore
          .collection(
            'users',
          )
          .doc(
            uid,
          )
          .update(
            {
              'farms': farmNames,
            },
          );
    } catch (
      e
    ) {
      throw Exception(
        'Failed to update user farms: $e',
      );
    }
  }

  /// Sign Out
  Future<
    void
  >
  signOut() async {
    await _auth.signOut();
  }

  /// Helper to convert Firebase Auth exceptions to user-friendly messages
  String _handleAuthException(
    FirebaseAuthException e,
  ) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email address is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/Password sign in is not enabled.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ??
            'An authentication error occurred.';
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final authControllerProvider = Provider((ref) => AuthController());

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      // PESAN ERROR MANTAP
      switch (e.code) {
        case 'user-not-found': return 'No account found with this email.';
        case 'wrong-password': return 'Incorrect password. Please try again.';
        case 'invalid-email': return 'The email address is not valid.';
        case 'user-disabled': return 'This user account has been disabled.';
        default: return 'Authentication failed. Please check your credentials.';
      }
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use': return 'This email is already registered.';
        case 'weak-password': return 'The password is too weak. Try a stronger one.';
        case 'invalid-email': return 'Please provide a valid email address.';
        default: return 'Registration failed. Please try again later.';
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
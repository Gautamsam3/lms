import 'package:firebase_auth/firebase_auth.dart';
import '../utils/user_data.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update user data
      if (result.user != null) {
        String displayName = result.user!.displayName ?? 
            email.split('@')[0].replaceAll('.', ' ').split(' ')
                .map((word) => word[0].toUpperCase() + word.substring(1))
                .join(' ');
        
        UserData.updateUser(
          name: displayName,
          email: email,
        );
      }
      
      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        default:
          return 'Login failed. Please try again.';
      }
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  // Register with email and password
  Future<String?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user!.updateDisplayName(name);
      
      // Update user data
      UserData.updateUser(
        name: name,
        email: email,
      );

      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'Invalid email address.';
        default:
          return 'Registration failed. Please try again.';
      }
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  // Reset password
  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'invalid-email':
          return 'Invalid email address.';
        default:
          return 'Failed to send reset email. Please try again.';
      }
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    UserData.clearUser();
  }
}
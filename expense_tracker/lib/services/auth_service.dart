import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to listen for auth state changes
  Stream<User?> get user => _auth.authStateChanges();

  // Register a user but DO NOT keep them logged in.
  Future<bool> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (result.user != null) {
        await _auth.signOut(); // Force user to log in after registering
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      print('Registration failed: ${e.message}');
      return false;
    }
  }

  // Sign In with Email & Password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Sign in failed: ${e.message}');
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- NEW METHOD: Send Password Reset Email ---
  /// Sends a password reset link to the current user's email.
  /// Returns true on success, false on failure.
  Future<bool> sendPasswordResetEmail() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      // Cannot send reset email if not logged in or no email exists
      return false;
    }
    try {
      await _auth.sendPasswordResetEmail(email: user.email!);
      print('Password reset email sent to ${user.email}');
      return true;
    } catch (e) {
      print('Error sending password reset email: $e');
      return false;
    }
  }

  // --- NEW METHOD: Delete User Account ---
  /// Deletes the current user's Firebase Auth account.
  /// Returns true on success, false on failure.
  /// NOTE: This does NOT delete their Firestore data. That's a more complex operation.
  Future<bool> deleteUserAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      return false; // Not logged in
    }
    try {
      await user.delete();
      print('User account deleted successfully.');
      // The AuthGate will automatically handle navigation to the LoginScreen.
      return true;
    } on FirebaseAuthException catch (e) {
      // This is a common security error. Firebase requires the user to have
      // logged in recently to perform sensitive actions like deletion.
      if (e.code == 'requires-recent-login') {
        print('User needs to re-authenticate to delete their account.');
        // In a production app, you would prompt the user to log in again here.
        // For now, we just print the error.
      } else {
        print('Error deleting user account: ${e.message}');
      }
      return false;
    }
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_home_pro/services/firebase_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ✅ Authorized email - Sirf yahi email access kar sakta hai
  static const String _authorizedEmail = 'ahsansaleem123@gmail.com';

  // Check if user is authorized
  static bool isAuthorizedUser(User? user) {
    if (user == null) return false;
    return user.email?.toLowerCase() == _authorizedEmail.toLowerCase();
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Stream of auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  static Future<User?> registerWithEmailPassword(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();
      
      // Save user data to Realtime Database
      if (userCredential.user != null) {
        await FirebaseService.database.child('users/${userCredential.user!.uid}').set({
          'displayName': name,
          'email': email.trim(),
          'createdAt': DateTime.now().toIso8601String(),
          'isAuthorized': email.trim().toLowerCase() == _authorizedEmail.toLowerCase(),
        });
      }
      
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  // Login with email and password
  static Future<User?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Update last login
      if (userCredential.user != null) {
        await FirebaseService.database
            .child('users/${userCredential.user!.uid}')
            .update({'lastLogin': DateTime.now().toIso8601String()});
      }
      
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  // Sign in with Google
  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Save user data if new user
      final userSnapshot = await FirebaseService.database
          .child('users/${userCredential.user!.uid}')
          .once();
      
      if (userSnapshot.snapshot.value == null && userCredential.user != null) {
        await FirebaseService.database.child('users/${userCredential.user!.uid}').set({
          'displayName': userCredential.user!.displayName ?? '',
          'email': userCredential.user!.email ?? '',
          'createdAt': DateTime.now().toIso8601String(),
          'isAuthorized': userCredential.user!.email?.toLowerCase() == _authorizedEmail.toLowerCase(),
        });
      }
      
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  // Send password reset email
  static Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Logout
  static Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Get error message
  static String getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-not-found':
        return 'No account found with this email.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
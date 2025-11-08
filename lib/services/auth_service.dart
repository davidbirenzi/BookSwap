import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

// Auth service - handles Firebase Authentication operations
// This is where we actually talk to Firebase Auth
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream that notifies when user signs in/out
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Create a new user account
  Future<AppUser?> signUp(String email, String password, String name) async {
    try {
      // Create the Firebase Auth account
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Send verification email
        await result.user!.sendEmailVerification();
        
        // Create our custom user object
        AppUser user = AppUser(
          id: result.user!.uid,
          email: email,
          name: name,
          emailVerified: false, // they need to verify first
        );
        
        // Save user data to Firestore
        await _firestore.collection('users').doc(result.user!.uid).set(user.toMap());
        return user;
      }
    } catch (e) {
      rethrow; // let the UI handle the error
    }
    return null;
  }

  // Sign in existing user
  Future<AppUser?> signIn(String email, String password) async {
    try {
      // Authenticate with Firebase
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null && result.user!.emailVerified) {
        // Get user data from Firestore
        DocumentSnapshot doc = await _firestore.collection('users').doc(result.user!.uid).get();
        return AppUser.fromMap(doc.data() as Map<String, dynamic>, result.user!.uid);
      } else if (result.user != null && !result.user!.emailVerified) {
        // Don't let unverified users sign in
        throw 'Please verify your email before signing in';
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  // Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user data (if signed in and verified)
  Future<AppUser?> getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null && user.emailVerified) {
      // Fetch user data from Firestore
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      return AppUser.fromMap(doc.data() as Map<String, dynamic>, user.uid);
    }
    return null; // not signed in or not verified
  }
}
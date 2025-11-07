import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser?> signUp(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        await result.user!.sendEmailVerification();
        
        AppUser user = AppUser(
          id: result.user!.uid,
          email: email,
          name: name,
          emailVerified: false,
        );
        
        await _firestore.collection('users').doc(result.user!.uid).set(user.toMap());
        return user;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<AppUser?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null && result.user!.emailVerified) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(result.user!.uid).get();
        return AppUser.fromMap(doc.data() as Map<String, dynamic>, result.user!.uid);
      } else if (result.user != null && !result.user!.emailVerified) {
        throw 'Please verify your email before signing in';
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AppUser?> getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null && user.emailVerified) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      return AppUser.fromMap(doc.data() as Map<String, dynamic>, user.uid);
    }
    return null;
  }
}
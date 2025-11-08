import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// Auth provider - manages user authentication state across the app
// Uses Provider pattern to notify widgets when auth state changes
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  AppUser? _user; // currently logged in user
  bool _isLoading = false; // tracks if auth operation is in progress

  // Getters for other widgets to access auth state
  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // Constructor - sets up listener for auth state changes
  AuthProvider() {
    // Listen to Firebase auth changes and update our user accordingly
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null && firebaseUser.emailVerified) {
        // User is signed in and verified, get their profile data
        _user = await _authService.getCurrentUser();
      } else {
        // User is signed out or not verified
        _user = null;
      }
      notifyListeners(); // tell widgets to rebuild
    });
  }

  // Sign up a new user
  Future<void> signUp(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners(); // show loading state
    
    try {
      _user = await _authService.signUp(email, password, name);
    } catch (e) {
      rethrow; // let the UI handle the error
    } finally {
      _isLoading = false;
      notifyListeners(); // hide loading state
    }
  }

  // Sign in existing user
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _user = await _authService.signIn(email, password);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out current user
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null; // clear user data
    notifyListeners(); // update UI
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

// Main entry point of the BookSwap application
// Sets up Firebase and Provider state management
void main() async {
  // Ensure Flutter binding is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Start the app
  runApp(BookSwapApp());
}

// Root widget that sets up state management and routing
class BookSwapApp extends StatelessWidget {
  const BookSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    // STATE MANAGEMENT SETUP:
    // ChangeNotifierProvider wraps the entire app to provide AuthProvider
    // This allows any widget in the app to access authentication state
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(), // Create AuthProvider instance
      child: MaterialApp(
        title: 'BookSwap',
        theme: AppTheme.theme, // Custom app theme
        debugShowCheckedModeBanner: false, // Hide debug banner
        
        // REACTIVE ROUTING:
        // Consumer listens to AuthProvider changes and rebuilds when needed
        // This automatically switches between login and home screens
        home: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            // Show HomeScreen if user is authenticated, LoginScreen otherwise
            // This rebuilds automatically when auth.isAuthenticated changes
            return auth.isAuthenticated ? HomeScreen() : LoginScreen();
          },
        ),
      ),
    );
  }
}

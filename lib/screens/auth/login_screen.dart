import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'signup_screen.dart';

// Login screen - where existing users sign in
// First screen users see when opening the app
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // for form validation
  final _emailController = TextEditingController(); // email input
  final _passwordController = TextEditingController(); // password input

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0E0E2C), // dark blue background
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                // App logo and branding
                Icon(Icons.menu_book, size: 80, color: Color(0xFFF5C841)), // yellow book icon
                SizedBox(height: 24),
                Text('BookSwap', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Swap Your Books With Other Students', 
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text('Sign in to get started', 
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                SizedBox(height: 48),
                // Email input field
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => value?.isEmpty ?? true ? 'Enter email' : null,
                ),
                SizedBox(height: 16),
                // Password input field
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                  ),
                  obscureText: true, // hide password text
                  textInputAction: TextInputAction.done,
                  // Allow signing in by pressing Enter
                  onFieldSubmitted: (_) async {
                    if (_formKey.currentState!.validate()) {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await context.read<AuthProvider>().signIn(_emailController.text, _passwordController.text);
                      } catch (e) {
                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                    }
                  },
                  validator: (value) => value?.isEmpty ?? true ? 'Enter password' : null,
                ),
                SizedBox(height: 24),
                SizedBox(height: 40),
                // Sign in button - shows loading spinner when authenticating
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return auth.isLoading
                        ? CircularProgressIndicator(color: Color(0xFFF5C841)) // show spinner
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final messenger = ScaffoldMessenger.of(context);
                                  try {
                                    await auth.signIn(_emailController.text, _passwordController.text);
                                  } catch (e) {
                                    if (mounted) {
                                      messenger.showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  }
                                }
                              },
                              child: Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          );
                  },
                ),
                // Link to sign up screen for new users
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen()));
                  },
                  child: Text('Don\'t have an account? Sign Up', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
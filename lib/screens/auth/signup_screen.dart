import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0E0E2C),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              Icon(Icons.menu_book, size: 60, color: Color(0xFFF5C841)),
              SizedBox(height: 16),
              Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Name',
                  prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => value?.isEmpty ?? true ? 'Enter name' : null,
              ),
              SizedBox(height: 16),
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
              TextFormField(
                controller: _passwordController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) async {
                  if (_formKey.currentState!.validate()) {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await context.read<AuthProvider>().signUp(_emailController.text, _passwordController.text, _nameController.text);
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('Verification email sent! Please check your email.')),
                        );
                        navigator.pop();
                      }
                    } catch (e) {
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  }
                },
                validator: (value) => (value?.length ?? 0) < 6 ? 'Password must be 6+ characters' : null,
              ),
              SizedBox(height: 24),
              SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return auth.isLoading
                      ? CircularProgressIndicator(color: Color(0xFFF5C841))
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final navigator = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  await auth.signUp(_emailController.text, _passwordController.text, _nameController.text);
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      SnackBar(content: Text('Verification email sent! Please check your email.')),
                                    );
                                    navigator.pop();
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              }
                            },
                            child: Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        );
                },
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
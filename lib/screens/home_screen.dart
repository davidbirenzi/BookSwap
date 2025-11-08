import 'package:flutter/material.dart';
import 'browse_listings_screen.dart';
import 'my_listings_screen.dart';
import 'chats_screen.dart';
import 'settings_screen.dart';

// Main home screen with bottom navigation
// This is what users see after logging in
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // tracks which tab is selected
  
  // List of screens for each tab
  final List<Widget> _screens = [
    BrowseListingsScreen(), // tab 0: browse all books
    MyListingsScreen(),     // tab 1: manage your own books
    ChatsScreen(),          // tab 2: chat with other students
    SettingsScreen(),       // tab 3: profile and settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // show the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index), // switch tabs
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Books'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), label: 'My Listings'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
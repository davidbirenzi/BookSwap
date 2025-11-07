import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../services/database_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/book_card.dart';
import 'add_book_screen.dart';

class MyListingsScreen extends StatelessWidget {
  final DatabaseService _databaseService = DatabaseService();

  MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('My Books'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AddBookScreen()));
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Book>>(
        stream: _databaseService.getUserBooks(authProvider.user?.id ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No books listed yet', style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AddBookScreen()));
                    },
                    child: Text('Add Your First Book'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Book book = snapshot.data![index];
              return BookCard(
                book: book,
                actionButton: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _editBook(context, book),
                      child: Text('Edit'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _deleteBook(context, book.id),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _editBook(BuildContext context, Book book) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddBookScreen(book: book)));
  }

  void _deleteBook(BuildContext context, String bookId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Book'),
        content: Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
        ],
      ),
    );
    
    if (confirm == true) {
      await _databaseService.deleteBook(bookId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book deleted')),
      );
    }
  }
}
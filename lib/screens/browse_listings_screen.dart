import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/swap.dart';
import '../services/database_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/book_card.dart';

class BrowseListingsScreen extends StatelessWidget {
  final DatabaseService _databaseService = DatabaseService();

  BrowseListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: Text('Browse Listings', style: TextStyle(fontWeight: FontWeight.bold))),
      body: StreamBuilder<List<Book>>(
        stream: _databaseService.getBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No books available', style: TextStyle(color: Colors.black)));
          }
          
          List<Book> books = snapshot.data!;
          
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              Book book = books[index];
              return BookCard(
                book: book,
                actionButton: book.ownerId == authProvider.user?.id
                    ? null
                    : ElevatedButton(
                        onPressed: () => _initiateSwap(context, book, authProvider.user!),
                        child: Text('Request Swap'),
                      ),
              );
            },
          );
        },
      ),
    );
  }

  void _initiateSwap(BuildContext context, Book book, user) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      Swap swap = Swap(
        id: '',
        bookId: book.id,
        bookTitle: book.title,
        senderId: user.id,
        senderName: user.name,
        receiverId: book.ownerId,
        receiverName: book.ownerName,
        status: SwapStatus.pending,
        createdAt: DateTime.now(),
      );
      
      await _databaseService.createSwap(swap);
      messenger.showSnackBar(
        SnackBar(content: Text('Swap request sent!')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error sending swap request')),
      );
    }
  }
}
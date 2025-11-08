import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/swap.dart';
import '../services/database_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/book_card.dart';
import 'add_book_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  MyListingsScreenState createState() => MyListingsScreenState();
}

class MyListingsScreenState extends State<MyListingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Listings'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AddBookScreen()));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFFF5C841),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'My Books'),
            Tab(text: 'My Offers'),
            Tab(text: 'Incoming'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyBooksTab(),
          _buildMyOffersTab(),
          _buildIncomingTab(),
        ],
      ),
    );
  }

  Widget _buildMyBooksTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return StreamBuilder<List<Book>>(
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
                Text('No books listed yet', style: TextStyle(color: Colors.black, fontSize: 18)),
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
    );
  }

  Widget _buildMyOffersTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return StreamBuilder<List<Swap>>(
      stream: _databaseService.getUserSwaps(authProvider.user?.id ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No offers sent yet', style: TextStyle(color: Colors.black, fontSize: 18)),
          );
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Swap swap = snapshot.data![index];
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Book: ${swap.bookTitle}', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('To: ${swap.receiverName}'),
                    Text('Status: ${swap.status.name}', 
                      style: TextStyle(color: _getStatusColor(swap.status))),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIncomingTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return StreamBuilder<List<Swap>>(
      stream: _databaseService.getReceivedSwaps(authProvider.user?.id ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No incoming offers', style: TextStyle(color: Colors.black, fontSize: 18)),
          );
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Swap swap = snapshot.data![index];
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Book: ${swap.bookTitle}', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('From: ${swap.senderName}'),
                    Text('Status: ${swap.status.name}', 
                      style: TextStyle(color: _getStatusColor(swap.status))),
                    if (swap.status == SwapStatus.pending) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _updateSwapStatus(swap.id, SwapStatus.accepted),
                            child: Text('Accept'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _updateSwapStatus(swap.id, SwapStatus.rejected),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: Text('Reject', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(SwapStatus status) {
    switch (status) {
      case SwapStatus.pending:
        return Colors.orange;
      case SwapStatus.accepted:
        return Colors.green;
      case SwapStatus.rejected:
        return Colors.red;
    }
  }

  void _updateSwapStatus(String swapId, SwapStatus status) async {
    await _databaseService.updateSwapStatus(swapId, status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Swap ${status.name.toLowerCase()}')),
      );
    }
  }

  void _editBook(BuildContext context, Book book) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddBookScreen(book: book)));
  }

  void _deleteBook(BuildContext context, String bookId) async {
    final messenger = ScaffoldMessenger.of(context);
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
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Book deleted')),
        );
      }
    }
  }
}
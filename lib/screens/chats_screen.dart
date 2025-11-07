import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/swap.dart';
import '../services/database_service.dart';
import '../providers/auth_provider.dart';
import 'chat_detail_screen.dart';
import 'sample_chat_screen.dart';

class ChatsScreen extends StatelessWidget {
  final DatabaseService _databaseService = DatabaseService();

  ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.preview),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SampleChatScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Swap>>(
        stream: _databaseService.getUserSwaps(authProvider.user?.id ?? ''),
        builder: (context, sentSnapshot) {
          return StreamBuilder<List<Swap>>(
            stream: _databaseService.getReceivedSwaps(authProvider.user?.id ?? ''),
            builder: (context, receivedSnapshot) {
              if (sentSnapshot.connectionState == ConnectionState.waiting ||
                  receivedSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              List<Swap> allSwaps = [
                ...(sentSnapshot.data ?? []),
                ...(receivedSnapshot.data ?? []),
              ];
              
              if (allSwaps.isEmpty) {
                return Center(
                  child: Text('No chats yet', style: TextStyle(color: Colors.black, fontSize: 18)),
                );
              }
              
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: allSwaps.length,
                itemBuilder: (context, index) {
                  Swap swap = allSwaps[index];
                  bool isSender = swap.senderId == authProvider.user?.id;
                  String otherUserName = isSender ? swap.receiverName : swap.senderName;
                  
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text('Chat with $otherUserName', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Book: ${swap.bookTitle}', style: TextStyle(color: Colors.black54)),
                          Text('Status: ${swap.status.name}', style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.black54),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailScreen(swap: swap),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
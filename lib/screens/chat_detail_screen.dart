import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/swap.dart';
import '../models/message.dart';
import '../services/database_service.dart';
import '../providers/auth_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final Swap swap;
  
  const ChatDetailScreen({super.key, required this.swap});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    bool isSender = widget.swap.senderId == authProvider.user?.id;
    String otherUserName = isSender ? widget.swap.receiverName : widget.swap.senderName;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(otherUserName),
        actions: [
          if (!isSender && widget.swap.status == SwapStatus.Pending)
            PopupMenuButton<String>(
              onSelected: (value) => _updateSwapStatus(SwapStatus.values.firstWhere((s) => s.name == value)),
              itemBuilder: (context) => [
                PopupMenuItem(value: 'Accepted', child: Text('Accept Swap')),
                PopupMenuItem(value: 'Rejected', child: Text('Reject Swap')),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Color(0xFFF5C841),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Book: ${widget.swap.bookTitle}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      Text('Status: ${widget.swap.status.name}', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _databaseService.getMessages(widget.swap.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                List<Message> messages = snapshot.data ?? [];
                
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Message message = messages[index];
                    bool isMe = message.senderId == authProvider.user?.id;
                    
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Color(0xFFF5C841) : Color(0xFF0E0E2C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(message.text, style: TextStyle(color: isMe ? Colors.black : Colors.white)),
                            SizedBox(height: 4),
                            Text(
                              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _sendMessage,
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    Message message = Message(
      id: _uuid.v4(),
      chatId: widget.swap.id,
      senderId: authProvider.user!.id,
      senderName: authProvider.user!.name,
      text: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );
    
    await _databaseService.sendMessage(message);
    _messageController.clear();
  }

  void _updateSwapStatus(SwapStatus status) async {
    await _databaseService.updateSwapStatus(widget.swap.id, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Swap ${status.name.toLowerCase()}')),
    );
  }
}
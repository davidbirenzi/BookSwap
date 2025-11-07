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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    bool isSender = widget.swap.senderId == authProvider.user?.id;
    String otherUserName = isSender ? widget.swap.receiverName : widget.swap.senderName;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0E0E2C),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFF5C841),
              child: Text(
                otherUserName[0].toUpperCase(),
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserName,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Book: ${widget.swap.bookTitle}',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!isSender && widget.swap.status == SwapStatus.Pending)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white),
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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0E0E2C), Color(0xFF1A1A3A)],
                ),
              ),
              child: StreamBuilder<List<Message>>(
                stream: _databaseService.getMessages(widget.swap.id),
                builder: (context, snapshot) {
                  print('Chat ID: ${widget.swap.id}');
                  print('Connection State: ${snapshot.connectionState}');
                  print('Has Error: ${snapshot.hasError}');
                  if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                  }
                  print('Messages Count: ${snapshot.data?.length ?? 0}');
                  
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Color(0xFFF5C841)));
                  }
                  
                  List<Message> messages = snapshot.data ?? [];
                  
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.white30),
                          SizedBox(height: 16),
                          Text('Start your conversation', 
                            style: TextStyle(color: Colors.white54, fontSize: 18)),
                          Text('Say hello to ${isSender ? widget.swap.receiverName : widget.swap.senderName}!', 
                            style: TextStyle(color: Colors.white30, fontSize: 14)),
                        ],
                      ),
                    );
                  }
                  
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  
                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      Message message = messages[index];
                      bool isMe = message.senderId == authProvider.user?.id;
                      
                      return Container(
                        margin: EdgeInsets.only(
                          bottom: 12,
                          left: isMe ? 50 : 0,
                          right: isMe ? 0 : 50,
                        ),
                        child: Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isMe ? Color(0xFFF5C841) : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(isMe ? 20 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.text,
                                  style: TextStyle(
                                    color: isMe ? Colors.black : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isMe ? Colors.black54 : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF0E0E2C),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        _sendMessage();
                      },
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5C841),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFF5C841).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.black),
                    onPressed: _sendMessage,
                  ),
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
    if (authProvider.user == null) return;
    
    String messageText = _messageController.text.trim();
    
    try {
      Message message = Message(
        id: _uuid.v4(),
        chatId: widget.swap.id,
        senderId: authProvider.user!.id,
        senderName: authProvider.user!.name,
        text: messageText,
        timestamp: DateTime.now(),
      );
      
      print('Sending message with chatId: ${widget.swap.id}');
      print('Message: ${message.toMap()}');
      
      await _databaseService.sendMessage(message);
      _messageController.clear(); // Clear only after successful send
    } catch (e) {
      print('Send message error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateSwapStatus(SwapStatus status) async {
    await _databaseService.updateSwapStatus(widget.swap.id, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Swap ${status.name.toLowerCase()}')),
    );
  }
}
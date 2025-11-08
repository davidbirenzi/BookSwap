// Message model - represents a chat message between students
class Message {
  final String id; // unique message ID
  final String chatId; // ID of the swap this message belongs to
  final String senderId; // ID of student who sent the message
  final String senderName; // display name of sender
  final String text; // actual message content
  final DateTime timestamp; // when the message was sent

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  // Create message object from Firestore data
  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      chatId: map['chatId'] ?? '', // links message to specific swap
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '', // stored for easy display
      text: map['text'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  // Convert message object to map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch, // store as timestamp
    };
  }
}
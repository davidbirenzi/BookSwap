enum SwapStatus { pending, accepted, rejected }

class Swap {
  final String id;
  final String bookId;
  final String bookTitle;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final SwapStatus status;
  final DateTime createdAt;

  Swap({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.status,
    required this.createdAt,
  });

  factory Swap.fromMap(Map<String, dynamic> map, String id) {
    return Swap(
      id: id,
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      status: SwapStatus.values[map['status'] ?? 0],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'status': status.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
// Status of a swap request between students
enum SwapStatus { pending, accepted, rejected }

// Swap model - represents a textbook exchange request
class Swap {
  final String id; // unique swap request ID
  final String bookId; // ID of the book being requested
  final String bookTitle; // title of the book (for easy display)
  final String senderId; // ID of student making the request
  final String senderName; // name of student making the request
  final String receiverId; // ID of book owner
  final String receiverName; // name of book owner
  final SwapStatus status; // current status of the swap request
  final DateTime createdAt; // when the swap request was made

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

  // Create swap object from Firestore data
  factory Swap.fromMap(Map<String, dynamic> map, String id) {
    return Swap(
      id: id,
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? '', // stored for convenience
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      status: SwapStatus.values[map['status'] ?? 0], // convert index to enum
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  // Convert swap object to map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'status': status.index, // store enum as index
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
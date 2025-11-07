import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/swap.dart';
import '../models/message.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Books
  Future<String> addBook(Book book) async {
    DocumentReference ref = await _firestore.collection('books').add(book.toMap());
    return ref.id;
  }

  Stream<List<Book>> getBooks() {
    return _firestore.collection('books').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<Book>> getUserBooks(String userId) {
    return _firestore.collection('books')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> updateBook(String bookId, Book book) async {
    await _firestore.collection('books').doc(bookId).update(book.toMap());
  }

  Future<void> deleteBook(String bookId) async {
    await _firestore.collection('books').doc(bookId).delete();
  }

  // Swaps
  Future<String> createSwap(Swap swap) async {
    DocumentReference ref = await _firestore.collection('swaps').add(swap.toMap());
    return ref.id;
  }

  Stream<List<Swap>> getUserSwaps(String userId) {
    return _firestore.collection('swaps')
        .where('senderId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Swap.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<Swap>> getReceivedSwaps(String userId) {
    return _firestore.collection('swaps')
        .where('receiverId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Swap.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> updateSwapStatus(String swapId, SwapStatus status) async {
    await _firestore.collection('swaps').doc(swapId).update({'status': status.index});
  }

  // Messages
  Future<String> sendMessage(Message message) async {
    try {
      DocumentReference ref = await _firestore.collection('messages').add(message.toMap());
      return ref.id;
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Stream<List<Message>> getMessages(String chatId) {
    return _firestore.collection('messages')
        .where('chatId', isEqualTo: chatId)
        .snapshots()
        .map((snapshot) {
      List<Message> messages = snapshot.docs.map((doc) => Message.fromMap(doc.data(), doc.id)).toList();
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  // Get chat participants for a swap
  Stream<List<String>> getChatParticipants(String swapId) {
    return _firestore.collection('swaps').doc(swapId).snapshots().map((doc) {
      if (doc.exists) {
        Map<String, dynamic> data = doc.data()!;
        return [data['senderId'], data['receiverId']];
      }
      return [];
    });
  }
}
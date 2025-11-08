import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/swap.dart';
import '../models/message.dart';

// Database service - handles all Firestore operations
// This is where we talk to Firebase to store and retrieve data
class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === BOOK OPERATIONS ===
  
  // Add a new book listing to the database
  Future<String> addBook(Book book) async {
    DocumentReference ref = await _firestore.collection('books').add(book.toMap());
    return ref.id; // return the auto-generated ID
  }

  // Get all book listings in real-time
  Stream<List<Book>> getBooks() {
    return _firestore.collection('books').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Get books owned by a specific user
  Stream<List<Book>> getUserBooks(String userId) {
    return _firestore.collection('books')
        .where('ownerId', isEqualTo: userId) // filter by owner
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Update an existing book listing
  Future<void> updateBook(String bookId, Book book) async {
    await _firestore.collection('books').doc(bookId).update(book.toMap());
  }

  // Delete a book listing
  Future<void> deleteBook(String bookId) async {
    await _firestore.collection('books').doc(bookId).delete();
  }

  // === SWAP OPERATIONS ===
  
  // Create a new swap request
  Future<String> createSwap(Swap swap) async {
    DocumentReference ref = await _firestore.collection('swaps').add(swap.toMap());
    return ref.id;
  }

  // Get swap requests sent by a user
  Stream<List<Swap>> getUserSwaps(String userId) {
    return _firestore.collection('swaps')
        .where('senderId', isEqualTo: userId) // swaps they initiated
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Swap.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Get swap requests received by a user
  Stream<List<Swap>> getReceivedSwaps(String userId) {
    return _firestore.collection('swaps')
        .where('receiverId', isEqualTo: userId) // swaps sent to them
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Swap.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Update the status of a swap (accept/reject)
  Future<void> updateSwapStatus(String swapId, SwapStatus status) async {
    await _firestore.collection('swaps').doc(swapId).update({'status': status.index});
  }

  // === MESSAGE OPERATIONS ===
  
  // Send a new message in a chat
  Future<String> sendMessage(Message message) async {
    try {
      DocumentReference ref = await _firestore.collection('messages').add(message.toMap());
      return ref.id;
    } catch (e) {
      // Re-throw the error so the UI can handle it
      rethrow;
    }
  }

  // Get all messages for a specific chat in real-time
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore.collection('messages')
        .where('chatId', isEqualTo: chatId) // messages for this swap
        .snapshots()
        .map((snapshot) {
      List<Message> messages = snapshot.docs.map((doc) => Message.fromMap(doc.data(), doc.id)).toList();
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp)); // sort by time
      return messages;
    });
  }

  // Get the two users involved in a swap (for chat purposes)
  Stream<List<String>> getChatParticipants(String swapId) {
    return _firestore.collection('swaps').doc(swapId).snapshots().map((doc) {
      if (doc.exists) {
        Map<String, dynamic> data = doc.data()!;
        return [data['senderId'], data['receiverId']]; // return both user IDs
      }
      return []; // empty list if swap doesn't exist
    });
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/book.dart';
import '../models/swap.dart';
import '../models/message.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Books
  Future<String> addBook(Book book, File? imageFile) async {
    String imageUrl = '';
    
    if (imageFile != null) {
      String fileName = 'books/${DateTime.now().millisecondsSinceEpoch}.jpg';
      TaskSnapshot snapshot = await _storage.ref(fileName).putFile(imageFile);
      imageUrl = await snapshot.ref.getDownloadURL();
    }
    
    Book bookWithImage = Book(
      id: book.id,
      title: book.title,
      author: book.author,
      condition: book.condition,
      imageUrl: imageUrl,
      ownerId: book.ownerId,
      ownerName: book.ownerName,
      createdAt: book.createdAt,
    );
    
    DocumentReference ref = await _firestore.collection('books').add(bookWithImage.toMap());
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
  Future<void> sendMessage(Message message) async {
    await _firestore.collection('messages').add(message.toMap());
  }

  Stream<List<Message>> getMessages(String chatId) {
    return _firestore.collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromMap(doc.data(), doc.id)).toList();
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
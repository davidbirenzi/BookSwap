// Different conditions a textbook can be in
enum BookCondition { brandNew, likeNew, good, used }

// Book model - represents a textbook listing
class Book {
  final String id; // unique book listing ID
  final String title; // textbook title
  final String author; // book author
  final BookCondition condition; // physical condition of the book
  final String imageUrl; // base64 encoded image or URL
  final String ownerId; // ID of the student who owns this book
  final String ownerName; // display name of the owner
  final DateTime createdAt; // when this listing was created

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    required this.imageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
  });

  // Create book object from Firestore data
  factory Book.fromMap(Map<String, dynamic> map, String id) {
    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      condition: BookCondition.values[map['condition'] ?? 0], // convert index back to enum
      imageUrl: map['imageUrl'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  // Convert book object to map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'condition': condition.index, // store enum as index number
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'createdAt': createdAt.millisecondsSinceEpoch, // store as timestamp
    };
  }
}
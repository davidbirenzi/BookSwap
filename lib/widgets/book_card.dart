import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/book.dart';

// Reusable widget to display a book listing in a card format
// Used in browse listings and my listings screens
class BookCard extends StatelessWidget {
  final Book book; // the book data to display
  final VoidCallback? onTap; // what happens when user taps the card
  final Widget? actionButton; // optional button (like "Request Swap" or "Edit")

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.actionButton,
  });

  // Helper method to display book cover image
  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      // No image provided, show book icon
      return Icon(Icons.book, size: 30, color: Colors.grey[600]);
    }
    
    try {
      if (imageUrl.startsWith('data:image/')) {
        // Base64 encoded image (what we use in this app)
        final base64String = imageUrl.split(',')[1];
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.book, size: 30, color: Colors.grey[600]);
          },
        );
      } else if (imageUrl.startsWith('http')) {
        // Network image URL
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.book, size: 30, color: Colors.grey[600]);
          },
        );
      }
    } catch (e) {
      // If anything goes wrong, show the book icon
    }
    
    return Icon(Icons.book, size: 30, color: Colors.grey[600]);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap, // make the whole card tappable
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Book cover image section
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300], // background for image
                ),
                child: book.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImage(book.imageUrl),
                      )
                    : Icon(Icons.book, size: 30, color: Colors.grey[600]),
              ),
              SizedBox(width: 16),
              // Book details section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book title
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    // Author name
                    Text(
                      'by ${book.author}',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    // Book condition
                    Text(
                      book.condition.name,
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    // How long ago it was posted
                    Text(
                      '${DateTime.now().difference(book.createdAt).inDays} days ago',
                      style: TextStyle(color: Colors.black38, fontSize: 12),
                    ),
                    // Optional action button (edit, delete, request swap, etc.)
                    if (actionButton != null) ...[
                      SizedBox(height: 8),
                      actionButton!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
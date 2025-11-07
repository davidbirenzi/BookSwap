import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final Widget? actionButton;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.actionButton,
  });

  Widget _buildImage(String imageUrl) {
    try {
      if (imageUrl.startsWith('data:') || !imageUrl.startsWith('http')) {
        final base64String = imageUrl.contains(',') ? imageUrl.split(',')[1] : imageUrl;
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.book, size: 30, color: Colors.grey[600]);
          },
        );
      } else {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.book, size: 30, color: Colors.grey[600]);
          },
        );
      }
    } catch (e) {
      return Icon(Icons.book, size: 30, color: Colors.grey[600]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: book.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImage(book.imageUrl),
                      )
                    : Icon(Icons.book, size: 30, color: Colors.grey[600]),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'by ${book.author}',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      book.condition.name,
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${DateTime.now().difference(book.createdAt).inDays} days ago',
                      style: TextStyle(color: Colors.black38, fontSize: 12),
                    ),
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:convert';
import 'dart:typed_data';
import '../models/book.dart';
import '../services/database_service.dart';
import '../providers/auth_provider.dart';

// Screen for adding new books or editing existing ones
// Students use this to list their textbooks for swapping
class AddBookScreen extends StatefulWidget {
  final Book? book; // if provided, we're editing; if null, we're adding new
  
  const AddBookScreen({super.key, this.book});

  @override
  AddBookScreenState createState() => AddBookScreenState();
}

class AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>(); // for form validation
  final _titleController = TextEditingController(); // book title input
  final _authorController = TextEditingController(); // author input
  final DatabaseService _databaseService = DatabaseService();
  
  BookCondition _selectedCondition = BookCondition.brandNew; // default condition
  Uint8List? _imageBytes; // raw image data for preview
  String? _base64Image; // base64 string to store in database
  bool _isLoading = false; // tracks save operation

  @override
  void initState() {
    super.initState();
    // If editing existing book, populate fields with current data
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _selectedCondition = widget.book!.condition;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: Text(widget.book == null ? 'Add Book' : 'Edit Book')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image picker section - tap to select book cover photo
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.yellow, // yellow background matches app theme
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : widget.book?.imageUrl.isNotEmpty == true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildPreviewImage(widget.book!.imageUrl),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 50, color: Colors.black54),
                                Text('Tap to select image', style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                ),
              ),
              SizedBox(height: 16),
              // Book title input
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(labelText: 'Book Title'),
                validator: (value) => value?.isEmpty ?? true ? 'Enter title' : null,
              ),
              SizedBox(height: 16),
              // Author input
              TextFormField(
                controller: _authorController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(labelText: 'Author'),
                validator: (value) => value?.isEmpty ?? true ? 'Enter author' : null,
              ),
              SizedBox(height: 16),
              // Book condition selector
              Text('Condition', style: TextStyle(color: Colors.black, fontSize: 16)),
              SizedBox(height: 8),
              // Create a selectable option for each condition
              ...BookCondition.values.map((condition) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedCondition = condition),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    margin: EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: _selectedCondition == condition ? Color(0xFFF5C841) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedCondition == condition ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: _selectedCondition == condition ? Colors.black : Colors.grey,
                        ),
                        SizedBox(width: 8),
                        Text(condition.name, style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 24),
              // Save button - shows spinner while saving
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _saveBook(authProvider.user!),
                      child: Text(widget.book == null ? 'Add Book' : 'Update Book'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to display existing book images
  Widget _buildPreviewImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Icon(Icons.camera_alt, size: 50, color: Colors.black54);
    }
    
    try {
      if (imageUrl.startsWith('data:image/')) {
        final base64String = imageUrl.split(',')[1];
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.camera_alt, size: 50, color: Colors.black54);
          },
        );
      } else if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.camera_alt, size: 50, color: Colors.black54);
          },
        );
      } else {
        // Try to decode as base64 without prefix
        return Image.memory(
          base64Decode(imageUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.camera_alt, size: 50, color: Colors.black54);
          },
        );
      }
    } catch (e) {
      return Icon(Icons.camera_alt, size: 50, color: Colors.black54);
    }
  }

  // Let user pick an image from their gallery
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, // only gallery, no camera
        maxWidth: 600, // resize to reasonable size
        maxHeight: 800,
        imageQuality: 80, // compress to save storage
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes); // convert to base64 for storage
        
        setState(() {
          _imageBytes = bytes;
          _base64Image = base64String;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image selected successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    }
  }

  // Save the book to the database
  Future<void> _saveBook(user) async {
    if (!_formKey.currentState!.validate()) return; // check form validation
    
    // Require image for new books
    if (_base64Image == null && widget.book == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image for the book')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Determine which image to use
      String imageUrl = '';
      if (_base64Image != null && _base64Image!.isNotEmpty) {
        // Use newly selected image
        imageUrl = 'data:image/jpeg;base64,$_base64Image';
      } else if (widget.book != null && widget.book!.imageUrl.isNotEmpty) {
        // Keep existing image when editing
        imageUrl = widget.book!.imageUrl;
      }
      
      final book = Book(
        id: widget.book?.id ?? '',
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        condition: _selectedCondition,
        imageUrl: imageUrl,
        ownerId: user.id,
        ownerName: user.name,
        createdAt: widget.book?.createdAt ?? DateTime.now(),
      );
      
      // Save to database - add new or update existing
      if (widget.book == null) {
        await _databaseService.addBook(book);
      } else {
        await _databaseService.updateBook(widget.book!.id, book);
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.book == null ? 'Book added successfully!' : 'Book updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
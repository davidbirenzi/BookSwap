import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:convert';
import 'dart:typed_data';
import '../models/book.dart';
import '../services/database_service.dart';
import '../providers/auth_provider.dart';

class AddBookScreen extends StatefulWidget {
  final Book? book;
  
  const AddBookScreen({super.key, this.book});

  @override
  AddBookScreenState createState() => AddBookScreenState();
}

class AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  
  BookCondition _selectedCondition = BookCondition.good;
  Uint8List? _imageBytes;
  String? _base64Image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
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
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(labelText: 'Book Title'),
                validator: (value) => value?.isEmpty ?? true ? 'Enter title' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(labelText: 'Author'),
                validator: (value) => value?.isEmpty ?? true ? 'Enter author' : null,
              ),
              SizedBox(height: 16),
              Text('Condition', style: TextStyle(color: Colors.black, fontSize: 16)),
              SizedBox(height: 8),
              ...BookCondition.values.map((condition) {
                return ListTile(
                  title: Text(condition.name, style: TextStyle(color: Colors.black)),
                  leading: Radio<BookCondition>(
                    value: condition,
                    groupValue: _selectedCondition,
                    onChanged: (value) => setState(() => _selectedCondition = value!),
                    activeColor: Color(0xFFF5C841),
                  ),
                  onTap: () => setState(() => _selectedCondition = condition),
                );
              }),
              SizedBox(height: 24),
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

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        
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

  Future<void> _saveBook(user) async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_base64Image == null && widget.book == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image for the book')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      String imageUrl = '';
      if (_base64Image != null && _base64Image!.isNotEmpty) {
        imageUrl = 'data:image/jpeg;base64,$_base64Image';
      } else if (widget.book != null && widget.book!.imageUrl.isNotEmpty) {
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